# core/views.py
from datetime import date
from django.utils import timezone
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiExample
from .models import Article, Booking, Course, Batch, Quiz, Session, DeviceToken,  Submission
from .serializers import (
    ArticleSer, BatchDetailSerializer, BatchSerializer, BookingCreateSerializer, BookingListDetailSerializer,
    CourseDetailSerializer, CourseListSerializer, NotificationSerializer, QuestionPublicSer, QuizDetailSer,
    SessionSer, DeviceTokenSer, SubmissionSer)
from .services import generate_sessions
from django.db.models import Q, Exists, OuterRef, Subquery

# Swagger/Redoc (drf-spectacular)
from drf_spectacular.utils import extend_schema, extend_schema_view
from firebase_admin import messaging

from django.shortcuts import get_object_or_404

from core import serializers

from accounts.models import User, InstructorAvailability
from rest_framework.views import APIView # Custom Logic ရေးသားရန်
from datetime import datetime, timedelta, time # Time တွက်ချက်မှုများအတွက်
from .serializers import AvailableSlotSerializer

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
    queryset = Course.objects.all().order_by("title")
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
        DeviceToken.objects.update_or_create(
            user=request.user,
            token=ser.validated_data["token"],  # type: ignore
            defaults={"platform": ser.validated_data.get("platform", "android")},  # type: ignore
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
            return BookingCreateSerializer
        return BookingListDetailSerializer

    def get_queryset(self):
        # user က instructor/admin ဆိုရင် booking အားလုံးကိုပြ၊ student ဆိုရင် ကိုယ့်ဟာကိုယ်ပဲပြ
        if self.request.user.is_staff:
            return Booking.objects.all()
        return Booking.objects.filter(student=self.request.user)

    def perform_create(self, serializer):
        # Booking အသစ်လုပ်ရင် student ကို auto သတ်မှတ်
        booking_instance = serializer.save(student=self.request.user, status='pending')

        # Sessions Status ကို 'booked' အဖြစ် ပြောင်းလဲခြင်း
        sessions_to_update = serializer.validated_data.get('sessions')
        session_ids = [s.id for s in sessions_to_update]

        # Sessions များကို bulk update လုပ်ခြင်း
        Session.objects.filter(id__in=session_ids).update(status='booked')

        # Note: Approved လုပ်တဲ့ action ထဲမှာတော့ 'booked' ကို 'approved' ဖြစ်မှ update လုပ်တာ ပိုကောင်းပါတယ်
        # အခုကတော့ စာရင်းသွင်းပြီးတာနဲ့ ချက်ချင်း 'booked' အဖြစ် သတ်မှတ်လိုက်ပါတယ်။

        return booking_instance

    @action(detail=True, methods=['post'], permission_classes=[IsInstructorOrAdmin]) # Permission check ထည့်လိုက်သည်
    def approve(self, request, pk=None):
        booking = self.get_object()
        
        # Approved လုပ်လိုက်ရင် Booking ရဲ့ Status ကို 'approved' ပြောင်းပါ
        booking.status = 'approved'
        booking.save()

        # Sessions status ကို 'booked' (သို့မဟုတ် 'scheduled' ကို ပြန်ပြောင်းခြင်း)
        # လက်ရှိ logic အရ 'booked' ကို ပြောင်းပြီးသားဖြစ်လို့ ဒီနေရာမှာ ထပ် update လုပ်စရာမလိုပါဘူး။
        # သို့သော် Sessions များကိုလည်း status="scheduled" သို့ ပြောင်းပေးနိုင်သည် (သင့် business logic အပေါ် မူတည်သည်)
        # ဥပမာ- booking.sessions.all().update(status='scheduled')
        
        return Response({'status': 'booking approved'})

    @action(detail=True, methods=['post'], permission_classes=[IsInstructorOrAdmin]) # Permission check ထည့်လိုက်သည်
    def reject(self, request, pk=None):
        booking = self.get_object()
        booking.status = 'rejected'
        booking.save()
        
        # Reject လုပ်ရင် Sessions တွေကို 'available' (scheduled) အဖြစ် ပြန်ပြောင်းပါ
        booking.sessions.all().update(status='available')
        
        return Response({'status': 'booking rejected'})



# class EnrollmentViewSet(viewsets.ModelViewSet):
#     queryset = Enrollment.objects.all()
#     permission_classes = [permissions.IsAuthenticated]
#     serializer_class = EnrollmentCreateSer

#     def get_queryset(self):
#         """
#         Students can only see their own enrollments.
#         Staff can see all enrollments.
#         """
#         user = self.request.user
#         if user.is_staff:
#             return Enrollment.objects.select_related('batch', 'user').all()
#         return Enrollment.objects.select_related('batch').filter(user=user)

#     def perform_create(self, serializer):
#         """
#         Automatically assign the current user to the enrollment
#         and prevent duplicate enrollments.
#         """
#         batch = serializer.validated_data.get('batch')
#         user = self.request.user

#         # user က ဒီ batch ကို enroll လုပ်ပြီးသားလား အရင်စစ်ဆေးပါ
#         if Enrollment.objects.filter(user=user, batch=batch).exists():
#             # လုပ်ပြီးသားဆိုရင် error message ပြန်ပေးပါ
#             raise serializers.ValidationError("You are already enrolled in this batch.") # type: ignore

#         # enroll မလုပ်ရသေးမှ user ကို သတ်မှတ်ပြီး save ပါ
#         serializer.save(user=user)


#     @action(detail=False, methods=['get'], url_path='my-enrollments')
#     def my_enrollments(self, request):
#         """Return a list of batches the current user is enrolled in."""
#         user = request.user
#         # status='active' အစား 'approved' ကိုပြောင်းပါ
#         enrollments = Enrollment.objects.filter(user=user, status='approved')
#         batches = [e.batch for e in enrollments]
#         serializer = BatchSerializer(batches, many=True)
#         return Response(serializer.data)











class QuizViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Quiz.objects.filter(is_published=True)
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
        return Response({"submission_id": sub.id})


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
            opt = get_object_or_404(Option, id=opt_id, question=q)
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
    """
    A viewset for viewing notifications for the current user.
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """
        This view should return a list of all the notifications
        for the currently authenticated user.
        """
        return self.request.user.notifications.all() # type: ignore

    @action(detail=True, methods=['post'], url_path='mark-as-read')
    def mark_as_read(self, request, pk=None):
        notification = self.get_object()
        if notification.user == request.user:
            notification.is_read = True
            notification.save()
            return Response({'status': 'notification marked as read'})
        return Response(status=status.HTTP_403_FORBIDDEN)




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
            # TODO: ဤနေရာတွင် InstructorAvailability Model ကို အသုံးပြုနိုင်သည်
            # (သို့သော် လက်ရှိ models.py တွင် မပါဝင်သေးသောကြောင့် Fixed Time ယူဆပါမည်)
            
            # Fixed Time Window: နံနက် ၉:၀၀ မှ ညနေ ၅:၀၀
            # Note: timezone-aware ဖြစ်စေရန် settings.py ကို စစ်ဆေးပါ
            day_start_time = datetime.combine(current_date, time(hour=9))
            day_end_time = datetime.combine(current_date, time(hour=17))
            
            current_slot_start = day_start_time

            while current_slot_start + timedelta(minutes=session_duration) <= day_end_time:
                current_slot_end = current_slot_start + timedelta(minutes=session_duration)
                
                # Conflict စစ်ဆေးခြင်း: ဤ Batch အတွင်းရှိ sessions များ သို့မဟုတ် အခြား Batch များမှ 
                # (batch_id ကိုသာ စစ်ပါမည်၊ instructor တစ်ဦးတည်းရဲ့ sessions များစွာကို စစ်လိုပါက logic ကို ပြင်ရပါမည်)
                is_booked = Session.objects.filter(
                    batch=batch, # ဤ Batch အတွက်သာ စစ်ဆေးခြင်း
                    start_dt__lt=current_slot_end,
                    end_dt__gt=current_slot_start,
                    status__in=['booked', 'completed']
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