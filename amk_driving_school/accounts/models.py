from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings

ROLE_CHOICES = (
    ("owner", "Owner"),
    ("admin", "Admin"),
    ("instructor", "Instructor"),
    ("student", "Student"),
    ("guest", "Guest"),
)

class User(AbstractUser):
    # Role ကို ဒီ User model မှာပဲ တစ်နေရာတည်းမှာ သိမ်းပါ
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="student")

    # is_instructor, is_student တို့လို property တွေထည့်ရေးထားရင် ပိုအဆင်ပြေပါတယ်
    @property
    def is_instructor(self):
        return self.role == "instructor"

    @property
    def is_student(self):
        return self.role == "student"


class Profile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")
    # Profile model ထဲက role field ကို ဖယ်ရှားလိုက်ပါ
    # ဒီနေရာမှာ bio, profile_picture, phone_number တို့လို တခြားအချက်အလက်တွေ ထည့်နိုင်ပါတယ်
    bio = models.TextField(blank=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)

    def __str__(self):
        # User ရဲ့ role ကို တိုက်ရိုက်လှမ်းယူသုံးပါ
        return f"{self.user.username} ({self.user.role})"