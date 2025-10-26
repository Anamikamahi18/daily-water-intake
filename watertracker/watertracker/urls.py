from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('intake.urls')),
    path('logout/', include('django.contrib.auth.urls')),  # Only logout, login handled in intake.urls
]