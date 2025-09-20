from django.conf import settings
from django.db import models

class Course(models.Model):
    title = models.CharField(max_length=150)
    code  = models.CharField(max_length=30, unique=True)
    description = models.TextField(blank=True)
    is_public = models.BooleanField(default=True)

    def __str__(self): return self.title

class Batch(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name="batches")
    title  = models.CharField(max_length=150)
    instructor = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="teaching_batches")
    start_date = models.DateField()
    end_date   = models.DateField()

class Session(models.Model):
    STATUS = (("scheduled","scheduled"),("canceled","canceled"),("completed","completed"))
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE, related_name="sessions")
    start_dt = models.DateTimeField(db_index=True)
    end_dt   = models.DateTimeField()
    status   = models.CharField(max_length=12, choices=STATUS, default="scheduled")
    reason   = models.CharField(max_length=200, blank=True)

    class Meta:
        indexes = [
        models.Index(fields=["start_dt", "end_dt", "status"]),
        models.Index(fields=["batch", "start_dt"]),
    ]

class Enrollment(models.Model):
    user  = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    batch = models.ForeignKey(Batch, on_delete=models.CASCADE)
    status = models.CharField(max_length=12, default="active")
    class Meta:
        unique_together = ("user","batch")

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

class Option(models.Model):  # for MCQ
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='options')
    text = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)

class OrderItem(models.Model):  # for ORDER
    question = models.ForeignKey(Question, on_delete=models.CASCADE, related_name='order_items')
    text = models.CharField(max_length=255)
    order_index = models.PositiveIntegerField()  # 0..n

class Submission(models.Model):
    quiz = models.ForeignKey(Quiz, on_delete=models.CASCADE)
    student = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    started_at = models.DateTimeField(auto_now_add=True)
    finished_at = models.DateTimeField(null=True, blank=True)
    score = models.FloatField(default=0)

class Answer(models.Model):
    submission = models.ForeignKey(Submission, on_delete=models.CASCADE, related_name='answers')
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    # MCQ
    selected_option = models.ForeignKey(Option, null=True, blank=True, on_delete=models.SET_NULL)
    # ORDER
    given_order = models.JSONField(null=True, blank=True)  # list[int]




class Article(models.Model):
    title = models.CharField(max_length=200)
    body = models.TextField()
    tags = models.JSONField(default=list)  # ["traffic-signs","safety"]
    published = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    def __str__(self): return self.title