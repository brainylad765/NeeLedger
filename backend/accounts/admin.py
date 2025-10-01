from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'role', 'is_project_proponent', 'has_completed_kyc', 'is_active')
    list_filter = ('role', 'is_project_proponent', 'has_completed_kyc', 'is_active', 'is_staff')
    search_fields = ('username', 'email', 'first_name', 'last_name')
    ordering = ('-date_joined',)

    fieldsets = UserAdmin.fieldsets + (
        ('Additional Info', {
            'fields': ('role', 'mobile', 'kyb_link', 'is_project_proponent', 'has_completed_kyc', 'firebase_uid')
        }),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Additional Info', {
            'fields': ('role', 'mobile', 'kyb_link', 'is_project_proponent', 'has_completed_kyc', 'firebase_uid')
        }),
    )
