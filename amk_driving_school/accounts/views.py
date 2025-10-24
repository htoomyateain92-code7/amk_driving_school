# accounts/views.py
from rest_framework import generics, permissions, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import action
from django.contrib.auth import authenticate
from .serializers import RegisterSerializer, MeSerializer, ChangePasswordSerializer
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from drf_spectacular.utils import extend_schema


class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer


class MeView(generics.RetrieveUpdateAPIView): # APIView အစား RetrieveUpdateAPIView ကိုသုံးပါ
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MeSerializer

    def get_object(self):
        # Retrieve/Update လုပ်ရမယ့် object က လက်ရှိ login ဝင်ထားတဲ့ user ဖြစ်ကြောင်း သတ်မှတ်ပေးပါ
        return self.request.user


class ChangePasswordView(generics.GenericAPIView):
    """
    An endpoint for changing the current user's password.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ChangePasswordSerializer

    # Decorator ကို post method ရဲ့ အပေါ်မှာ တိုက်ရိုက်ရေးရပါမယ်
    @extend_schema(
        tags=["Accounts"],
        summary="Change current user's password",
        request=ChangePasswordSerializer,
        responses={
            200: OpenApiResponse(description="Password changed successfully."),
            400: OpenApiResponse(description="Validation Error (e.g., Old password incorrect).")
        },
    )
    def post(self, request, *args, **kwargs):
        """
        Handles the password change logic by using the serializer.
        """
        # serializer ကို 'context' ထဲမှာ request object ထည့်ပြီး instantiate လုပ်ပါ
        # ဒါမှ serializer ထဲမှာ request.user ကို သုံးလို့ရမှာပါ
        serializer = self.get_serializer(data=request.data)
        # is_valid() က serializer ထဲက validate_old_password logic ကို run သွားပါလိမ့်မယ်
        serializer.is_valid(raise_exception=True)

        # is_valid() အောင်မြင်ရင် save() ကိုခေါ်ပါ
        # save() က user.set_password() နဲ့ user.save() ကို အလုပ်လုပ်သွားပါလိမ့်မယ်
        serializer.save()

        return Response({"detail": "Password changed successfully."}, status=status.HTTP_200_OK)



class AccountViewSet(viewsets.GenericViewSet):
    """
    An endpoint for handling account-related actions like registration,
    viewing the current user profile, and changing the password.
    """
    
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        
        if self.action == 'register':
            return RegisterSerializer
        elif self.action == 'me':
            return MeSerializer
        elif self.action == 'change_password':
            return ChangePasswordSerializer
        return super().get_serializer_class()

    @extend_schema(
        tags=["Accounts"],
        summary="Register a new user account"
    )
    @action(detail=False, methods=['post'], permission_classes=[permissions.AllowAny])
    def register(self, request):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    @extend_schema(
        tags=["Accounts"],
        summary="Retrieve or update the current user's profile"
    )
    @action(detail=False, methods=['get', 'patch'], url_path='me')
    def me(self, request):
        user = request.user
        if request.method == 'GET':
            serializer = self.get_serializer(user)
            return Response(serializer.data)

        # PATCH method
        serializer = self.get_serializer(user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

    @extend_schema(
        tags=["Accounts"],
        summary="Change the current user's password"
    )
    @action(detail=False, methods=['post'], url_path='change-password')
    def change_password(self, request):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"detail": "Password changed successfully."}, status=status.HTTP_200_OK)


@extend_schema(
    tags=["Authentication"],
    summary="Obtain JWT token pair by providing username and password"
)
class CustomTokenObtainPairView(TokenObtainPairView):
    pass

@extend_schema(
    tags=["Authentication"],
    summary="Refresh JWT access token by providing a valid refresh token"
)
class CustomTokenRefreshView(TokenRefreshView):
    pass