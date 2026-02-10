//
//  CameraServiceView.swift
//  kivoai
//

import SwiftUI
import AVFoundation

struct CameraServiceView: View {
    @Binding var image: UIImage?
    var creditCost: Int? = nil
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraService = CameraService()
    @State private var isFlashOn = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppTheme.Colors.secondaryBackground))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    if let cost = creditCost {
                        HStack(spacing: 6) {
                            Text("🪙")
                                .font(.system(size: 14))
                            Text("\(cost) credits")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppTheme.Colors.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 40)
                        .background(Capsule().fill(AppTheme.Colors.secondaryBackground))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()

                // Camera Preview
                ZStack {
                    if cameraService.isPermissionGranted {
                        CameraPreview(session: cameraService.session)
                            .aspectRatio(3/4, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    } else {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(AppTheme.Colors.secondaryBackground)
                            .aspectRatio(3/4, contentMode: .fit)
                            .overlay {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(AppTheme.Colors.textQuaternary)
                                    Text("Camera access required")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(AppTheme.Colors.textQuaternary)
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Controls
                HStack(spacing: 36) {
                    // Placeholder for balance
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 52, height: 52)

                    // Capture Button - iOS-native shutter style
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        cameraService.capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(Color(uiColor: .systemGray3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(Color(white: 0.55))
                                .frame(width: 66, height: 66)
                        }
                    }
                    .buttonStyle(.plain)

                    // Switch Camera Button
                    Button {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        cameraService.switchCamera()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .frame(width: 52, height: 52)
                            .background(AppTheme.Colors.secondaryBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            cameraService.onPhotoCaptured = { capturedImage in
                self.image = capturedImage
                dismiss()
            }
            cameraService.checkPermissions()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }
}
