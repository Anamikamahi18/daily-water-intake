from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator
from datetime import date

class WaterIntake(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    amount = models.FloatField(
        validators=[MinValueValidator(0.1)],
        help_text="Water intake in liters"
    )
    date = models.DateField(default=date.today)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'date']
        ordering = ['-date']

    def __str__(self):
        return f"{self.user.username} - {self.amount}L on {self.date}"