# core/signals.py
from firebase_admin import messaging as firebase_messaging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db import transaction # Transaction ကို ထိန်းချုပ်ရန်
from accounts.models import User
from .models import Booking, Notification
from .utils import notify_all_admins, send_fcm_notification

# -------------------------------------------------------------------
# 1. Database Notification Save လုပ်သည်နှင့် FCM ကို ချက်ချင်းပို့ရန် Signal
# -------------------------------------------------------------------

@receiver(post_save, sender=Notification)
def send_push_notification_on_create(sender, instance, created, **kwargs):
    """ Notification Model တွင် Data အသစ် Save လုပ်သည်နှင့် FCM ကို ပို့ပါမည်။ """
    if created:
        # Push Sending ကို Transaction ပြီးဆုံးမှသာ လုပ်ရန် on_commit ကို သုံးပါ
        def on_notification_commit():
             send_fcm_notification(instance.user, instance.title, instance.body, data={"type": "general"})
             
        transaction.on_commit(on_notification_commit)


# -------------------------------------------------------------------
# 2. Booking Model Events (Created, Approved, Rejected)
# -------------------------------------------------------------------

@receiver(post_save, sender=Booking)
def create_booking_notifications(sender, instance, created, **kwargs):
    
    # --- Function ဖြင့် encapsulation လုပ်ပါ (Transaction ပြီးမှ ခေါ်ရန်) ---
    def process_booking_notifications():
        
        # Case 1: ကျောင်းသားက သင်တန်းအသစ် စအပ်တဲ့အခါ (Owner/Admin/Instructor ကို အကြောင်းကြား)
        if created:
            try:
                staff_to_notify = list(User.objects.filter(role__in=['owner', 'admin']))
                
                
                course_title = instance.course.title if instance.course else "Unknown Course"
                
                
                instructor_ids = instance.course.batches.filter(instructor__isnull=False).values_list('instructor', flat=True).distinct()
                
                for instructor_id in instructor_ids:
                    instructor = User.objects.get(pk=instructor_id)
                    if instructor not in staff_to_notify:
                         staff_to_notify.append(instructor)

                notification_title = "New Booking Request"
                notification_body = f"{instance.student.username} has requested to book sessions in '{course_title}'."

                
                for staff_member in staff_to_notify:
                    Notification.objects.create(
                        user=staff_member,
                        title=notification_title,
                        body=notification_body,
                        payload={"type": "new_booking", "booking_id": str(instance.pk)}
                    )
                print(f"Signal: Sent new booking notification to {len(staff_to_notify)} staff members.")

            except Exception as e:
                print(f"Error in new booking signal: {e}")


        # Case 2: Admin က သင်တန်းကို Approve လုပ်လိုက်တဲ့အခါ (Student ကို အကြောင်းကြား)
        elif instance.status == 'approved':
            try:
                student = instance.student
                notification_title = "Booking Approved!"
                notification_body = f"Congratulations! Your booking for '{instance.course.title}' has been approved."

                Notification.objects.create(
                    user=student,
                    title=notification_title,
                    body=notification_body,
                    payload={"type": "booking_approved", "booking_id": str(instance.pk)},
                    
                )
                print(f"Signal: Sent 'Approved' notification to student {student.username}")

            except Exception as e:
                print(f"Error in booking approved signal: {e}")

        # Case 3: Admin က သင်တန်းကို Reject လုပ်လိုက်တဲ့အခါ (Student ကို အကြောင်းကြား)
        elif instance.status == 'rejected':
            try:
                student = instance.student
                notification_title = "Booking Update"
                notification_body = f"Unfortunately, your booking for '{instance.course.title}' has been rejected. Please contact us for more details."

                Notification.objects.create(
                    user=student,
                    title=notification_title,
                    body=notification_body,
                    payload={"type": "booking_rejected", "booking_id": str(instance.pk)}
                )
                print(f"Signal: Sent 'Rejected' notification to student {student.username}")

            except Exception as e:
                print(f"Error in booking rejected signal: {e}")


    # Booking save operation သည် Database တွင် အောင်မြင်စွာ ပြီးဆုံးမှသာ Notification Logic ကို ခေါ်ပါ
    transaction.on_commit(process_booking_notifications)


@receiver(post_save, sender=Booking)
def alert_admin_on_new_booking(sender, instance, created, **kwargs):
    if created:
        notify_all_admins(
            title="New Booking Alert!",
            body=f"Student {instance.student.username} booked {instance.course.code}.",
            data={"booking_id": str(instance.id)}
        )