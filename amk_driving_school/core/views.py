# core/views.py
from .utils import send_fcm_notification, notify_all_admins
from decimal import Decimal
from datetime import date
from optparse import Option
from django.utils import timezone
from dashboard.serializers import QuestionSerializer # type: ignore
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiExample
from .models import Answer, Article, Booking, Course, Batch, Question, Quiz, Session, DeviceToken,  Submission
from .serializers import (
    ArticleSer, BatchDetailSerializer, BatchSerializer, BookingSerializer, BookingListDetailSerializer,
    CourseDetailSerializer, CourseListSerializer, NotificationSerializer, QuestionPublicSer, QuizDetailSer,
    SessionSer, DeviceTokenSer, SubmissionSer)
from .services import generate_sessions
from django.db.models import Q, Exists, OuterRef, Subquery
from rest_framework.permissions import IsAuthenticated
# Swagger/Redoc (drf-spectacular)
from drf_spectacular.utils import extend_schema, extend_schema_view
from firebase_admin import messaging

from django.shortcuts import get_object_or_404

from rest_framework.views import APIView # Custom Logic ရေးသားရန်
from datetime import datetime, timedelta, time # Time တွက်ချက်မှုများအတွက်
from .serializers import AvailableSlotSerializer

from .utils import send_fcm_notification
from .models import Booking, Notification

from django.contrib.auth.models import User
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from django.contrib.auth.models import User
from django.contrib.auth.models import User


class IsInstructorOrAdmin(permissions.BasePermission):
    def has_permission(self, req, view):  # type: ignore
        # roles သုံးမယ်ဆို: return req.user.is_authenticated and req.user.role in ("owner","admin","instructor")
        return bool(
            req.user and
            req.user.is_authenticated and
            req.user.role in ("owner", "admin", "instructor")
        )


class IsAdminOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS: return True
        return request.user and request.user.is_staff



class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all()
    # serializer_class = CourseSer
    permission_classes = [permissions.AllowAny]

    def get_serializer_class(self):
        if self.action == 'retrieve': # Detail view အတွက်
            return CourseDetailSerializer
        return CourseListSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        public = self.request.query_params.get("public")
        return qs.filter(is_public=True) if public == "true" else qs


class BatchViewSet(viewsets.ModelViewSet):
    queryset = Batch.objects.select_related("course", "instructor")
    # serializer_class = BatchSerializer
    permission_classes = [permissions.AllowAny]

    def get_serializer_class(self):
        if self.action == 'retrieve': # Detail view အတွက်
            return BatchDetailSerializer
        return BatchSerializer

    @action(detail=False, methods=["GET"], permission_classes=[permissions.IsAuthenticated])
    def available_for_me(self, request):
        user = request.user

        # 1. Get all of the current user's active, scheduled sessions
        my_active_sessions = Session.objects.filter(
            batch__enrollment__user=user,
            batch__enrollment__status="active",
            status="scheduled"
        ).values("start_dt", "end_dt")

        # 2. Build Q objects for each overlapping time range
        overlap_conditions = Q()
        for s in my_active_sessions:
            overlap_conditions |= Q(
                sessions__start_dt__lt=s['end_dt'],
                sessions__end_dt__gt=s['start_dt'],
                sessions__status='scheduled'
            )

        # 3. Exclude batches that have any session matching the overlap conditions
        # Also, ensure the batch has at least one scheduled session.
        if overlap_conditions:
            qs = Batch.objects.annotate(
                has_scheduled_sessions=Exists(Session.objects.filter(batch=OuterRef('pk'), status='scheduled'))
            ).filter(has_scheduled_sessions=True).exclude(overlap_conditions)
        else:
            # If user has no sessions, all batches with scheduled sessions are available
            qs = Batch.objects.annotate(
                has_scheduled_sessions=Exists(Session.objects.filter(batch=OuterRef('pk'), status='scheduled'))
            ).filter(has_scheduled_sessions=True)

        return Response(BatchSerializer(qs.distinct(), many=True).data)

    @action(detail=True, methods=['get'], url_path='available-slots')
    def available_slots(self, request, pk=None):
        """
        Return a list of available (scheduled) session start times for a batch.
        """
        batch = self.get_object()

        # ဒီ batch နဲ့ဆိုင်ပြီး "scheduled" ဖြစ်နေတဲ့ session တွေကိုပဲ ဆွဲထုတ်ပါ
        scheduled_sessions = Session.objects.filter(batch=batch, status='scheduled')

        # အဲ့ဒီ session တွေရဲ့ start_dt (start datetime) တွေကိုပဲ list အဖြစ်ပြန်ပေးပါ
        # Flutter က ဒါကိုသုံးပြီး ပြက္ခဒိန်မှာ အားတဲ့ရက်တွေကို ပြပေးမှာပါ
        slots = list(scheduled_sessions.values_list('start_dt', flat=True))

        return Response(slots)


@extend_schema_view(
    list=extend_schema(description="List sessions", tags=["Sessions"]),
    retrieve=extend_schema(description="Retrieve a session", tags=["Sessions"]),
)
class SessionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Session.objects.select_related("batch", "batch__course", "batch__instructor")
    serializer_class = SessionSer
    permission_classes = [permissions.AllowAny]


    @action(detail=True, methods=["POST"], permission_classes=[IsInstructorOrAdmin])
    def mark_completed(self, request, pk=None):
        s = self.get_object()
        s.status = "completed"; s.save(update_fields=["status"])
        # notify enrolled students
        tokens = list(DeviceToken.objects.filter(
            user__bookings__sessions=s,
            user__bookings__status='approved').values_list("token", flat=True).distinct())
        if tokens:
            messaging.send_multicast(messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=f"{s.batch.course.title}",
                    body="Class marked as completed"),
                data={"type":"session.completed","session_id":str(s.id)}
            ))
        return Response({"ok": True})

    @extend_schema(
        description="Get today's sessions for the current instructor (Asia/Yangon).",
        responses={200: SessionSer(many=True)},
        tags=["Sessions"],
    )
    @action(detail=False, methods=["GET"], permission_classes=[permissions.IsAuthenticated])
    def today_for_teacher(self, request):
        ygn_today = timezone.localdate()
        qs = self.queryset.filter(
            start_dt__date=ygn_today,
            batch__instructor=request.user,
            status="scheduled",
        ).order_by("start_dt")
        return Response(SessionSer(qs, many=True).data)

    @extend_schema(
        description="Generate sessions from weekday template (60min×3days or 90min×2days).",
        request={
            "application/json": {
                "type": "object",
                "properties": {
                    "batch_id": {"type": "integer"},
                    "weekdays": {"type": "array", "items": {"type": "integer"}, "example": [0, 2, 4]},
                    "start_time": {"type": "string", "example": "16:00"},
                    "duration_min": {"type": "integer", "enum": [60, 90]},
                    "since": {"type": "string", "format": "date"},
                    "until": {"type": "string", "format": "date"},
                },
                "required": ["batch_id", "weekdays", "start_time", "duration_min", "since", "until"],
            }
        },
        responses={200: {"type": "object", "properties": {"created": {"type": "integer"}}}},
        tags=["Sessions"],
    )
    @action(detail=False, methods=["POST"], permission_classes=[IsInstructorOrAdmin])
    def generate(self, request):
        data = request.data
        batch = get_object_or_404(Batch, id=data["batch_id"])
        created = generate_sessions(
            batch=batch,
            weekdays=list(map(int, data["weekdays"])),
            start_time=str(data["start_time"]),
            duration_min=int(data["duration_min"]),
            since=date.fromisoformat(data["since"]),
            until=date.fromisoformat(data["until"]),
        )
        return Response({"created": created})

    @action(detail=False, methods=['get'], url_path='my-upcoming')
    def my_upcoming(self, request):
        """Return a list of upcoming (scheduled) sessions for the current user."""
        user = request.user
        now = timezone.now()
        # User enroll လုပ်ထားပြီး၊ scheduled ဖြစ်ကာ၊ အခုချိန်ထက်နောက်ကျတဲ့ session တွေကိုပဲဆွဲထုတ်ပါ
        upcoming_sessions = Session.objects.filter(
            booking__student=user,
            booking__status='approved',
            status='scheduled',
            start_dt__gte=now
        ).order_by('start_dt')[:5] # အများဆုံး ၅ ခုပဲပြမယ်

        serializer = self.get_serializer(upcoming_sessions, many=True)
        return Response(serializer.data)


class PushViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request):
        ser = DeviceTokenSer(data=request.data)
        ser.is_valid(raise_exception=True)
        token_value = ser.validated_data["token"] # type: ignore
        platform_value = ser.validated_data.get("platform", "android") # type: ignore
        DeviceToken.objects.update_or_create(
            user=request.user,
            token=token_value,
            defaults={"platform": platform_value},  # type: ignore
        )
        return Response({"ok": True})



class IsStudent(permissions.BasePermission):
    def has_permission(self, req, view):
        # login ဝင်ထားပြီး role က 'student' ဖြစ်မှ ခွင့်ပြုမယ်
        return bool(
            req.user and
            req.user.is_authenticated and
            req.user.role == 'student' # Django User model မှာ role field ရှိတယ်လို့ ယူဆပါတယ်
        )


class BookingViewSet(viewsets.ModelViewSet):
    """ViewSet for handling booking requests."""
    queryset = Booking.objects.all()
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        
        if self.action == 'create':
            return BookingSerializer
        return BookingListDetailSerializer

    def get_queryset(self):
        user = self.request.user
        if user.is_staff or user.is_superuser:
            return Booking.objects.all().order_by('-created_at')
        return Booking.objects.filter(student=user).order_by('-created_at')

    def perform_create(self, serializer):
        # Booking အသစ်လုပ်ရင် student ကို auto သတ်မှတ်
        booking_instance = serializer.save()

        sessions_to_update = booking_instance.sessions.all()

        # Sessions Status ကို 'booked' အဖြစ် ပြောင်းလဲခြင်း
        sessions_to_update = serializer.validated_data.get('sessions')
        
        session_ids = [s.id for s in sessions_to_update]

        # Sessions များကို bulk update လုပ်ခြင်း
        # Session.objects.filter(id__in=session_ids).update(status='booked')

        # total_duration = sum(s.duration_hours for s in sessions_to_update)

        # user = self.request.user
        # user.remaining_credit_hours -= total_duration # type: ignore

        # user.save()

        notify_all_admins(
            title="New Booking",
            body=f"Booking အသစ် {booking_instance.student.username} ထံမှ ဝင်လာပါပြီ။",
            data={"type": "new_booking", "booking_id": str(booking_instance.id)}
        )

        return booking_instance
    
    

    # core/views.py (BookingViewSet.approve method အတွင်း)

    @action(detail=True, methods=['post'], permission_classes=[IsInstructorOrAdmin])
    def approve(self, request, pk=None):
        booking = self.get_object()
        user = booking.student

        if booking.status != 'approved':

            course_duration = booking.course.total_duration_hours

            booked_duration = sum(s.duration_hours for s in booking.sessions.all())

            user.remaining_credit_hours += course_duration # Course အတွက် Credit ပေါင်းထည့်
            user.remaining_credit_hours -= booked_duration # Booking အတွက် Credit နုတ်ယူ
            user.save()


            booking.status = 'approved'
            booking.save()

            # 2. Database Notification (Inbox) ရေးသွင်းခြင်း
            Notification.objects.create(
                user=booking.student,
                title="သင်တန်း စာရင်းသွင်းမှု အတည်ပြုပြီး",
                body=f"သင်၏ {booking.course.title} သင်တန်းကို အောင်မြင်စွာ စာရင်းသွင်းပြီးပါပြီ။",
                # Optional: payload data ထည့်သွင်းနိုင်
            )

            # 3. FCM Push Notification ပို့ခြင်း
            send_fcm_notification(
                user=booking.student,
                title="အတည်ပြုပြီး",
                body=f"{booking.course.title} သင်တန်း စတင်တက်ရောက်နိုင်ပါပြီ။",
                data={"type": "booking_approved", "course_id": str(booking.course.id)} 
            )

        return Response({'status': 'booking approved'})

# Note: reject မှာလည်း student ကို notification ပြန်ပို့နိုင်ပါတယ်။

    @action(detail=True, methods=['post'], permission_classes=[IsInstructorOrAdmin]) # Permission check ထည့်လိုက်သည်
    def reject(self, request, pk=None):
        booking = self.get_object()
        booking.status = 'rejected'
        booking.save()
        
        # Reject လုပ်ရင် Sessions တွေကို 'available' (scheduled) အဖြစ် ပြန်ပြောင်းပါ
        booking.sessions.all().update(status='available')

        if booking.status == 'rejected' and booking.student:
            # Booking လုပ်ခဲ့သော Sessions များ၏ စုစုပေါင်း duration ကို ပြန်ယူပါ
            total_duration = sum(s.duration_hours for s in booking.sessions.all())
            
            # ကျောင်းသား၏ Credit Balance ထဲသို့ ပြန်လည်ပေါင်းထည့်ပေးပါ
            student_user = booking.student
            student_user.remaining_credit_hours += total_duration # type: ignore
            student_user.save()
        
        return Response({'status': 'booking rejected'})

class QuizViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Quiz.objects.all()
    serializer_class = QuizDetailSer
    permission_classes = [permissions.AllowAny]

    @extend_schema(
        request=None,
        responses={"200": {"type": "object", "properties": {"submission_id": {"type": "integer"}}}},
        examples=[OpenApiExample("Start quiz", value={})],
    )
    @action(detail=True, methods=["post"], url_path="start")
    def start(self, request, pk=None):
        if not request.user.is_authenticated:
            return Response({"detail": "Authentication credentials were not provided."}, status=status.HTTP_401_UNAUTHORIZED)
        quiz = self.get_object()
        sub = Submission.objects.create(quiz=quiz, student=request.user)
        return Response({"submission_id": sub.id}) # type: ignore
        
    @extend_schema(
        summary="Get all questions for a specific quiz (Public)",
        responses={200: QuestionPublicSer(many=True)}
    )
    @action(detail=True, methods=['get'])
    def questions(self, request, pk=None):
        try:
            quiz = self.get_object() # pk ဖြင့် Quiz object ကို ရယူ
            questions = Question.objects.filter(quiz=quiz).order_by('pk') # 💡 စီထားခြင်း
            
            # 🛑 [FIX]: QuestionPublicSer ကို မှန်ကန်စွာ အသုံးပြုခြင်း
            # QuestionPublicSer သည် options နှင့် order_items ကို တွက်ချက်ပေးမည်။
            serializer = QuestionPublicSer(questions, many=True) 
            
            # 💡 [FIX]: quiz_title Field ၏ နာမည်ကို Model တွင် 'title' (သို့မဟုတ်) 'quiz_title' အပေါ်မူတည်၍ ပြင်ဆင်ပါ။
            quiz_title = getattr(quiz, 'title', quiz.pk) # Model မှာ 'title' ရှိရင် ယူ၊ မရှိရင် pk ယူ
            
            return Response({
                'id': quiz.pk,
                'quiz_title': quiz_title, # 💡 'quiz_title' အဖြစ် ပြန်ပို့သည်
                'questions': serializer.data,
            })
            
        except Quiz.DoesNotExist:
            return Response({'detail': 'Quiz not found.'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # 🛑 [IMPORTANT]: 500 Error ဖြစ်ရင် ဒီနေရာကနေ Log ထုတ်ပြီး စစ်ဆေးနိုင်ပါတယ်။
            print(f"Error fetching questions: {e}")
            return Response({'detail': f'Server error: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class SubmissionViewSet(viewsets.GenericViewSet):
    queryset = Submission.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = SubmissionSer

    @extend_schema(
        request={"application/json": {
            "type": "object",
            "properties": {
                "question_id": {"type": "integer"},
                "selected_option_id": {"type": "integer"},
                "ordered_item_ids": {"type": "array", "items": {"type": "integer"}}
            },
            "required": ["question_id"]
        }},
        responses={"200": {"type": "object", "properties": {"ok": {"type": "boolean"}}}},
        examples=[OpenApiExample("MCQ", value={"question_id":1,"selected_option_id":10}),
                OpenApiExample("ORDER", value={"question_id":2,"ordered_item_ids":[5,7,6,8]})],
    )
    @action(detail=True, methods=["post"], url_path="answer")
    def answer(self, request, pk=None):
        sub = self.get_object()
        qid = request.data.get("question_id")
        if not qid:
            return Response({"error": "question_id is required"}, status=400)
        q = get_object_or_404(Question, id=qid)
        if q.qtype == "MCQ":
            opt_id = request.data.get("selected_option_id")
            if not opt_id:
                return Response({"error": "selected_option_id is required for MCQ"}, status=400)
            opt = get_object_or_404(Option, id=opt_id, question=q) # type: ignore
            Answer.objects.update_or_create(
                submission=sub, question=q,
                defaults={"selected_option": opt, "given_order": None})
        else:
            ids = request.data["ordered_item_ids"]
            Answer.objects.update_or_create(
                submission=sub, question=q,
                defaults={"selected_option": None, "given_order": ids})
        return Response({"ok": True})

    @extend_schema(
        request=None,
        responses={"200": {"type": "object",
        "properties": {"score":{"type":"number"},"correct":{"type":"integer"},"total":{"type":"integer"}}}}
    )
    @action(detail=True, methods=["post"], url_path="finish")
    def finish(self, request, pk=None):
        sub = self.get_object()
        # Check if already finished
        if sub.finished_at:
            return Response({"error": "This submission is already finished."}, status=400)
        result = sub.calculate_score()
        return Response(result)

    @extend_schema(
        summary="Get all questions for a specific submission",
        responses={200: QuestionPublicSer(many=True)}
    )
    @action(detail=True, methods=['get'])
    def questions(self, request, pk=None):
        submission = self.get_object()
        # user က ဒီ submission ရဲ့ ပိုင်ရှင်ဟုတ်မဟုတ် စစ်ဆေးပါ
        if request.user != submission.student:
            return Response({"detail": "Not allowed."}, status=status.HTTP_403_FORBIDDEN)
        
        questions = submission.quiz.questions.all().prefetch_related('options', 'order_items')
        serializer = QuestionPublicSer(questions, many=True)
        return Response(serializer.data)
    
    # core/views.py (SessionViewSet.mark_completed method အတွင်း)

@action(detail=True, methods=["POST"], permission_classes=[IsInstructorOrAdmin])
def mark_completed(self, request, pk=None):
    s = self.get_object()
    s.status = "completed"; s.save(update_fields=["status"])
    
    # Session ကို တက်ရောက်ခွင့်ရှိသူများ (Approved Students)
    approved_students = User.objects.filter(
        bookings__sessions=s,
        bookings__status='approved'
    ).distinct()

    tokens = []

    for student in approved_students:
        # 1. Database Notification (Inbox) ရေးသွင်းခြင်း
        Notification.objects.create(
            user=student,
            title=f"{s.batch.course.title} ပြီးဆုံး",
            body=f"{s.batch.course.title} အတွက် Session {s.start_dt.strftime('%d-%b')} ကို ပြီးစီးကြောင်း မှတ်သားလိုက်ပါပြီ။",
            payload={"session_id": str(s.id)}, # Custom data
        )
        
        # 2. FCM Token များကို စုဆောင်းခြင်း
        student_tokens = list(student.fcm_devices.values_list("token", flat=True)) # type: ignore # fcm_devices ကို DeviceToken model မှာ related_name နဲ့ သတ်မှတ်ထားတယ်လို့ ယူဆပါတယ်
        tokens.extend(student_tokens)


    if tokens:
        messaging.send_multicast(messaging.MulticastMessage( # type: ignore
            tokens=tokens,
            notification=messaging.Notification(
                title=f"{s.batch.course.title}",
                body="Class marked as completed"),
            data={"type":"session.completed","session_id":str(s.id)}
        ))
    return Response({"ok": True})




class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSer
    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        qs = Article.objects.filter(published=True) if self.request.method == "GET" else Article.objects.all()
        q = self.request.query_params.get("q") # type: ignore
        tag = self.request.query_params.get("tag") # type: ignore
        if q:
            qs = qs.filter(Q(title__icontains=q) | Q(body__icontains=q))
        if tag:
            qs = qs.filter(tags__contains=[tag])
        return qs.order_by("-created_at")



class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.request.user.notifications.all() # type: ignore

    @action(detail=True, methods=['post'], url_path='mark-as-read')
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        if notification.user == request.user:
            notification.is_read = True
            notification.save()
            return Response({'status': 'notification marked as read'})
        return Response(status=status.HTTP_403_FORBIDDEN)

    @action(detail=False, methods=['post'], url_path='mark-all-as-read')
    def mark_all_as_read(self, request):
        user: 'User' = request.user
        unread_notifications = self.request.user.notifications.filter(is_read=False) # type: ignore
        updated_count = unread_notifications.update(is_read=True)

        return Response({
            'status': 'success', 
            'message': 'All notifications marked as read',
            'updated_count': updated_count
        })



class NotificationCountView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        user = request.user
        
        # User နှင့် is_read=False ဖြစ်သော Notification များကို ရေတွက်သည်
        unread_count = Notification.objects.filter(
            user=user, 
            is_read=False
        ).count()

        # JSON response တွင် 'unread_count' key ဖြင့် ပြန်ပေးသည်
        return Response({'unread_count': unread_count})


class AvailableSlotsView(APIView):
    """
    Batch တစ်ခုအတွက် Course ရဲ့ max_session_duration_minutes ကို အခြေခံပြီး 
    ရရှိနိုင်တဲ့ Session Slots များကို တွက်ချက်ပေးသည် (Conflict မရှိသော Sessions များကို ပြန်ပေးသည်)
    """
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # Query parameters များ ရယူခြင်း
        batch_id = request.query_params.get('batch_id')
        
        if not batch_id:
            return Response({"error": "batch_id is required."}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Course model မှာ max_session_duration_minutes ပါပြီးသားလို့ ယူဆပါတယ်
            batch = Batch.objects.select_related('course').get(id=batch_id)
            course = batch.course
        except Batch.DoesNotExist:
            return Response({"error": "Batch not found."}, status=status.HTTP_404_NOT_FOUND)

        session_duration = course.max_session_duration_minutes
        instructor_id = batch.instructor_id # type: ignore
        start_date = batch.start_date
        end_date = batch.end_date
        
        all_available_slots = []
        current_date = start_date

        # နေ့ရက်တစ်ခုချင်းစီကို စစ်ဆေးခြင်း
        while current_date <= end_date:
           
            day_start_time = datetime.combine(current_date, time(hour=9))
            day_end_time = datetime.combine(current_date, time(hour=17))
            
            current_slot_start = day_start_time

            while current_slot_start + timedelta(minutes=session_duration) <= day_end_time:
                current_slot_end = current_slot_start + timedelta(minutes=session_duration)
                
                
                is_booked = Session.objects.filter(
                    # batch=batch,
                    batch__instructor_id=instructor_id,
                    start_dt__lt=current_slot_end,
                    end_dt__gt=current_slot_start,
                    status__in=['booked', 'scheduled', 'completed']
                ).exists()

                if not is_booked:
                    all_available_slots.append({
                        "date": current_date,
                        "start_time": current_slot_start.time(),
                        "end_time": current_slot_end.time(),
                        "duration_minutes": session_duration,
                        "instructor_id": instructor_id,
                        "batch_id": batch_id
                    })
                
                current_slot_start = current_slot_end

            current_date += timedelta(days=1)

        serializer = AvailableSlotSerializer(all_available_slots, many=True)
        return Response(serializer.data)



def approve_booking_view(request, booking_id):
    booking = Booking.objects.get(id=booking_id)
    
    if booking.status != "approved":
        booking.status = "approved"
        booking.save()

        # 1. Database မှာ Notification ရေးသွင်းခြင်း
        Notification.objects.create(
            user=booking.student,
            title="သင်တန်း စာရင်းသွင်းမှု အတည်ပြုပြီး",
            body=f"သင်၏ {booking.course.title} သင်တန်းကို အောင်မြင်စွာ စာရင်းသွင်းပြီးပါပြီ။",
        )
        
        # 2. Device သို့ FCM ပို့ခြင်း
        send_fcm_notification(
            user=booking.student,
            title="အတည်ပြုပြီး",
            body=f"{booking.course.title} သင်တန်း စတင်တက်ရောက်နိုင်ပါပြီ။",
            data={"type": "booking_approved", "course_id": str(booking.course.id)} # Flutter တွင် ကိုင်တွယ်ရန် # type: ignore
        )



from rest_framework.decorators import api_view, permission_classes # type: ignore
from rest_framework.permissions import IsAdminUser # type: ignore
from rest_framework.response import Response # type: ignore
from .models import DeviceToken

@api_view(['POST'])
@permission_classes([IsAdminUser]) # Admin များသာ
def register_admin_device(request):
    token = request.data.get('token')
    platform = request.data.get('platform', 'web_admin')
    
    if token:
        DeviceToken.objects.update_or_create(
            user=request.user,
            token=token,
            defaults={'platform': platform}
        )
        return Response({"status": "success", "message": "Admin token saved"})
    return Response({"status": "error"}, status=400)



from django.http import HttpResponse
from django.conf import settings
import os

def firebase_messaging_sw(request):
    # Static file ထဲက js ကို ဖတ်ပြီး ပြန်ပေးမည်
    path = os.path.join(settings.STATIC_ROOT, 'firebase-messaging-sw.js')
    # Dev Mode မှာ staticfiles dirs ကို ရှာဖွေပါ
    if not os.path.exists(path):
        path = os.path.join(settings.BASE_DIR, 'static', 'firebase-messaging-sw.js')

    with open(path, 'r') as f:
        return HttpResponse(f.read(), content_type='application/javascript')




from django.http import JsonResponse
from django.contrib.admin.views.decorators import staff_member_required
from .models import Notification

@staff_member_required
def get_unread_notifications(request):
    unread_count = Notification.objects.filter(user=request.user, is_read=False).count()

    latest_notifs = Notification.objects.filter(user=request.user, is_read=False).order_by('-created_at')[:5]

    data = {
        "count": unread_count,
        "notifications": [
            {
                "title": n.title,
                "body": n.body[:40] + "...", # စာရှည်ရင် ဖြတ်မယ်
                "time": n.created_at.strftime("%H:%M"),
                "url": f"/admin/core/notification/{n.id}/change/" # နှိပ်ရင် Admin Detail ကိုသွားမယ် # type: ignore
            } for n in latest_notifs
        ]
    }
    return JsonResponse(data)