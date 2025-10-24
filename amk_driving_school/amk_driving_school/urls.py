"""
URL configuration for amk_driving_school project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
# amk_driving_school/urls.py
"""
Main URL configuration for amk_driving_school project.
"""
"""
Main URL configuration for amk_driving_school project.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.decorators.csrf import csrf_exempt

# --- simplejwt view တွေကို ဒီကနေ import မလုပ်တော့ပါဘူး ---
# from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView 

# Custom JWT Views တွေကို accounts.views ကနေ import လုပ်ပါ
from accounts.views import CustomTokenObtainPairView, CustomTokenRefreshView

# Imports for API Documentation (drf-spectacular)
from drf_spectacular.views import SpectacularAPIView, SpectacularRedocView, SpectacularSwaggerView
# from drf_spectacular.utils import extend_schema # ဒီမှာမလိုအပ်တော့ပါဘူး

urlpatterns = [
    # 1. Django Admin Site
    path('admin/', admin.site.urls),

    # 2. Main API Endpoints
    path('api/v1/', include('core.urls')),

    # 3. JWT Token Authentication Endpoints
    # url ထဲမှာ extend_schema နဲ့ decorate လုပ်စရာမလိုတော့ပါဘူး
    path(
        'api/v1/token/',
        csrf_exempt(CustomTokenObtainPairView.as_view()),
        name='token_obtain_pair'
    ),
    path(
        'api/v1/token/refresh/',
        CustomTokenRefreshView.as_view(),
        name='token_refresh'
    ),

    # 4. API Schema & Documentation Endpoints
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/schema/swagger-ui/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/schema/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)