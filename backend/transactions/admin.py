from django.contrib import admin
from .models import Transaction, CreditWallet, CreditHolding


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('transaction_id', 'transaction_type', 'buyer', 'seller', 'credit_amount', 'total_amount', 'status', 'transaction_date')
    list_filter = ('transaction_type', 'status', 'transaction_date')
    search_fields = ('transaction_id', 'buyer__username', 'seller__username', 'project__title')
    ordering = ('-transaction_date',)
    readonly_fields = ('transaction_id', 'transaction_date')

    fieldsets = (
        ('Transaction Info', {
            'fields': ('transaction_id', 'transaction_type', 'status', 'transaction_date', 'completed_at')
        }),
        ('Parties', {
            'fields': ('buyer', 'seller')
        }),
        ('Details', {
            'fields': ('project', 'credit_amount', 'price_per_credit', 'total_amount')
        }),
        ('Additional', {
            'fields': ('notes', 'blockchain_tx_hash')
        }),
    )


class CreditHoldingInline(admin.TabularInline):
    model = CreditHolding
    extra = 0
    readonly_fields = ('purchase_date',)


@admin.register(CreditWallet)
class CreditWalletAdmin(admin.ModelAdmin):
    list_display = ('user', 'total_credits', 'available_credits', 'retired_credits', 'total_invested', 'total_earned')
    search_fields = ('user__username', 'user__email')
    inlines = [CreditHoldingInline]


@admin.register(CreditHolding)
class CreditHoldingAdmin(admin.ModelAdmin):
    list_display = ('wallet', 'project', 'credit_amount', 'purchase_price', 'purchase_date')
    list_filter = ('purchase_date',)
    search_fields = ('wallet__user__username', 'project__title')
