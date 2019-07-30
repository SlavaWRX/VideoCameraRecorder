//
//  SGCameraManual.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/26/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import Foundation
import PhotosUI

private let kCameraRecordingTimeKey = "kCameraRecordingTimeKey"

enum FrameRates: Double {
    case thirty = 30
    case sixty = 60
}

protocol SGCameraManDelegate: class {
    func cameraManNotAvailable(_ cameraMan: SGCameraManual)
    func cameraManDidStart(_ cameraMan: SGCameraManual)
    func cameraManDidCompleteRecord(_ url: URL)
}

public class SGCameraManual: NSObject {
    weak var delegate: SGCameraManDelegate?
    
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "no.hyper.ImagePicker.Camera.SessionQueue")
    private var videoCompletion: ((PHAsset?) -> Void)?
    private var backCamera: AVCaptureDeviceInput?
    private var frontCamera: AVCaptureDeviceInput?
    private var stillCameraCaptureOutput: AVCaptureVideoDataOutput?
    var stillVideoOutput: AVCaptureMovieFileOutput?
    
    var startOnFrontCamera: Bool = false
    
    var recordingTime: Double? {
        didSet {
            updateRecordTime()
        }
    }
    
    var frameRate: FrameRates? {
        didSet {
            updateFrameRate()
        }
    }
    
    deinit {
        stop()
    }
    
    
    // MARK: - Setup
    
    func setup(_ startOnFrontCamera: Bool = false) {
        self.startOnFrontCamera = startOnFrontCamera
        checkPermission()
    }
    
    private func addInput(_ input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }
    
    
    // MARK: - Permission
    
    private func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch status {
        case .authorized:
            start()
        case .notDetermined:
            requestPermission()
        default:
            delegate?.cameraManNotAvailable(self)
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.start()
                } else {
                    self.delegate?.cameraManNotAvailable(self)
                }
            }
        }
    }
    
    
    // MARK: - Session
    
    private var currentInput: AVCaptureDeviceInput? {
        return session.inputs.first as? AVCaptureDeviceInput
    }
    
    private func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let captureDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        for device in captureDeviceDiscoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    private func updateRecordTime() {
        if let recordTime = recordingTime {
            stillVideoOutput?.maxRecordedDuration = CMTime(seconds: recordTime, preferredTimescale: 180)
        } else {
            stillVideoOutput?.maxRecordedDuration = CMTime.positiveInfinity
        }
    }
    
    private func updateFrameRate() {
        let newCameraDevice = self.camera(with: .back)
        if let frameRate = frameRate {
            newCameraDevice?.set(frameRate: frameRate.rawValue)
        } else {
            newCameraDevice?.set(frameRate: 30)
        }
    }
    
    public func start() {
        // Devices
        
        let newCameraPosition: AVCaptureDevice.Position = self.startOnFrontCamera ? .front : .back
        let newCameraDevice = self.camera(with: newCameraPosition)
        guard let input = try? AVCaptureDeviceInput(device: newCameraDevice!) else {
            return
        }
        
        // Inputs
        
        addInput(input)
        
        // Outputs
        
        stillVideoOutput = AVCaptureMovieFileOutput()
        
        updateRecordTime()
        updateFrameRate()
        
        stillCameraCaptureOutput = AVCaptureVideoDataOutput()
        stillCameraCaptureOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA] as? [String : Any]
        stillCameraCaptureOutput?.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        if let videoOutput = stillVideoOutput,
            session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        if let audioDevice = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
            session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        queue.async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.delegate?.cameraManDidStart(self)
            }
        }
    }
    
    private func stop() {
        self.session.stopRunning()
    }
    
    func recordVideo() {
        if let videoOutput = stillVideoOutput,
            session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let filePath = tmpURL.appendingPathComponent("temp.mov")
        
        stillVideoOutput?.startRecording(to: filePath,
                                         recordingDelegate: self)
        AudioServicesPlaySystemSound(1117)
    }
    
    func stopVideoRecording() {
        guard let stillVideoOutput = stillVideoOutput,
            stillVideoOutput.isRecording else {
                return
        }
        stillVideoOutput.stopRecording()
        AudioServicesPlaySystemSound(1118)
    }
}

extension SGCameraManual: AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        delegate?.cameraManDidCompleteRecord(outputFileURL)
    }
}

extension AVCaptureDevice {
    func set(frameRate: Double) {
        guard let range = activeFormat.videoSupportedFrameRateRanges.first,
            range.minFrameRate...range.maxFrameRate ~= frameRate
            else {
                print("Requested FPS is not supported by the device's activeFormat !")
                return
        }
        
        do { try lockForConfiguration()
            activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
            unlockForConfiguration()
        } catch {
            print("LockForConfiguration failed with error: \(error.localizedDescription)")
        }
    }
}
