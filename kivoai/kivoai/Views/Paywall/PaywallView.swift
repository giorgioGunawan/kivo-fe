//
//  PaywallView.swift
//  kivoai
//

import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPlan: Plan = .pro
    
    enum Plan: String, CaseIterable {
        case pro
        case credits
        
        var title: String {
            switch self {
            case .pro: return "Pro Subscription"
            case .credits: return "Credit Pack"
            }
        }
        
        var price: String {
            switch self {
            case .pro: return "$9.99/week"
            case .credits: return "$4.99"
            }
        }
        
        var description: String {
            switch self {
            case .pro: return "500 credits weekly"
            case .credits: return "100 credits one-time"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient.kivoBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Benefits
                        benefitsSection
                        
                        // Plan selection
                        planSelectionSection
                        
                        // Purchase button
                        purchaseButton
                        
                        // Legal text
                        legalText
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color.kivoTextTertiary)
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Pro badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kivoCredits, Color.kivoCredits.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.kivoCredits.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.black)
            }
            
            VStack(spacing: 8) {
                Text("Unlock Kivo Pro")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Create unlimited AI masterpieces")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
            }
        }
    }
    
    // MARK: - Benefits Section
    
    private var benefitsSection: some View {
        VStack(spacing: 16) {
            BenefitRow(icon: "bolt.fill", title: "500 Weekly Credits", description: "Refresh every week automatically")
            BenefitRow(icon: "square.grid.2x2.fill", title: "All Templates", description: "Access every template, including new ones")
            BenefitRow(icon: "wand.and.stars", title: "Priority Generation", description: "Skip the queue for faster results")
            BenefitRow(icon: "video.fill", title: "Video Coming Soon", description: "Be first to try AI video generation")
        }
        .padding(20)
        .background(Color.kivoCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Plan Selection
    
    private var planSelectionSection: some View {
        VStack(spacing: 12) {
            ForEach(Plan.allCases, id: \.self) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan == plan
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedPlan = plan
                    }
                }
            }
        }
    }
    
    // MARK: - Purchase Button
    
    private var purchaseButton: some View {
        Button(action: handlePurchase) {
            Text(selectedPlan == .pro ? "Start Pro (Mock)" : "Buy Credits (Mock)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.kivoCredits, Color.kivoCredits.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Legal Text
    
    private var legalText: some View {
        Text("This is a mock paywall for development. No real payment will be processed.")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Color.kivoTextTertiary)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Actions
    
    private func handlePurchase() {
        switch selectedPlan {
        case .pro:
            appState.purchasePro()
        case .credits:
            appState.addPurchasedCredits(100)
        }
        dismiss()
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.kivoAccent.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.kivoAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.kivoTextSecondary)
            }
            
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: PaywallView.Plan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(plan.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.kivoTextSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(plan.price)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isSelected ? Color.kivoCredits : .white)
                    
                    if plan == .pro {
                        Text("Best Value")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.kivoCredits)
                            .clipShape(Capsule())
                    }
                }
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.kivoAccent : Color.kivoTextTertiary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.kivoAccent)
                            .frame(width: 14, height: 14)
                    }
                }
                .padding(.leading, 12)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.kivoCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.kivoAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
