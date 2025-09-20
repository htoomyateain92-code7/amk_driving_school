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
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="student")



class Profile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="profile")
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default="student")

    def __str__(self): return f"{self.user.username} ({self.role})"