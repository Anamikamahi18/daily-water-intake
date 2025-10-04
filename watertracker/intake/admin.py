from django.contrib import admin
from .models import WaterIntake

@admin.register(WaterIntake)
class WaterIntakeAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount', 'date', 'created_at')
    list_filter = ('date', 'created_at')
    search_fields = ('user__username', 'user__email')
    ordering = ('-date', '-created_at')
    readonly_fields = ('created_at', 'updated_at')