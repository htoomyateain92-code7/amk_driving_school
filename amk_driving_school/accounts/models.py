from decimal import Decimal
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

    remaining_credit_hours = models.DecimalField(
        max_digits=5, 
        decimal_places=2, 
        default=Decimal('0.00'),
        verbose_name="ကျန်ရှိသင်တန်းနာရီ"
    )

    @property
    def is_owner(self):
        return self.role == "owner"

    @property
    def is_admin(self):
        return self.role == "admin"

    # is_instructor, is_student တို့လို property တွေထည့်ရေးထားရင် ပိုအဆင်ပြေပါတယ်
    @property
    def is_instructor(self):
        return self.role == "instructor"

    @property
    def is_student(self):
        return self.role == "student"

    # @property
    # def is_staff(self):
    #     # Django Admin Panel နှင့် IsAdminUser Permission များကို ထိန်းချုပ်ရန်
    #     return self.role in ["owner", "admin", "instructor"]
    def save(self, *args, **kwargs):
        self.is_staff = self.role in ["owner", "admin", "instructor"]
        self.is_staff = self.is_superuser or is_staff_based_on_role # type: ignore
        super().save(*args, **kwargs)



class Profile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")
    # Profile model ထဲက role field ကို ဖယ်ရှားလိုက်ပါ
    # ဒီနေရာမှာ bio, profile_picture, phone_number တို့လို တခြားအချက်အလက်တွေ ထည့်နိုင်ပါတယ်
    bio = models.TextField(blank=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)

    def __str__(self):
        # User ရဲ့ role ကို တိုက်ရိုက်လှမ်းယူသုံးပါ
        return f"{self.user.username} ({self.user.role})"



class InstructorAvailability(models.Model):
    instructor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        limit_choices_to={'is_staff': True} # ဆရာဖြစ်သူကိုသာ ရွေးချယ်နိုင်ရန်
    )
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()

    class Meta:
        verbose_name = "Instructor Availability"
        # ဆရာတစ်ဦးရဲ့ တစ်ရက်တာ ရရှိနိုင်မှုကို တစ်ကြိမ်သာ သတ်မှတ်နိုင်မည်။
        unique_together = ('instructor', 'date')
        ordering = ['date', 'start_time']

    def __str__(self):
        return f"{self.instructor} - {self.date}"