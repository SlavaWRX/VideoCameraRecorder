//
//  SGCameraView.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/26/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import Foundation
import Photos

protocol SGCameraViewDelegate: class {
    func sGCameraViewDidShare(_ videoUrl: URL)
}

public class SGCameraView: UIView, SGCameraManDelegate {
    
    public let cameraMan = SGCameraManual()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: SGCameraViewDelegate?
    var startOnFrontCamera: Bool = false
    var isRecordingVideo: Bool {
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
        
        
        previewLayer?.connection?.videoOrientation = .portrait
    }
    
    func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session)
        
        layer.backgroundColor = UIColor.black.cgColor
        layer.autoreverses = true
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.layer.insertSublayer(layer, at: 0)
        layer.frame = self.layer.frame
        self.clipsToBounds = true
        
        previewLayer = layer
    }
    
    
    // MARK: - Camera actions
    
    func startRecordVideo() {
        cameraMan.recordVideo()
    }
    
    func stopRecordVideo(_ completion: @escaping () -> Void) {
        cameraMan.stopVideoRecordingAndSaveToLibrary { _ in
            completion()
        }
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
    
    func cameraManShareVideo(_ url: URL) {
        delegate?.sGCameraViewDidShare(url)
    }
}
