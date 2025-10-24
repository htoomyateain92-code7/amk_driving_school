# Custom User model အတွက် Admin class
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from core.models import Booking
from .models import User, Profile


class CustomUserAdmin(UserAdmin):
    # autocomplete_fields အလုပ်လုပ်ဖို့ ဒီ search_fields က မဖြစ်မနေလိုအပ်ပါတယ်
    search_fields = ('username', 'email', 'first_name', 'last_name')

    # Admin list view မှာ 'role' ကိုပါ တစ်ခါတည်းပြချင်ရင်
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff', 'role')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'groups', 'role')

    # User ကို edit လုပ်တဲ့ form မှာ 'role' field ကို ထည့်သွင်းရန်
    # UserAdmin ရဲ့ မူလ fieldsets ကို copy ယူပြီး 'role' ကိုထပ်ထည့်ပါ
    fieldsets = UserAdmin.fieldsets + (
        ('Custom Fields', {'fields': ('role',)}),
    ) # type: ignore
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Custom Fields', {'fields': ('role',)}),
    )


# Profile model အတွက် Admin (Optional)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_user_role')

    @admin.display(description='Role')
    def get_user_role(self, obj):
        return obj.user.role


# Django admin site မှာ register လုပ်ပါ
admin.site.register(User, CustomUserAdmin)
admin.site.register(Profile, ProfileAdmin)



