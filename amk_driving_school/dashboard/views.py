from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .serializers import OwnerDashboardSerializer

class OwnerDashboardView(APIView):
    """
    Owner/Admin အတွက် Dashboard Summary Data ကို ပြန်ပေးသော API
    """
    # 💡 Security: ဤနေရာတွင် Owner/Admin User များသာ ဝင်ရောက်ခွင့်ရှိရန် သတ်မှတ်ပါ
    permission_classes = [IsAuthenticated, IsAdminUser] 
    
    def get(self, request, format=None):
        # [TODO]: ဤနေရာတွင် Database မှ အမှန်တကယ် Data များကို တွက်ချက်ရပါမည်။
        
        # ယာယီ Data တွက်ချက်မှု (Hardcoded for testing)
        dashboard_data = {
            'total_revenue': 560000.00,  # ယခုလ ဝင်ငွေ
            'total_students': 32,         # ကျောင်းသားသစ်
            'active_courses': 5,         # ဖွင့်ထားသော သင်တန်း
            'monthly_chart_data': [
                {'month': 'Jan', 'revenue': 450000},
                {'month': 'Feb', 'revenue': 520000},
                {'month': 'Mar', 'revenue': 560000},
            ]
        }
        
        # Serializer ဖြင့် JSON ပြောင်းလဲခြင်း
        serializer = OwnerDashboardSerializer(dashboard_data)
        
        # Response ပြန်ပေးခြင်း
        return Response(serializer.data)