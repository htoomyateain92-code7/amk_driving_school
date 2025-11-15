from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    InstructorDashboardView, OwnerDashboardView, CourseCRUDViewSet, QuizCRUDViewSet, PublicQuizViewSet, 
    ArticleCRUDViewSet, PublicArticleViewSet, NotificationListViewSet, SessionCRUDViewSet, StudentDashboardView
)

router = DefaultRouter()

# --- Admin/Owner CRUD Endpoints ---
router.register(r'courses', CourseCRUDViewSet)          # /api/v1/courses/
router.register(r'admin/quizzes', QuizCRUDViewSet, basename='admin-quiz') # /api/v1/admin/quizzes/
router.register(r'admin/articles', ArticleCRUDViewSet, basename='admin-article') # /api/v1/admin/articles/

# --- Public/Student Endpoints ---
router.register(r'public/quizzes', PublicQuizViewSet, basename='public-quiz')   # /api/v1/public/quizzes/
router.register(r'public/articles', PublicArticleViewSet, basename='public-article') # /api/v1/public/articles/

# --- Authenticated User Endpoints ---
router.register(r'notifications', NotificationListViewSet, basename='notifications') # /api/v1/notifications/

router.register(r'sessions', SessionCRUDViewSet, basename='session')

urlpatterns = [
    path('owner-dashboard/', OwnerDashboardView.as_view(), name='owner-dashboard-data'),

    path('instructor-dashboard/', InstructorDashboardView.as_view(), name='instructor-dashboard-data'),

    path('student-dashboard/', StudentDashboardView.as_view(), name='student-dashboard-data'),
    # 💡 Router URLs များကို ထည့်သွင်းခြင်း
    path('', include(router.urls)),
]