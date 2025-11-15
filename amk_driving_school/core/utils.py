# core/utils.py

from firebase_admin import messaging
from core.models import Notification, DeviceToken
from django.conf import settings

def send_fcm_notification(user, title, body, data=None):
    """
    သတ်မှတ်ထားသော User ၏ Device Token များအားလုံးသို့ FCM Notification ပို့ပေးခြင်း
    """
    
    # 1. Database မှ User ၏ Active Device Tokens များကို ရှာဖွေပါ
    # user.notifications.create(title=title, body=body) ကို Notification Logic က လုပ်ပြီးပါပြီ
    tokens = DeviceToken.objects.filter(user=user).values_list('token', flat=True)
    
    if not tokens:
        print(f"No active tokens found for user: {user.username}")
        return False
    
    # 2. FCM Message ကို တည်ဆောက်ပါ
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {}, # Custom data (e.g., booking_id, course_id)
        tokens=list(tokens),
    )
    
    # 3. FCM သို့ ပေးပို့ပါ
    try:
        response = messaging.send_multicast(message) # type: ignore
        
        # 4. Success / Failure Result ကို စစ်ဆေးပါ
        if response.failure_count > 0:
            print(f"FCM Errors for user {user.username}: {response.failure_count} failures.")
            # 💡 Failure ဖြစ်သွားသော Tokens များကို Database မှ ဖယ်ရှားရန် Logic ထပ်ထည့်နိုင်ပါသည်။
        
        print(f"FCM notification sent successfully to {response.success_count} devices for user {user.username}.")
        return True
        
    except Exception as e:
        print(f"FCM sending failed due to an exception: {e}")
        return False