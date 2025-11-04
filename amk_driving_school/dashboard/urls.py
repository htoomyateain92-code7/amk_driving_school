from django.urls import path
from .views import OwnerDashboardView

urlpatterns = [
    # /api/v1/owner-dashboard/ ကို ရည်ညွှန်းသည်
    path('owner-dashboard/', OwnerDashboardView.as_view(), name='owner-dashboard-data'),
]