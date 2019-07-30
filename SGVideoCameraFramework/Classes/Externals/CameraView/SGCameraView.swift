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
    func sGCameraViewDidShare(_ videoUrl: URL)
}

public class SGCameraView: UIView, SGCameraManDelegate {
    
    public let cameraMan = SGCameraManual()
    
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
        backgroundColor = UIColor.red
    }
 
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    public func shareVideo(shareUrl: URL, viewComtroller: UIViewController) {
        let videoLink = NSURL(fileURLWithPath: shareUrl.absoluteString)
        let objectsToShare = [videoLink]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        viewComtroller.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            let exportPath = NSTemporaryDirectory().appendingFormat("tmp.mov")
            self.cameraMan.deleteFileAt(exportPath)
            viewComtroller.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupPreviewLayer() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraMan.session)
        
        layer.backgroundColor = UIColor.black.cgColor
        layer.autoreverses = true
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.layer.insertSublayer(layer, at: 0)
//        layer.frame = self.layer.frame
        layer.frame = self.layer.bounds
        self.clipsToBounds = true
        
        previewLayer = layer
    }
    
    
    // MARK: - Camera actions
    
    public func startRecordVideo() {
        cameraMan.recordVideo()
    }
    
    public func stopRecordVideo(_ completion: @escaping () -> Void) {
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
