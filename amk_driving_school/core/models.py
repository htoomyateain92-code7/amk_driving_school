from django.utils import timezone
from django.conf import settings
from django.db import models
from django.db.models import Q, Exists, OuterRef
from math import ceil




class Course(models.Model):
    title = models.CharField(max_length=150)
    code  = models.CharField(max_length=30, unique=True)
    description = models.TextField(blank=True)
    # စုစုပေါင်းကြာချိန် (နာရီဖြင့်)
    total_duration_hours = models.DecimalField(max_digits=4, decimal_places=2, default=3.0)  # type: ignore
    # တစ်ရက်တည်း သင်နိုင်သည့် အများဆုံး မိနစ် (သင်တန်းသားဘက်မှ ရွေးမည့် Session တစ်ခု၏ ကြာချိန်)
    max_session_duration_minutes = models.PositiveIntegerField(
        default=60,
        help_text="တစ်ကြိမ်သင်တန်းအတွက် အများဆုံး ကြာချိန် (မိနစ်ဖြင့်)"
    )
    duration_day = models.IntegerField(default=3, verbose_name=("သင်တန်းကြာမြင့်ချိန် (ရက်)"),
        help_text=("သင်တန်းတစ်ခုလုံးကြာမြင့်မည့် ရက်အရေအတွက် (ဥပမာ: 3 ရက်)"))
    price = models.CharField(max_length=100)
    is_public = models.BooleanField(default=True)

    @property
    def total_duration_minutes(self):
        """စုစုပေါင်းကြာချိန်ကို မိနစ်ဖြင့် ပြန်ပေးခြင်း"""
        return int(self.total_duration_hours * 60)

    @property
    def required_sessions(self):
        """သင်တန်းပြီးရန် လိုအပ်သည့် Session အရေအတွက် တွက်ချက်ခြင်း"""
        total_min = self.total_duration_minutes
        max_session_min = self.max_session_duration_minutes
        if total_min > 0 and max_session_min > 0:
            # 180 / 90 = 2.0 -> 2 Sessions. 180 / 60 = 3.0 -> 3 Sessions.
            return ceil(total_min / max_session_min)
        return 0

    def __str__(self): return self.title

class Batch(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="batches")
    title  = models.CharField(max_length=150)
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="teaching_batches")
    start_date = models.DateField()
    end_date   = models.DateField()

class Session(models.Model):
    SESSION_STATUS = (("available", "Available"), ("booked", "Booked"), ("completed","Completed"), ("canceled","Canceled"))
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE, related_name="sessions")
    start_dt = models.DateTimeField(db_index=True)
    end_dt   = models.DateTimeField()
    status = models.CharField(max_length=12, choices=SESSION_STATUS, default="available")
    reason   = models.CharField(max_length=200, blank=True)

    class Meta:
        indexes = [
        models.Index(fields=["start_dt", "end_dt", "status"]),
        models.Index(fields=["batch", "start_dt"]),
    ]


class Booking(models.Model):
    STATUS_CHOICES = (("pending", "Pending"), ("approved", "Approved"), ("rejected", "Rejected"))

    student = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="bookings")
    course = models.ForeignKey(Course, on_delete=models.CASCADE)

    # ကျောင်းသားက ရွေးချယ်လိုက်တဲ့ session တွေအားလုံး
    sessions = models.ManyToManyField(Session)

    status = models.CharField(max_length=12, choices=STATUS_CHOICES, default="pending")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Booking for {self.student.username} in {self.course.title}"

# class Enrollment(models.Model):
#     STATUS_CHOICES = (
#         ("pending", "Pending"),
#         ("approved", "Approved"),
#         ("rejected", "Rejected"),
#     )
#     user  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
#     batch = models.ForeignKey(Batch, on_delete=models.CASCADE)
#     status = models.CharField(max_length=12, choices=STATUS_CHOICES, default="pending")
#     class Meta:
#         unique_together = ("user","batch")

class DeviceToken(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    token = models.CharField(max_length=512, unique=True)
    platform = models.CharField(max_length=16, default="android")
    updated_at = models.DateTimeField(auto_now=True)



class Quiz(models.Model):
    title = models.CharField(max_length=120)
    course = models.ForeignKey('core.Course', null=True, blank=True, on_delete=models.SET_NULL, related_name='quizzes')
    time_limit_sec = models.PositiveIntegerField(default=0)  # 0 = no limit
    is_published = models.BooleanField(default=True)

    def __str__(self): return self.title

class Question(models.Model):
    QTYPE = (("MCQ","MCQ"), ("ORDER","ORDER"))
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE, related_name='questions')
    text = models.TextField()
    qtype = models.CharField(max_length=10, choices=QTYPE, default="MCQ")

    def __str__(self):
        return self.text

class Option(models.Model):  # for MCQ
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='options')
    text = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return self.text

class OrderItem(models.Model):  # for ORDER
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='order_items')
    text = models.CharField(max_length=255)
    order_index = models.PositiveIntegerField()  # 0..n

    def __str__(self):
        return self.text

class Submission(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE)
    student = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    started_at = models.DateTimeField(auto_now_add=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    score = models.FloatField(default=0)


    def calculate_score(self):
        total = self.quiz.questions.count() # type: ignore
        if total == 0:
            self.score = 0
            self.save(update_fields=["score", "finished_at"])
            return {"score": 0, "correct": 0, "total": 0}

        correct = 0
        # Prefetch related answers and their nested relations for performance
        answers = self.answers.select_related("question", "selected_option").prefetch_related("question__order_items") # type: ignore

        for ans in answers:
            q = ans.question
            if q.qtype == "MCQ":
                if ans.selected_option and ans.selected_option.is_correct:
                    correct += 1
            else: # ORDER type
                expected_order = list(q.order_items.order_by("order_index").values_list("id", flat=True))
                if ans.given_order == expected_order:
                    correct += 1

        self.score = round(100 * correct / total, 2)
        self.finished_at = timezone.now()
        self.save(update_fields=["score", "finished_at"])
        return {"score": self.score, "correct": correct, "total": total}

class Answer(models.Model):
    submission = models.ForeignKey(Submission, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    # MCQ
    selected_option = models.ForeignKey(Option, null=True, blank=True, on_delete=models.SET_NULL)
    # ORDER
    given_order = models.JSONField(null=True, blank=True)  # list[int]



class Tag(models.Model):
    name = models.CharField(max_length=50, unique=True)


class Article(models.Model):
    title = models.CharField(max_length=200)
    body = models.TextField()
    tags = models.ManyToManyField(Tag, blank=True)
    published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    def __str__(self): return self.title




class Notification(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notifications")
    title = models.CharField(max_length=255)
    body = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at'] # အသစ်ဆုံးကို အပေါ်မှာပြရန်

    def __str__(self):
        return self.title



