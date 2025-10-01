from django.db import models
from django.conf import settings


class Evidence(models.Model):
    EVIDENCE_TYPES = [
        ('document', 'Document'),
        ('image', 'Image'),
        ('video', 'Video'),
        ('report', 'Report'),
        ('certificate', 'Certificate'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('requires_revision', 'Requires Revision'),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)

    evidence_type = models.CharField(max_length=20, choices=EVIDENCE_TYPES)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

    # Relationships
    project = models.ForeignKey(
        'projects.Project',
        on_delete=models.CASCADE,
        related_name='evidence'
    )
    submitted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='submitted_evidence'
    )
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_evidence'
    )

    # File attachments
    document_file = models.FileField(
        upload_to='evidence_documents/',
        null=True,
        blank=True
    )
    image_file = models.ImageField(
        upload_to='evidence_images/',
        null=True,
        blank=True
    )
    video_file = models.FileField(
        upload_to='evidence_videos/',
        null=True,
        blank=True
    )

    # Metadata
    file_size = models.PositiveIntegerField(null=True, blank=True)  # in bytes
    mime_type = models.CharField(max_length=100, blank=True)

    # Location data (for geospatial evidence)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location_accuracy = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)

    # Review process
    review_notes = models.TextField(blank=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)

    # Timestamps
    submitted_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.project.title}"

    def get_file_url(self):
        """Return the URL of the attached file based on evidence type"""
        if self.evidence_type == 'document' and self.document_file:
            return self.document_file.url
        elif self.evidence_type == 'image' and self.image_file:
            return self.image_file.url
        elif self.evidence_type == 'video' and self.video_file:
            return self.video_file.url
        return None

    class Meta:
        ordering = ['-submitted_at']
        verbose_name_plural = 'Evidence'


class EvidenceComment(models.Model):
    evidence = models.ForeignKey(Evidence, on_delete=models.CASCADE, related_name='comments')
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    comment = models.TextField()
    is_internal = models.BooleanField(default=False)  # Internal comments not visible to proponents

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Comment by {self.author.username} on {self.evidence.title}"

    class Meta:
        ordering = ['created_at']


class EvidenceRevision(models.Model):
    evidence = models.ForeignKey(Evidence, on_delete=models.CASCADE, related_name='revisions')
    revision_number = models.PositiveIntegerField()
    changes_description = models.TextField()

    # File changes
    old_file = models.FileField(upload_to='evidence_revisions/', null=True, blank=True)
    new_file = models.FileField(upload_to='evidence_revisions/')

    requested_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Revision {self.revision_number} for {self.evidence.title}"

    class Meta:
        ordering = ['-revision_number']
        unique_together = ['evidence', 'revision_number']
