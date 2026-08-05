"""config URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
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
from django.contrib import admin
from django.conf import settings
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from config.health import healthz, readyz

urlpatterns = [
    path('healthz', healthz, name='healthz'),
    path('readyz', readyz, name='readyz'),
    path('api/v1/', include('users.urls')),
    path('api/v1/', include('medical.urls')),
]

if settings.ENABLE_ADMIN:
    urlpatterns.append(path('admin/', admin.site.urls))

if settings.ENABLE_API_DOCS:
    urlpatterns.extend(
        [
            path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
            path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
        ]
    )
