//
//  SGCameraViewController.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/26/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import UIKit
import Photos

public class SGCameraViewController: UIViewController {

    @IBOutlet weak var cameraView: SGCameraView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    
    private var startRecordTime: TimeInterval = 0.0
    private var frameRateTypes: FrameRates?
    
    private var minutes = 0
    private var seconds = 0
    private weak var timer: Timer?
    
    public var recordingTime: Double?
    public var frameRate: Double?
    
    // MARK: - Intance intialization
    
    public init() {
        super.init(nibName: "SGCameraViewController", bundle: Bundle(for: SGCameraViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        cameraView.cameraMan.recordingTime = recordingTime
        cameraView.cameraMan.frameRate = frameRateTypes
    }
    
    
    // MARK: - Action methods
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        userDidTapRecordButton()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        cameraView.delegate = self
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        timerLabel.textColor = UIColor.white
    }
    
    private func timerTick(){
        seconds += 1
        
        if seconds == 60{
            seconds = 0
            minutes += 1
        }
        
        if Double(seconds) == recordingTime {
            stopTimer()
            cameraView.stopRecordVideo {
            }
        }
        
        let timeNow = String(format: "%02d:%02d", minutes, seconds)
        timerLabel.text = timeNow
    }
    
    private func  stopTimer() {
        timer?.invalidate()
    }
    
    private func startRecordingTime() {
        timerLabel.isHidden = false
        let timeNow = String(format: "%02d:%02d", minutes, seconds)
        timerLabel.text = timeNow
        
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
        
    }
    
    private func userDidTapRecordButton() {
        if cameraView.isRecordingVideo {
            cameraView.stopRecordVideo {
            }
            stopTimer()
        } else {
            cameraView.startRecordVideo()
            startRecordingTime()
        }
    }
    
    private func shareVideo(_ assetId: [String], shareUrl: URL) {
        let videoLink = NSURL(fileURLWithPath: shareUrl.absoluteString)
        let objectsToShare = [videoLink]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            PHPhotoLibrary.shared().performChanges( {
                let imageAssetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: assetId, options: nil)
                PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
                print(imageAssetToDelete)
            }, completionHandler: { success, error in
                if success {
                    print("success")
                } else {
                    print("error")
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SGCameraViewController: SGCameraViewDelegate {
    func shareVideo(_ url: URL, assetId: String) {
        shareVideo([assetId], shareUrl: url)
    }
}
