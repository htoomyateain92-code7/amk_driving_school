from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ArticleViewSet, CourseViewSet, BatchViewSet, QuizViewSet, SessionViewSet, PushViewSet, EnrollmentViewSet, SubmissionViewSet

r = DefaultRouter()
r.register("courses", CourseViewSet)
r.register("batches", BatchViewSet, basename="batches")
r.register("sessions", SessionViewSet, basename="sessions")
r.register("push/register-device", PushViewSet, basename="push")
r.register("enrollments", EnrollmentViewSet, basename="enrollments")
r.register("quizzes", QuizViewSet, basename="core_api_quizzes")
r.register("articles", ArticleViewSet, basename="core_api_articles")



urlpatterns = [
    path("api/", include(r.urls)),
    path("core/api/submissions/<int:pk>/answer/", SubmissionViewSet.as_view({"post":"answer"})),
    path("core/api/submissions/<int:pk>/finish/", SubmissionViewSet.as_view({"post":"finish"})),
]
