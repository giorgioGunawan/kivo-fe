//
//  CreditDetailsSheet.swift
//  kivoai
//

import SwiftUI

struct CreditDetailsSheet: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var showingPaywall = false
    @State private var showingExtraCredits = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Credits")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.top, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)

            VStack(spacing: AppTheme.Spacing.md) {
                // Weekly pool row — only meaningful for Pro subscribers
                creditRow(
                    title: proCreditsTitle,
                    value: appState.isProSubscriber
                        ? "\(appState.creditBalance.weeklyRemaining)"
                        : "Inactive",
                    subtitle: appState.isProSubscriber
                        ? "renews with subscription"
                        : "Subscribe to unlock",
                    isInactive: !appState.isProSubscriber
                )

                // Purchased pool row
                creditRow(
                    title: "Extra Credits",
                    value: "\(appState.creditBalance.purchasedRemaining)",
                    subtitle: "never expire",
                    isInactive: false
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            // Contextual footer
            Group {
                if !appState.isProSubscriber && appState.creditBalance.purchasedRemaining > 0 {
                    Text("You can still generate using your extra credits. Upgrade to Pro to unlock 500 weekly credits.")
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                } else if appState.isProSubscriber {
                    Text(footerText)
                        .font(AppTheme.Typography.footnote)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .padding(.top, AppTheme.Spacing.xl)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // CTAs
            VStack(spacing: AppTheme.Spacing.md) {
                if !appState.isProSubscriber {
                    Button {
                        dismiss()
                        appState.showingPaywall = true
                    } label: {
                        Text("Get Pro")
                            .primaryButtonStyle()
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        showingExtraCredits = true
                    } label: {
                        Text("Buy More Credits")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .background(Color(UIColor.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
        .sheet(isPresented: $showingExtraCredits) {
            ExtraCreditsSheet()
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
    }

    // MARK: - Helpers

    private var proCreditsTitle: String {
        if appEnvironment.storeKitManager.activeSubscriptionID == StoreKitManager.ProductID.monthly {
            return "Pro Monthly Credits"
        }
        return "Pro Weekly Credits"
    }

    private var footerText: String {
        let isMonthly = appEnvironment.storeKitManager.activeSubscriptionID == StoreKitManager.ProductID.monthly
        let period = isMonthly ? "Monthly" : "Weekly"

        if appState.creditBalance.weeklyRemaining > 0 {
            return "\(period) credits are used first before any extra credits."
        } else {
            return "\(period) credits used up. Using extra credits."
        }
    }

    private func creditRow(
        title: String,
        value: String,
        subtitle: String?,
        isInactive: Bool = false
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(isInactive ? AppTheme.Colors.textTertiary : AppTheme.Colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(isInactive ? AppTheme.Colors.textTertiary : AppTheme.Colors.textPrimary)
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(AppTheme.Colors.textTertiary.opacity(0.25), lineWidth: 1)
        )
    }
}

#Preview {
    CreditDetailsSheet()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
