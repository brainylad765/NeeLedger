from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator


class Transaction(models.Model):
    TRANSACTION_TYPES = [
        ('buy', 'Buy Credits'),
        ('sell', 'Sell Credits'),
        ('transfer', 'Transfer Credits'),
        ('retire', 'Retire Credits'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
    ]

    transaction_id = models.CharField(max_length=50, unique=True)
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPES)

    # Parties involved
    buyer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='purchases'
    )
    seller = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sales'
    )

    # Transaction details
    project = models.ForeignKey(
        'projects.Project',
        on_delete=models.CASCADE,
        related_name='transactions'
    )
    credit_amount = models.PositiveIntegerField(validators=[MinValueValidator(1)])
    price_per_credit = models.DecimalField(max_digits=10, decimal_places=2)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)

    # Status and timestamps
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    transaction_date = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)

    # Additional metadata
    notes = models.TextField(blank=True)
    blockchain_tx_hash = models.CharField(max_length=128, blank=True, null=True)

    def __str__(self):
        return f"{self.transaction_id} - {self.transaction_type} {self.credit_amount} credits"

    def save(self, *args, **kwargs):
        if not self.transaction_id:
            import uuid
            self.transaction_id = f"TXN-{uuid.uuid4().hex[:8].upper()}"
        if not self.total_amount:
            self.total_amount = self.credit_amount * self.price_per_credit
        super().save(*args, **kwargs)

    class Meta:
        ordering = ['-transaction_date']


class CreditWallet(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='credit_wallet'
    )
    total_credits = models.PositiveIntegerField(default=0)
    available_credits = models.PositiveIntegerField(default=0)
    retired_credits = models.PositiveIntegerField(default=0)

    # Financial summary
    total_invested = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    total_earned = models.DecimalField(max_digits=15, decimal_places=2, default=0)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username}'s Credit Wallet"

    @property
    def net_worth(self):
        return self.total_earned - self.total_invested


class CreditHolding(models.Model):
    wallet = models.ForeignKey(CreditWallet, on_delete=models.CASCADE, related_name='holdings')
    project = models.ForeignKey('projects.Project', on_delete=models.CASCADE)
    credit_amount = models.PositiveIntegerField()
    purchase_price = models.DecimalField(max_digits=10, decimal_places=2)
    purchase_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.credit_amount} credits from {self.project.title}"

    class Meta:
        ordering = ['-purchase_date']
