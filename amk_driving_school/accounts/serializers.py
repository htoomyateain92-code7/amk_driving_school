# accounts/serializers.py
from django.contrib.auth import get_user_model, password_validation
from rest_framework import serializers

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, trim_whitespace=False)
    class Meta:
        model = User
        fields = ("username", "email", "password", "role")  # role ကို default "student" ထားထားတတ်
        extra_kwargs = {"email": {"required": False}}

    def validate_password(self, value):
        password_validation.validate_password(value)
        return value

    def create(self, validated_data):
        pwd = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(pwd)
        user.save()
        return user


class MeSerializer(serializers.ModelSerializer):
    has_bookings = serializers.SerializerMethodField()

    class Meta:
        model = User
        read_only_fields = ("role", "is_staff", "is_superuser")
        
        # --- ဒီ fields list ထဲမှာ 'has_bookings' ကို ထည့်ပေးပါ ---
        fields = ("id", "username", "email", "first_name", "last_name", "role", "has_bookings")

    def get_has_bookings(self, user):
        # user မှာ approved ဖြစ်နေတဲ့ booking အနည်းဆုံးတစ်ခုရှိမရှိ စစ်ဆေးပါ
        return user.bookings.filter(status='approved').exists()



class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is not correct.")
        return value

    def save(self, **kwargs):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password']) # type: ignore
        user.save()
        return user



# ========================================================== #
#  --- NEW SERIALIZER (To fix Flutter TypeError in Batch) --- #
# ========================================================== #
class SimpleUserSerializer(serializers.ModelSerializer):
    """A simple serializer to represent a user with minimal details."""
    class Meta:
        model = User
        fields = ['id', 'username']