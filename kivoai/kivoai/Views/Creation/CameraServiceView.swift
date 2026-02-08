//
//  CameraServiceView.swift
//  kivoai
//

import SwiftUI
import AVFoundation

struct CameraServiceView: View {
    @Binding var image: UIImage?
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
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.Colors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(AppTheme.Colors.secondaryBackground))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.leading, 32)
                .padding(.trailing, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Camera Preview
                ZStack {
                    if cameraService.isPermissionGranted {
                        CameraPreview(session: cameraService.session)
                            .aspectRatio(3/4, contentMode: .fill)
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
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Controls - Standardized with CustomCreationSheet
                HStack(spacing: 0) {
                    // Placeholder for balance
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 52, height: 52)
                    
                    Spacer()
                    
                    // Capture Button - Modern Premium Style
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        cameraService.capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.55, green: 0.25, blue: 0.9),
                                            Color(red: 0.4, green: 0.1, blue: 0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.purple.opacity(0.35), radius: 12, x: 0, y: 6)
                            
                            Circle()
                                .stroke(.white, lineWidth: 3)
                                .frame(width: 66, height: 66)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Switch Camera Button - Moved here from top
                    Button {
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
                .padding(.horizontal, 40)
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
