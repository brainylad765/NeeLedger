from django.contrib import admin
from .models import Evidence, EvidenceComment, EvidenceRevision


class EvidenceCommentInline(admin.TabularInline):
    model = EvidenceComment
    extra = 0
    readonly_fields = ('created_at', 'updated_at')


class EvidenceRevisionInline(admin.TabularInline):
    model = EvidenceRevision
    extra = 0
    readonly_fields = ('created_at',)


@admin.register(Evidence)
class EvidenceAdmin(admin.ModelAdmin):
    list_display = ('title', 'project', 'evidence_type', 'status', 'submitted_by', 'submitted_at')
    list_filter = ('evidence_type', 'status', 'submitted_at')
    search_fields = ('title', 'description', 'project__title', 'submitted_by__username')
    ordering = ('-submitted_at',)
    inlines = [EvidenceCommentInline, EvidenceRevisionInline]

    fieldsets = (
        ('Basic Information', {
            'fields': ('title', 'description', 'evidence_type', 'status')
        }),
        ('Relationships', {
            'fields': ('project', 'submitted_by', 'reviewed_by')
        }),
        ('Files', {
            'fields': ('document_file', 'image_file', 'video_file')
        }),
        ('Location', {
            'fields': ('latitude', 'longitude', 'location_accuracy')
        }),
        ('Review Process', {
            'fields': ('review_notes', 'reviewed_at')
        }),
        ('Metadata', {
            'fields': ('file_size', 'mime_type', 'submitted_at', 'updated_at')
        }),
    )

    readonly_fields = ('submitted_at', 'updated_at')


@admin.register(EvidenceComment)
class EvidenceCommentAdmin(admin.ModelAdmin):
    list_display = ('evidence', 'author', 'is_internal', 'created_at')
    list_filter = ('is_internal', 'created_at')
    search_fields = ('evidence__title', 'author__username', 'comment')
    readonly_fields = ('created_at', 'updated_at')


@admin.register(EvidenceRevision)
class EvidenceRevisionAdmin(admin.ModelAdmin):
    list_display = ('evidence', 'revision_number', 'requested_by', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('evidence__title', 'changes_description', 'requested_by__username')
    readonly_fields = ('created_at',)
