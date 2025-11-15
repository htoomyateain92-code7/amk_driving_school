# Custom User model အတွက် Admin class
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from core.models import Booking
from .models import User, Profile


class CustomUserAdmin(UserAdmin):
    # 💡 fieldsets ကို ပြင်ဆင်ပါ
    fieldsets = (
        (None, {'fields': ('username',)}),
        # Permissions Fieldset ကို ပြင်ဆင်ပြီး is_staff အစား role ကို ထည့်ပါ
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Permissions', {
            'fields': ('is_active', 'is_superuser', 'role', 'groups', 'user_permissions'),
        }),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    
    # # 💡 add_fieldsets ကို ပြင်ဆင်ပါ (အကောင့်အသစ် ဖန်တီးရာတွင် သုံးသည်)
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'role', 'password', 'password2'),
        }),
    )
    
    # 💡 list_display မှာလည်း is_staff အစား role ကို ထည့်သွင်းပါ
    list_display = ('username', 'email', 'first_name', 'last_name', 'role', 'is_active')
    
    # 💡 is_staff ကို list_filter မှာလည်း ဖယ်ရှားပြီး is_active ကိုသာ ထားပါ
    list_filter = ('is_active', 'is_superuser', 'role') # 'is_staff' ကို ဖယ်ရှားလိုက်ပါ
    search_fields = ('username', 'email', 'first_name', 'last_name')


# Profile model အတွက် Admin (Optional)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_user_role')

    @admin.display(description='Role')
    def get_user_role(self, obj):
        return obj.user.role


# Django admin site မှာ register လုပ်ပါ
admin.site.register(User, CustomUserAdmin)
admin.site.register(Profile, ProfileAdmin)



