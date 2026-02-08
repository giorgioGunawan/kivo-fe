//
//  CreditDetailsSheet.swift
//  kivoai
//

import SwiftUI

struct CreditDetailsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
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
                if appState.isProSubscriber {
                    // Case 1-3: Pro Weekly first
                    creditRow(
                        title: "Pro Weekly",
                        value: "\(appState.creditBalance.weeklyRemaining)",
                        subtitle: "(resets in 7 days)"
                    )
                    
                    creditRow(
                        title: "Extra Credits",
                        value: "\(appState.creditBalance.purchasedRemaining)",
                        subtitle: "(never expire)"
                    )
                } else {
                    // Case 4: Extra Credits first
                    creditRow(
                        title: "Extra Credits",
                        value: "\(appState.creditBalance.purchasedRemaining)",
                        subtitle: "(never expire)"
                    )
                    
                    creditRow(
                        title: "Pro Weekly",
                        value: "Inactive",
                        subtitle: nil
                    )
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
            // Footer Text
            Text(footerText)
                .font(AppTheme.Typography.footnote)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.top, AppTheme.Spacing.xl)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // CTAs
            VStack(spacing: AppTheme.Spacing.md) {
                if !appState.isProSubscriber {
                    // Case 4 Primary CTA
                    Button {
                        dismiss()
                        appState.showingPaywall = true
                    } label: {
                        HStack {
                            Text("Get Pro")
                            Spacer()
                            Text("→ 500 credits every week")
                                .font(AppTheme.Typography.caption)
                                .opacity(0.8)
                        }
                        .primaryButtonStyle()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    // Case 4 Secondary CTA
                    Button {
                        print("Buy more credits tapped")
                    } label: {
                        Text("Buy more credits")
                            .font(AppTheme.Typography.headline)
                            .foregroundStyle(AppTheme.Colors.accent)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    // Case 1-3 Optional CTA
                    Button {
                        print("Buy extra credits tapped")
                    } label: {
                        Text("Buy extra credits")
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
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private var footerText: String {
        if appState.isProSubscriber {
            if appState.creditBalance.weeklyRemaining > 0 {
                return "Weekly credits are used first."
            } else {
                return "Using extra credits until weekly refresh."
            }
        }
        return ""
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
}
