from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import RegexValidator


class User(AbstractUser):
    ROLE_CHOICES = [
        ('project_developer', 'Project Developer'),
        ('credit_buyer', 'Credit Buyer'),
        ('verifier', 'Verifier'),
        ('administrator', 'Administrator'),
    ]

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='project_developer'
    )

    mobile = models.CharField(
        max_length=15,
        validators=[RegexValidator(r'^\+?1?\d{9,15}$')],
        blank=True,
        null=True
    )

    kyb_link = models.URLField(blank=True, null=True)

    is_project_proponent = models.BooleanField(default=False)

    has_completed_kyc = models.BooleanField(default=False)

    firebase_uid = models.CharField(max_length=128, unique=True, blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.username} ({self.get_role_display()})"

    class Meta:
        ordering = ['-created_at']
