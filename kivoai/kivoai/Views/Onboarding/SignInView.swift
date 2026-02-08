//
//  SignInView.swift
//  kivoai
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    var onSignInSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Icon / Logo Placeholder
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient.accentGradient)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
                .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Text("Kivo AI")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
            }
            
            VStack(spacing: 12) {
                Text("Sign in to continue")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text("Save your generations and sync your credits across all your devices.")
                    .font(.system(size: 16))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Apple Sign In Button
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                handleAuthorization(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 54)
            .clipShape(Capsule())
            .padding(.horizontal, 32)
            
            Button {
                dismiss()
            } label: {
                Text("Not now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
        }
        .padding()
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
    
    private func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            Task {
                do {
                    try await authManager.completeSignInWithApple(authorization: authorization)
                    if authManager.isAuthenticated {
                        onSignInSuccess()
                    }
                } catch {
                    print("Auth exchange failed: \(error.localizedDescription)")
                }
            }
            
        case .failure(let error):
            print("Auth failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SignInView(onSignInSuccess: {})
        .environmentObject(AuthManager())
}
