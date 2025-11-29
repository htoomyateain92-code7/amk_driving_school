# dashboard/views.py (Data တွက်ချက်မှု)
from django.db.models import Count, Sum # တွက်ချက်ရန်အတွက်
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from core.models import Course, Booking, Session, Submission # သင်၏ Models များ
from .serializers import CourseSerializer, InstructorDashboardSerializer, OwnerDashboardSerializer, SessionCRUDSerializer, StudentDashboardSerializer # ယခင်က ရေးခဲ့သော Serializer
from rest_framework import viewsets
from rest_framework import viewsets, mixins, generics
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from core.models import Course, Quiz, Article, Notification
from .serializers import (
    CourseSerializer, QuizSerializer, ArticleSerializer, NotificationSerializer, 
    QuestionSerializer, OptionSerializer
)
from rest_framework.decorators import action
from rest_framework_simplejwt.authentication import JWTAuthentication

from .permissions import IsOwnerOrAdmin, IsInstructorOrAbove # 💡 New Imports
from rest_framework.permissions import IsAuthenticated # type: ignore



class OwnerDashboardView(APIView):
    authentication_classes = [JWTAuthentication] # type: ignore
    permission_classes = [IsAuthenticated, IsOwnerOrAdmin]


    def get(self, request, format=None):
        if not request.user.is_authenticated:
            return Response({"detail": "User not authenticated"}, status=401)
        today = timezone.now().date()
        current_month = today.month
        current_year = today.year

        # 1. ဖွင့်လှစ်ထားသည့် သင်တန်းအရေအတွက် (Active Courses)
        # is_public=True ဖြစ်သော Course များကို ရေတွက်သည်
        active_courses_count = Course.objects.filter(is_public=True).count()

        # 2. ကျောင်းသားသစ် ဦးရေ (New Students - ယခုလ Approved Booking များအဖြစ် ယူဆ)
        # Booking Model မှ Approved ဖြစ်ပြီး ယခုလအတွင်း ပြုလုပ်ထားသော Unique Students အရေအတွက်ကို ရေတွက်သည်
        new_students_count = Booking.objects.filter(
            status="approved",
            created_at__year=current_year,
            created_at__month=current_month
        ).aggregate(
            unique_students=Count('student', distinct=True)
        )['unique_students'] or 0

        # 3. စုစုပေါင်း ဝင်ငွေ (Total Revenue)
        # 💡 Revenue Model မရှိသောကြောင့် ယာယီ Hardcode ကို အသုံးပြုပါမည်
        total_revenue_value = 560000.00 # ယာယီတန်ဖိုး

        # 4. လစဉ်ဝင်ငွေ ဇယား (ယာယီ)
        # [TODO]: Monthly Revenue ကို Database မှ အမှန်တကယ် တွက်ချက်ရန်
        monthly_chart_data = [
            {'month': 'Jan', 'revenue': 450000},
            {'month': 'Feb', 'revenue': 520000},
            {'month': 'Mar', 'revenue': 560000},
        ]

        dashboard_data = {
            'total_revenue': total_revenue_value,
            'total_students': new_students_count,
            'active_courses': active_courses_count,
            'monthly_chart_data': monthly_chart_data
        }

        serializer = OwnerDashboardSerializer(dashboard_data)
        return Response(serializer.data)


class CourseCRUDViewSet(viewsets.ModelViewSet):
    """
    Course Model ၏ CRUD (Create, Retrieve, Update, Destroy) Operations များ
    Owner/Admin များသာ ဝင်ရောက်ခွင့် ရှိသည်
    """
    # 💡 core app မှ Course Model ကို Query လုပ်ခြင်း
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    # Security: Admin/Staff များသာ CRUD လုပ်နိုင်ရန် သေချာပါစေ
    permission_classes = [IsOwnerOrAdmin]

    # 💡 Listing အတွက် is_public ကို Filter လုပ်ရန် လိုအပ်ပါက
    filter_fields = ['is_public']



# --- 1. Quiz CRUD (Admin/Owner) ---
class QuizCRUDViewSet(viewsets.ModelViewSet):
    """ Admin များသာ Quiz များကို ဖန်တီး/ပြင်ဆင်/ဖျက်နိုင်သည် """
    queryset = Quiz.objects.filter(is_published=True).order_by('-id')
    serializer_class = QuizSerializer
    permission_classes = [IsAuthenticated, IsAdminUser] # Admin/Owner အတွက်

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

# --- 2. Quiz List/Detail (Student/Public) ---
class PublicQuizViewSet(viewsets.ReadOnlyModelViewSet):
    """ Student များအတွက် Published Quiz List ကို ပြပါမည် """
    queryset = Quiz.objects.filter(is_published=True).order_by('-id')
    serializer_class = QuizSerializer
    # 💡 Public ဖြစ်သောကြောင့် Login မလိုပါ
    permission_classes = []

# --- 3. Article/Blog CRUD (Admin/Owner) ---
class ArticleCRUDViewSet(viewsets.ModelViewSet):
    """ Admin များသာ Article များကို စီမံခန့်ခွဲနိုင်သည် """
    queryset = Article.objects.all().order_by('-created_at')
    serializer_class = ArticleSerializer
    permission_classes = [IsAuthenticated, IsAdminUser]

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)

# --- 4. Article/Blog List (Student/Public) ---
class PublicArticleViewSet(viewsets.ReadOnlyModelViewSet):
    """ Public အတွက် Published Article List ကို ပြပါမည် """
    queryset = Article.objects.filter(published=True).order_by('-created_at')
    serializer_class = ArticleSerializer
    permission_classes = [] # Public အတွက်

# --- 5. User Notifications (Authenticated Users) ---
class NotificationListViewSet(mixins.RetrieveModelMixin,
                                mixins.ListModelMixin,
                                viewsets.GenericViewSet):
    """ လက်ရှိ User ရဲ့ Notifications များကို ပြရန် """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # 💡 လက်ရှိ Login ဝင်ထားသော User ရဲ့ Notification များကိုသာ ပြပါမည်
        return Notification.objects.filter(user=self.request.user).order_by('-created_at')

    # Optional: Notification ကို ဖတ်ပြီးကြောင်း မှတ်သားရန် Endpoint
    @action(detail=True, methods=['patch'])
    def mark_read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'status': 'read'})



class InstructorDashboardView(APIView):
    """
    Instructor/Teacher အတွက် Dashboard Summary Data ကို ပြန်ပေးသော API
    """
    # 💡 Security: Login ဝင်ထားသော Instructor များသာ ဝင်ရောက်ခွင့်ရှိရန်
    permission_classes = [IsInstructorOrAbove]
    
    def get(self, request, format=None):
        user = request.user
        today = timezone.localdate() # ယနေ့ Date ကို ရယူပါ
        
        # 1. ယနေ့ အချိန်ဇယား (Today's Schedule)
        # Login ဝင်ထားသော Instructor ၏ Batch များနှင့် သက်ဆိုင်သည့် ယနေ့ Session များကို ရှာဖွေပါ
        today_sessions = Session.objects.filter(
            batch__instructor=user, # 💡 Instructor သည် လက်ရှိ User ဖြစ်ရမည်
            start_dt__date=today    # 💡 ယနေ့ Date ဖြစ်ရမည်
        ).select_related('batch__course').order_by('start_dt')
        
        # 2. စစ်ဆေးရန် ကျန်ရှိသော Quiz အရေအတွက် (Pending Submissions)
        # 💡 နည်းပြသည် မိမိသင်သော Course/Batch မှ Submission များကို စစ်ရမည်ဟု ယူဆသည်။
        # ယာယီအားဖြင့် finished_at = null ဖြစ်နေသော Submissions များကို ရေတွက်ပါမည်။
        pending_submissions_count = Submission.objects.filter(
            quiz__course__batches__instructor=user, # 💡 Quiz ၏ Course ကို သင်ပြသော Instructor
            finished_at__isnull=True                 # 💡 ပြီးဆုံးသော်လည်း အမှတ်မပေးရသေးဟု ယူဆပါ
        ).count()
        
        # 3. တိုင်ပင်ကြံဉာဏ် (ယာယီ Hardcode)
        pending_tips = 5 # (သင့် Project တွင် Tips Model ရှိမှသာ Query ဖြင့် အစားထိုးပါ)

        dashboard_data = {
            'today_schedule': today_sessions,
            'pending_submissions_count': pending_submissions_count,
            'pending_tips_count': pending_tips,
        }
        
        # Serializer ဖြင့် JSON ပြောင်းလဲခြင်း
        serializer = InstructorDashboardSerializer(dashboard_data)
        return Response(serializer.data)



class SessionCRUDViewSet(viewsets.ModelViewSet):
    """
    Instructor များ မိမိတို့၏ Batches များအတွက် Session များကို စီမံခန့်ခွဲရန်
    """
    serializer_class = SessionCRUDSerializer
    permission_classes = [IsInstructorOrAbove] # Login ဝင်ထားသူတိုင်း ဝင်ခွင့်ရှိပြီး Serializer တွင် Instructor ကို စစ်မည်
    
    def get_queryset(self):
        user = self.request.user
        # Admin ဆိုရင် အားလုံးပြ
        if user.is_staff:
            return Session.objects.all().select_related('batch')
        # Instructor ဆိုရင် မိမိ Batch ရဲ့ Session များကိုသာ ပြပါ
        return Session.objects.filter(batch__instructor=user).select_related('batch').order_by('start_dt')





class StudentDashboardView(APIView):
    """
    Student အတွက် Dashboard Summary Data ကို ပြန်ပေးသော API
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, format=None):
        user = request.user
        now = timezone.now()
        
        # 1. စာရင်းသွင်းထားသော Approved Booking များ (Enrolled Courses)
        approved_bookings = Booking.objects.filter(student=user, status="approved")
        enrolled_course_count = approved_bookings.count()
        
        # 2. Session Progress တွက်ချက်ခြင်း
        
        # ကျောင်းသား Booking များမှ ချိတ်ဆက်ထားသော Sessions များအားလုံး
        all_sessions_for_student = Session.objects.filter(
            booking__in=approved_bookings
        ).distinct()
        
        total_sessions = all_sessions_for_student.count()
        
        # ပြီးစီးသော Session များ (ယခုအချိန်ထက် နောက်ကျနေသော sessions)
        completed_sessions = all_sessions_for_student.filter(
            # end_dt__lte=now, 
            status="completed"
        ).count()
        
        # Progress တွက်ချက်ခြင်း
        progress_percentage = 0.0
        if total_sessions > 0:
            progress_percentage = (completed_sessions / total_sessions) * 100
            progress_percentage = round(progress_percentage, 1)

        # 3. လာမည့် Sessions များ (Upcoming Sessions)
        upcoming_sessions = all_sessions_for_student.filter(
            start_dt__gt=now,
            status__in=["scheduled", "available"] # ဒါမှမဟုတ် approved
        ).select_related('batch').order_by('start_dt')[:3] # လာမည့် ၃ ခုသာ ပြပါ
        
        # 4. နောက်ဆုံး Quiz Score
        last_quiz_score = Submission.objects.filter(
            student=user,
            finished_at__isnull=False
        ).order_by('-finished_at').values_list('score', flat=True).first()
        
        dashboard_data = {
            'enrolled_course_count': enrolled_course_count,
            'completed_sessions': completed_sessions,
            'total_sessions': total_sessions,
            'progress_percentage': progress_percentage,
            'upcoming_sessions': upcoming_sessions,
            'last_quiz_score': last_quiz_score,
        }
        
        serializer = StudentDashboardSerializer(dashboard_data)
        return Response(serializer.data)







