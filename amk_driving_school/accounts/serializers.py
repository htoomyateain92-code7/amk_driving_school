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
    class Meta:
        model = User
        # role ကို user ကိုယ်တိုင် မပြင်နိုင်အောင် read_only ပြု
        read_only_fields = ("role", "is_staff", "is_superuser")
        fields = ("id", "username", "email", "first_name", "last_name", "role")


class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True, trim_whitespace=False)
    new_password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate_new_password(self, value):
        password_validation.validate_password(value)
        return value
