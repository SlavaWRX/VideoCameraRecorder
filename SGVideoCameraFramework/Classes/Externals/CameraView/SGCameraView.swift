//
//  SGCameraView.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/26/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import Foundation
import Photos

public protocol SGCameraViewDelegate: class {
    func sGCameraViewDidCompleteRecord(_ videoUrl: URL)
}

public class SGCameraView: UIView, SGCameraManDelegate {
    
    public let cameraMan = SGCameraManual()
    public let helper = SGHelper()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    public weak var delegate: SGCameraViewDelegate?
    var startOnFrontCamera: Bool = false
    public var isRecordingVideo: Bool {
        return cameraMan.stillVideoOutput?.isRecording ?? false
    }
    
    
    // MARK: - Override methods
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        cameraMan.delegate = self
        cameraMan.setup(self.startOnFrontCamera)
        backgroundColor = UIColor.black
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        previewLayer?.frame = self.layer.bounds
    }
    
    func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session)
        
        layer.backgroundColor = UIColor.black.cgColor
        layer.autoreverses = true
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.layer.insertSublayer(layer, at: 0)
        layer.frame = self.layer.bounds
        self.clipsToBounds = true
        
        previewLayer = layer
    }
    
    
    // MARK: - Camera actions
    
    public func recordButtonTapped() {
        if isRecordingVideo {
            stopRecordVideo {
            }
        } else {
            startRecordVideo()
        }
    }
    
    public func startRecordVideo() {
        cameraMan.recordVideo()
    }
    
    public func stopRecordVideo(_ completion: @escaping () -> Void) {
        cameraMan.stopVideoRecording()
    }
    
    
    // MARK: - Private helpers
    
    func showNoCamera(_ show: Bool) {
        // error if user did not give permission for camera
    }
    
    
    // CameraManDelegate
    func cameraManNotAvailable(_ cameraMan: SGCameraManual) {
        showNoCamera(true)
    }
    
    func cameraManLibraryNotAvailable(_ cameraMan: SGCameraManual) {
        // error if user did not give permission for library
    }
    
    func cameraManDidStart(_ cameraMan: SGCameraManual) {
        setupPreviewLayer()
    }
    
    func cameraManDidCompleteRecord(_ url: URL) {
        delegate?.sGCameraViewDidCompleteRecord(url)
    }
}
