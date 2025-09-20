# accounts/views.py
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import authenticate
from .serializers import RegisterSerializer, MeSerializer, ChangePasswordSerializer
from drf_spectacular.utils import extend_schema, OpenApiResponse

class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer


class MeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response(MeSerializer(request.user).data)

    def patch(self, request):
        ser = MeSerializer(request.user, data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        ser.save()
        return Response(ser.data)


class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        tags=["Auth"],
        request=ChangePasswordSerializer,
        responses={200: OpenApiResponse(description="Password changed."),
                   400: OpenApiResponse(description="Old password incorrect.")},
    )
    def post(self, request):
        ser = ChangePasswordSerializer(data=request.data)
        ser.is_valid(raise_exception=True)
        user = request.user
        if not user.check_password(ser.validated_data["old_password"]): # type: ignore
            return Response({"detail": "Old password incorrect."}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(ser.validated_data["new_password"]) # type: ignore
        user.save()
        return Response({"detail": "Password changed."})
