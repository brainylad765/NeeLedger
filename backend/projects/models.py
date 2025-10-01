from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator


class Project(models.Model):
    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Submitted'),
        ('under_review', 'Under Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
        ('active', 'Active'),
        ('completed', 'Completed'),
    ]

    CATEGORY_CHOICES = [
        ('reforestation', 'Reforestation'),
        ('renewable_energy', 'Renewable Energy'),
        ('energy_efficiency', 'Energy Efficiency'),
        ('waste_management', 'Waste Management'),
        ('agriculture', 'Agriculture'),
        ('other', 'Other'),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField()
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)

    proponent = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='projects'
    )

    location = models.CharField(max_length=200)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)

    estimated_credits = models.PositiveIntegerField()
    current_credits = models.PositiveIntegerField(default=0)

    start_date = models.DateField()
    end_date = models.DateField()

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')

    # Financial details
    total_cost = models.DecimalField(max_digits=12, decimal_places=2)
    funding_received = models.DecimalField(max_digits=12, decimal_places=2, default=0)

    # Verification details
    verifier = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='verified_projects'
    )
    verification_date = models.DateTimeField(null=True, blank=True)

    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title

    @property
    def progress_percentage(self):
        if self.estimated_credits == 0:
            return 0
        return min(100, int((self.current_credits / self.estimated_credits) * 100))

    class Meta:
        ordering = ['-created_at']


class ProjectImage(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='project_images/')
    caption = models.CharField(max_length=200, blank=True)
    is_primary = models.BooleanField(default=False)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for {self.project.title}"

    class Meta:
        ordering = ['-uploaded_at']


class ProjectDocument(models.Model):
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='documents')
    title = models.CharField(max_length=200)
    document = models.FileField(upload_to='project_documents/')
    document_type = models.CharField(max_length=50)  # PDF, DOC, XLS, etc.
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.project.title}"

    class Meta:
        ordering = ['-uploaded_at']
