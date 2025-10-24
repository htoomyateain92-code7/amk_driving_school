from django.db.models.signals import post_save
from django.dispatch import receiver
from firebase_admin import messaging

from accounts.models import User
from .models import Booking, Notification, DeviceToken

def send_fcm_notification(user, title, body):
    tokens = list(DeviceToken.objects.filter(user=user).values_list("token", flat=True))
    if not tokens:
        print(f"No device tokens found for user {user.username}")
        return

    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={"type": "general_notification"}
    )
    try:
        response = messaging.send_multicast(message) # type: ignore
        print(f'Successfully sent message to {response.success_count} devices.')
    except Exception as e:
        print(f"Error sending FCM message: {e}")

@receiver(post_save, sender=Booking)
def create_enrollment_notification(sender, instance, created, **kwargs):

    # --- Case 1: ကျောင်းသားက သင်တန်းအသစ် စအပ်တဲ့အခါ ---
    if created:
        try:
            # အသိပေးရမယ့်သူတွေ (Admins, Owners) ကို အရင်ရှာပါ
            staff_to_notify = list(User.objects.filter(role__in=['owner', 'admin']))

            # သက်ဆိုင်ရာ instructor ကို ထပ်ပေါင်းထည့်ပါ
            instructor = instance.sessions.first().batch.instructor
            if instructor not in staff_to_notify:
                staff_to_notify.append(instructor)

            notification_title = "New Booking Request"
            notification_body = f"{instance.student.username} has requested to book sessions in '{instance.course.title}'."

            # Admin/Instructor တစ်ယောက်ချင်းစီဆီကို notification ပို့ပါ
            for staff_member in staff_to_notify:
                Notification.objects.create(
                    user=staff_member,
                    title=notification_title,
                    body=notification_body
                )
            print(f"Sent new booking notification to {len(staff_to_notify)} staff members.")

        except Exception as e:
            print(f"Error in new booking signal: {e}")

    # --- Case 2: Admin က သင်တန်းကို Approve လုပ်လိုက်တဲ့အခါ ---
    elif instance.status == 'approved':
        try:
            student = instance.student
            notification_title = "booking Approved!"
            notification_body = f"Congratulations! Your booking for '{instance.course.title}' has been approved."

            # ကျောင်းသားဆီကို Database notification ပို့ပါ
            Notification.objects.create(
                user=student,
                title=notification_title,
                body=notification_body
            )
            print(f"Sent 'Approved' notification to student {student.username}")

        except Exception as e:
            print(f"Error in booking approved signal: {e}")

    # --- Case 3: Admin က သင်တန်းကို Reject လုပ်လိုက်တဲ့အခါ ---
    elif instance.status == 'rejected':
        try:
            student = instance.student
            notification_title = "booking Update"
            notification_body = f"Unfortunately, your booking for '{instance.course.title}' has been rejected. Please contact us for more details."

            # ကျောင်းသားဆီကို Database notification ပို့ပါ
            Notification.objects.create(
                user=student,
                title=notification_title,
                body=notification_body
            )
            print(f"Sent 'Rejected' notification to student {student.username}")

        except Exception as e:
            print(f"Error in booking rejected signal: {e}")

@receiver(post_save, sender=Notification)
def send_push_notification_on_create(sender, instance, created, **kwargs):
    if created:
        send_fcm_notification(instance.user, instance.title, instance.body)