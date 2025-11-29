# core/utils.py

from firebase_admin import messaging as firebase_messaging
from .models import Notification, DeviceToken
from django.conf import settings
from firebase_admin.exceptions import FirebaseError

def send_fcm_notification(user, title, body, data=None):
    """
    သတ်မှတ်ထားသော User ၏ Device Token များအားလုံးသို့ FCM Notification ပို့ပေးခြင်း။
    (Failure ဖြစ်သော Inactive Tokens များကို Database မှ ဖယ်ရှားပေးပါသည်။)
    """
    
    # 1. Database မှ User ၏ Active Device Tokens များကို ရှာဖွေပါ
    # [Note]: FCM Tokens တွေဟာ CharField/String ဖြစ်လို့ .values_list('token', flat=True) က မှန်ကန်ပါတယ်။
    tokens = list(DeviceToken.objects.filter(user=user).values_list('token', flat=True))
    
    if not tokens:
        print(f"INFO: No active tokens found for user: {user.username}")
        return False
    
    # 2. FCM Message ကို တည်ဆောက်ပါ
    message = firebase_messaging.MulticastMessage(
        notification=firebase_messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {}, 
        tokens=tokens,
    )
    
    # 3. FCM သို့ ပေးပို့ပြီး Inactive Tokens များကို ဖယ်ရှားပါ
    try:
        response = firebase_messaging.send_multicast(message) # type: ignore # response.responses သည် list of SendResponse ဖြစ်သည်။
        
        # 4. Failure Result ကို စစ်ဆေးပြီး Token များကို Clean Up လုပ်ပါ
        if response.failure_count > 0:
            failed_tokens = []
            
            for idx, resp in enumerate(response.responses):
                if not resp.success:
                    # Token မှားယွင်းခြင်း၊ Token မရှိတော့ခြင်း တို့ကို စစ်ဆေးသည်
                    # error.code == 'not-registered' ဆိုရင် အဲဒီ Token ကို ဖျက်ဖို့ လိုအပ်ပါတယ်။
                    error_code = resp.exception.code if resp.exception else None
                    
                    if error_code in ['messaging/invalid-argument', 'messaging/not-registered']:
                        # Firebase က ဒီ Token ကို အလုပ်မလုပ်တော့ဘူးလို့ ပြန်ပြောပြီ
                        failed_tokens.append(tokens[idx])
                        
            if failed_tokens:
                # Inactive ဖြစ်သွားသော Tokens များကို Database မှ ဖယ်ရှားခြင်း
                deleted_count, _ = DeviceToken.objects.filter(token__in=failed_tokens).delete()
                print(f"INFO: Cleaned up {deleted_count} inactive tokens for user {user.username}.")
            
            print(f"WARNING: FCM failed to send {response.failure_count} messages for user {user.username}.")
            
        print(f"SUCCESS: FCM notification sent to {response.success_count} devices for user {user.username}.")
        return True
        
    except FirebaseError as e:
        # Firebase Server နဲ့ ချိတ်ဆက်ရာတွင် ပြဿနာတက်ခြင်း (e.g., Auth/Network)
        print(f"FATAL ERROR: FCM sending failed due to Firebase Error: {e.code} - {e.message}") # type: ignore
        return False
    except Exception as e:
        # အခြားမမျှော်လင့်ထားသော Error များ
        print(f"FATAL ERROR: FCM sending failed due to an unexpected exception: {e}")
        return False

# from accounts.models import User
from .models import DeviceToken
from django.contrib.auth import get_user_model
from firebase_admin import messaging as firebase_messaging

def notify_all_admins(title, body, data=None):
    # Admin (is_staff=True) များ၏ Web Token များကို ရှာပါ
    admin_tokens = DeviceToken.objects.filter(
        user__is_staff=True
        # platform='web_admin'
    ).values_list('token', flat=True)
    
    if not admin_tokens:
        return

    message = firebase_messaging.MulticastMessage(
        notification=firebase_messaging.Notification(title=title, body=body),
        data=data or {},
        tokens=list(admin_tokens),
    )
    try:
        response = firebase_messaging.send_multicast(message)
        print(f"Admin Notification sent: {response.success_count} success.")
    except Exception as e:
        print(f"Error sending admin notification: {e}")