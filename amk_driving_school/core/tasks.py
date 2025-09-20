import datetime as dt, pytz
from django.utils import timezone
from celery import shared_task
from firebase_admin import messaging
from django.db.models import Q
from .models import Session, DeviceToken

YGN = pytz.timezone("Asia/Yangon")

def push(tokens, title, body, data=None):
    if not tokens: return
    messaging.send_multicast(messaging.MulticastMessage( # type: ignore
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={k:str(v) for k,v in (data or {}).items()}
    ))

@shared_task
def send_daily_teacher_digest():
    today = timezone.localdate()
    start = YGN.localize(dt.datetime.combine(today, dt.time(0,0)))
    end   = YGN.localize(dt.datetime.combine(today, dt.time(23,59,59)))
    teachers = (Session.objects.filter(start_dt__range=(start,end), status="scheduled")
                .values_list("batch__instructor", flat=True).distinct())

    for tid in teachers:
        todays = Session.objects.filter(batch__instructor_id=tid, start_dt__range=(start,end), status="scheduled").order_by("start_dt")
        items = [f"{s.start_dt.astimezone(YGN).strftime('%H:%M')} – {s.batch.course.title}" for s in todays]
        title = "ဒီနေ့ အတန်းအစီအစဉ်"
        body = "၊ ".join(items) if items else "ဒီနေ့ အတန်းမရှိပါ"
        tokens = list(DeviceToken.objects.filter(user_id=tid).values_list("token", flat=True))
        push(tokens, title, body, {"type":"digest","date":str(today)})

@shared_task
def send_session_reminders():
    now = timezone.now().astimezone(YGN)
    window = [now + dt.timedelta(minutes=30), now + dt.timedelta(hours=2)]
    due = Session.objects.filter(
        status="scheduled", start_dt__range=window
    ).select_related("batch","batch__course","batch__instructor")
    for s in due:
        # instructor + enrolled students
        tokens = list(DeviceToken.objects.filter(
            Q(user=s.batch.instructor) | Q(user__enrollment__batch=s.batch)
        ).values_list("token", flat=True).distinct())
        title = f"{s.batch.course.title}"
        body  = f"{s.start_dt.astimezone(YGN).strftime('%H:%M')} အချိန် အတန်းစမည်"
        push(tokens, title, body, {"type":"session.reminder","session_id":s.id}) # type: ignore
