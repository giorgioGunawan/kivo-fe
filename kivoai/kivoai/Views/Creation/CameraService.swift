//
//  CameraService.swift
//  kivoai
//
//  Simplified, high-performance camera service.
//

import AVFoundation
import SwiftUI
import Combine
class CameraService: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    @Published var isPermissionGranted = false
    
    private let sessionQueue = DispatchQueue(label: "com.kivoai.camera.session")
    private var isConfigured = false
    private var currentPosition: AVCaptureDevice.Position = .back
    
    // Callback for captured photo
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isPermissionGranted = true
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isPermissionGranted = granted
                }
                if granted {
                    self.configureSession()
                }
            }
        default:
            isPermissionGranted = false
        }
    }
    
    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            #if targetEnvironment(simulator)
            return
            #endif
            
            guard !self.isConfigured else {
                self.startSession()
                return
            }
            
            self.session.beginConfiguration()
            // Ensure commitConfiguration is always called at end of block
            defer { self.session.commitConfiguration() }
            
            self.session.sessionPreset = .photo
            
            do {
                // DiscoverySession to find the best available camera
                let discoverySession = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera],
                    mediaType: .video,
                    position: self.currentPosition
                )
                
                guard let device = discoverySession.devices.first else {
                    print("Error: No camera device found")
                    return
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    print("Error: Cannot add camera input")
                }
                
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                
                self.isConfigured = true
                
                // Start session after configuration is committed
                // Since this enqueues to the same serial queue, it will run after this block returns (and defer executes)
                self.startSession()
                
            } catch {
                print("Error configuring camera: \(error)")
            }
        }
    }
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            #if targetEnvironment(simulator)
            return
            #endif
            
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async { [weak self] in
            if self?.session.isRunning == true {
                self?.session.stopRunning()
            }
        }
    }
    
    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }
            
            if let currentInput = self.session.inputs.first as? AVCaptureDeviceInput {
                self.session.removeInput(currentInput)
            }
            
            self.currentPosition = (self.currentPosition == .back) ? .front : .back
            
            do {
                let discoverySession = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTripleCamera],
                    mediaType: .video,
                    position: self.currentPosition
                )
                
                guard let newDevice = discoverySession.devices.first else {
                    return
                }
                
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                }
            } catch {
                print("Error switching camera: \(error)")
            }
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let finalImage: UIImage
            if self.currentPosition == .front, let cgImage = image.cgImage {
                finalImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .leftMirrored)
            } else {
                finalImage = image
            }
            
            self.onPhotoCaptured?(finalImage)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        if let view = uiView as? VideoPreviewView {
            view.videoPreviewLayer.session = nil
        }
    }
}

class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
