from rest_framework.routers import DefaultRouter

# သင့် app တွေထဲက ViewSet အားလုံးကို import လုပ်ပါ
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
    SubmissionViewSet
    # Device-registration အတွက် view ကိုလည်း import လုပ်ပါ
    # from .views import PushViewSet
)

# Router instance တစ်ခုတည်ဆောက်ပါ
router = DefaultRouter()

# ViewSet အားလုံးကို ဒီ router မှာ register လုပ်ပါ
router.register(r'courses', CourseViewSet)
router.register(r'batches', BatchViewSet)
router.register(r'sessions', SessionViewSet)
router.register(r'bookings', BookingViewSet)
router.register(r'quizzes', QuizViewSet)
router.register(r'articles', ArticleViewSet)
router.register(r'submissions', SubmissionViewSet, basename='submission')
router.register(r'device-registration', PushViewSet, basename='device-registration')
router.register(r'notifications', NotificationViewSet, basename='notifications')

# AccountViewSet ကို ဒီမှာထည့်သွင်း register လုပ်ပါ (အရေးကြီးဆုံး)
router.register(r'accounts', AccountViewSet, basename='accounts')

# router က generate လုပ်ထားတဲ့ URL တွေကို တိုက်ရိုက် export လုပ်ပါ
# path() နဲ့ ပြန်မပတ်ပါနဲ့
urlpatterns = router.urls