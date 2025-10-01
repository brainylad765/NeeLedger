from django.contrib import admin
from .models import Project, ProjectImage, ProjectDocument


class ProjectImageInline(admin.TabularInline):
    model = ProjectImage
    extra = 0


class ProjectDocumentInline(admin.TabularInline):
    model = ProjectDocument
    extra = 0


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('title', 'proponent', 'category', 'status', 'estimated_credits', 'current_credits', 'created_at')
    list_filter = ('status', 'category', 'created_at')
    search_fields = ('title', 'description', 'proponent__username', 'proponent__email')
    ordering = ('-created_at',)
    inlines = [ProjectImageInline, ProjectDocumentInline]

    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'description', 'category', 'proponent')
        }),
        ('Location', {
            'fields': ('location', 'latitude', 'longitude')
        }),
        ('Credits & Funding', {
            'fields': ('estimated_credits', 'current_credits', 'total_cost', 'funding_received')
        }),
        ('Timeline', {
            'fields': ('start_date', 'end_date')
        }),
        ('Status & Verification', {
            'fields': ('status', 'verifier', 'verification_date')
        }),
    )


@admin.register(ProjectImage)
class ProjectImageAdmin(admin.ModelAdmin):
    list_display = ('project', 'caption', 'is_primary', 'uploaded_at')
    list_filter = ('is_primary', 'uploaded_at')
    search_fields = ('project__title', 'caption')


@admin.register(ProjectDocument)
class ProjectDocumentAdmin(admin.ModelAdmin):
    list_display = ('title', 'project', 'document_type', 'uploaded_at')
    list_filter = ('document_type', 'uploaded_at')
    search_fields = ('title', 'project__title')
