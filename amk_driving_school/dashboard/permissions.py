# dashboard/permissions.py (New File)

from rest_framework import permissions

class IsOwnerOrAdmin(permissions.BasePermission):
    """ Owner (or) Admin Role ရှိမှသာ ဝင်ရောက်ခွင့်ပြုမည် """
    def has_permission(self, request, view):
        user = request.user
        if not user.is_authenticated:
            return False
        # Owner သို့မဟုတ် Admin Role ရှိမှသာ ခွင့်ပြုပါ
        return user.role in ["owner", "admin"]


class IsInstructorOrAbove(permissions.BasePermission):
    """ Owner, Admin သို့မဟုတ် Instructor Role ရှိမှသာ ဝင်ရောက်ခွင့်ပြုမည် """
    def has_permission(self, request, view):
        user = request.user
        if not user.is_authenticated:
            return False
        # Owner, Admin, Instructor ၃ မျိုးလုံးကို ခွင့်ပြုပါ
        return user.role in ["owner", "admin", "instructor"]