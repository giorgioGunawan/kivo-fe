//
//  FloatingCreateButton.swift
//  kivoai
//

import SwiftUI

struct FloatingCreateButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Pulse effect
                Circle()
                    .fill(Color.kivoAccent.opacity(0.3))
                    .frame(width: 70, height: 70)
                    .scaleEffect(pulseScale)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.kivoAccent, Color.kivoPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.kivoAccent.opacity(0.5), radius: 10, x: 0, y: 4)
                
                // Plus icon
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.15
            }
        }
    }
}

#Preview {
    ZStack {
        Color.kivoBackground.ignoresSafeArea()
        FloatingCreateButton(action: {})
    }
}
