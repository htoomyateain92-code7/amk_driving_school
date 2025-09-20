from rest_framework.permissions import BasePermission

class IsInstructor(BasePermission):
    def has_permission(self, request, view): # type: ignore
        u = request.user
        return u.is_authenticated and hasattr(u, "profile") and u.profile.role == "instructor"
