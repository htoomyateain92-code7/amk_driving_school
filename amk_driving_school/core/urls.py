from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views
# Views များကို စနစ်တကျ import လုပ်ခြင်း
from accounts.views import AccountViewSet 
from .views import ( 
    ArticleViewSet,
    CourseViewSet,
    BatchViewSet,
    NotificationViewSet,
    PushViewSet,
    QuizViewSet,
    SessionViewSet,
    BookingViewSet,
    SubmissionViewSet,
    AvailableSlotsView,
    firebase_messaging_sw,
    get_unread_notifications,
    register_admin_device,
    NotificationCountView 
)


router = DefaultRouter()


router.register(r'courses', CourseViewSet)
router.register(r'batches', BatchViewSet)
router.register(r'sessions', SessionViewSet)
router.register(r'bookings', BookingViewSet)
router.register(r'quizzes', QuizViewSet)
router.register(r'articles', ArticleViewSet)
router.register(r'submissions', SubmissionViewSet, basename='submission')
router.register(r'device-registration', PushViewSet, basename='device-registration')
router.register(r'notifications', NotificationViewSet, basename='notifications')
router.register(r'accounts', AccountViewSet, basename='accounts')



custom_urlpatterns = [
    
    path('notifications/unread_count/', NotificationCountView.as_view(), name='notification-unread-count'),
    
    
    path('notifications/mark-all-as-read/', 
         NotificationViewSet.as_view({'post': 'mark_all_as_read'}), 
         name='notification-mark-all-as-read'),

    
    path('notifications/<int:pk>/mark-as-read/', 
         NotificationViewSet.as_view({'post': 'mark_as_read'}), 
         name='notification-mark-as-read'),
         
    
    path('available-slots/', AvailableSlotsView.as_view(), name='available-slots'),
    path('api/devices/register_admin/', register_admin_device),
    path('firebase-messaging-sw.js', firebase_messaging_sw),
    path('admin/notifications/', get_unread_notifications, name='admin_notif_api'),
]



urlpatterns = custom_urlpatterns + [
    
    path('', include(router.urls)),
]