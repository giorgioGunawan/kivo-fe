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
                creditRow(
                    title: "Subscription Credits",
                    value: appState.isProSubscriber
                        ? "\(appState.creditBalance.weeklyRemaining)"
                        : "—",
                    subtitle: appState.isProSubscriber ? "(resets weekly)" : nil
                )

                creditRow(
                    title: "Extra Credits",
                    value: "\(appState.creditBalance.purchasedRemaining)",
                    subtitle: "(never expire)"
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            // Footer
            if appState.isProSubscriber {
                Text(footerText)
                    .font(AppTheme.Typography.footnote)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .padding(.top, AppTheme.Spacing.xl)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

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
                }

                Button {
                    showingPaywall = true
                } label: {
                    Text("Buy Credits")
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showingPaywall) {
            PaywallView(initialPlan: .credits)
                .environmentObject(appState)
                .environmentObject(appEnvironment)
        }
    }

    private var footerText: String {
        if appState.creditBalance.weeklyRemaining > 0 {
            return "Subscription credits are used first."
        } else {
            return "Using extra credits until subscription refreshes."
        }
    }

    private func creditRow(title: String, value: String, subtitle: String? = nil) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.textTertiary)
                }
            }
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .bold))
        }
        .padding()
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
    }
}

#Preview {
    CreditDetailsSheet()
        .environmentObject(AppState())
        .environmentObject(AppEnvironment())
}
