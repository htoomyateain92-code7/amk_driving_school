from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Profile

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (("Role", {"fields": ("role",)}),) # type: ignore
    list_display = ("username","email","role","is_staff","is_active")
    list_filter = ("role","is_staff","is_active")



@admin.register(Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ("user","role")
    list_filter = ("role",)
    search_fields = ("user__username","user__email")