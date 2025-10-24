import datetime as dt, pytz
from django.db import transaction
from django.utils import timezone
from .models import Session, Batch
from django.db.models import Q
from .models import Session, Booking
from core import models
from django.db.models import Exists, OuterRef

YGN = pytz.timezone("Asia/Yangon")

def generate_sessions(*, batch: Batch, weekdays: list[int], start_time: str, duration_min: int, since: dt.date, until: dt.date):
    # validation: 60min×3days or 90min×2days only
    if duration_min not in (60, 90): raise ValueError("duration must be 60 or 90")
    if duration_min == 60 and len(weekdays) != 3: raise ValueError("60min requires 3 weekdays")
    if duration_min == 90 and len(weekdays) != 2: raise ValueError("90min requires 2 weekdays")

    hh, mm = map(int, start_time.split(":"))
    cursor = since
    created = []

    with transaction.atomic():
        # optional: delete existing within range
        Session.objects.filter(batch=batch, start_dt__date__range=(since, until)).delete()

        while cursor <= until:
            if cursor.weekday() in weekdays:
                start = YGN.localize(dt.datetime(cursor.year, cursor.month, cursor.day, hh, mm))
                end   = start + dt.timedelta(minutes=duration_min)
                # conflict: same instructor same time?
                clash = Session.objects.filter(
                    batch__instructor=batch.instructor,
                    start_dt__lt=end, end_dt__gt=start, status="scheduled"
                ).exists()
                if not clash:
                    created.append(Session(batch=batch, start_dt=start, end_dt=end))
            cursor += dt.timedelta(days=1)

        Session.objects.bulk_create(created, batch_size=200)
    return len(created)



# def has_student_time_clash(*, user, target_batch) -> bool:
#     # student joined batches (excluding the one we’re trying)
#     joined_batch_ids = (Booking.objects
#         .filter(user=user, status="active")
#         .exclude(batch=target_batch)
#         .values_list("batch_id", flat=True))

#     if not joined_batch_ids:
#         return False

#     # all sessions of joined batches
#     existing = Session.objects.filter(
#         batch_id__in=joined_batch_ids, status="scheduled"
#     ).values("start_dt","end_dt")

#     # sessions of target batch
#     targets = Session.objects.filter(
#         batch=target_batch, status="scheduled"
#     ).values("start_dt","end_dt")

#     # efficient overlap test (ORM)
#     return Session.objects.filter(
#         batch_id__in=joined_batch_ids, status="scheduled"
#     ).filter(
#         # Overlap with ANY target session
#         # target.start < existing.end AND target.end > existing.start
#         # Use subqueries via OR across target sessions
#         # Simpler way: for each target range, check exists
#         Q(start_dt__lt=models.Subquery( # type: ignore
#             Session.objects.filter(batch=target_batch, status="scheduled")
#             .values("end_dt")[:1]
#         )) &
#         Q(end_dt__gt=models.Subquery( # type: ignore
#             Session.objects.filter(batch=target_batch, status="scheduled")
#             .values("start_dt")[:1]
#         ))
#     ).exists()


def has_student_time_clash(*, user, target_batch) -> bool:
    # 1. Student joined batches (excluding the one we’re trying)
    joined_batch_ids = (Booking.objects
        .filter(user=user, status="active")
        .exclude(batch=target_batch)
        .values_list("batch_id", flat=True))

    if not joined_batch_ids:
        return False

    # 2. Get all existing sessions
    existing_sessions = Session.objects.filter(
        batch_id__in=joined_batch_ids, status="scheduled"
    )

    # 3. Define the overlap condition using a Subquery (referencing the outer query)
    # ဒီ Subquery က 'existing_sessions' တစ်ခုချင်းစီအတွက် အလုပ်လုပ်ပါမယ်။
    overlap_condition = Session.objects.filter(
        batch=target_batch, status="scheduled",
        
        # target.start < existing.end (OuterRef 'end_dt' က existing_session ကို ရည်ညွှန်း)
        start_dt__lt=OuterRef('end_dt'), 
        
        # target.end > existing.start (OuterRef 'start_dt' က existing_session ကို ရည်ညွှန်း)
        end_dt__gt=OuterRef('start_dt')
    )

    # 4. Check if any existing session has an overlapping target session
    # 'existing_sessions' တွေထဲက 'overlap_condition' နဲ့ ကိုက်ညီတဲ့ 
    # 'target_session' တစ်ခုခု (Exists) ရှိနေသလား စစ်ပါ။
    return existing_sessions.filter(
        Exists(overlap_condition)
    ).exists()