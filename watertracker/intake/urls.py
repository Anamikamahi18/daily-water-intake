from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('add/', views.add_intake, name='add_intake'),
    path('list/', views.intake_list, name='intake_list'),
    path('edit/<int:pk>/', views.edit_intake, name='edit_intake'),
    path('delete/<int:pk>/', views.delete_intake, name='delete_intake'),
    path('compare/', views.compare_intake, name='compare_intake'),
    path('signup/', views.signup, name='signup'),
    path('login/', views.login_view, name='login'),
]