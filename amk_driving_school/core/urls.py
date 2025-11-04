from django.urls import path, include # type: ignore
from rest_framework.routers import DefaultRouter # type: ignore

# သင့် app တွေထဲက ViewSet အားလုံးကို import လုပ်ပါ
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
    AvailableSlotsView
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


urlpatterns = [
    # Router URLs များကို ထည့်သွင်းခြင်း
    path('', include(router.urls)),
    # ✅ AvailableSlotsView ကို path() ကိုသုံးပြီး သီးသန့် လမ်းကြောင်း သတ်မှတ်ခြင်း
    # ဤအရာသည် APIView ကို router တွင် register လုပ်ခြင်းကို ရှောင်ရှားရန် မှန်ကန်သောနည်းလမ်းဖြစ်သည်
    path('available-slots/', AvailableSlotsView.as_view(), name='available-slots'),
]


