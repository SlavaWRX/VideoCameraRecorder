//
//  ViewController.swift
//  CameraFrameworkTest
//
//  Created by Viacheslav Goroshniuk on 7/25/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import SGVideoCameraFramework
import UIKit

enum SegmentType {
    case viewController
    case view
}


class CameraViewController: UIViewController {
    
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var openCameraButton: UIButton!
    @IBOutlet weak var cameraView: SGCameraView!
    
    private (set) var topSegmentControll: [SegmentType] = [.viewController, .view]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.isHidden = true
    }

    @IBAction func segmentControllDidTap(_ sender: Any) {
        let type = topSegmentControll[segmentControll.selectedSegmentIndex]
        switch type {
        case .viewController:
            openCameraButton.isHidden = false
            cameraView.isHidden = true
        case .view:
            openCameraButton.isHidden = true
            cameraView.isHidden = false
        }
    }
    
    @IBAction func openCameraButtonTapped(_ sender: Any) {
        let sgCameraView = SGCameraViewController()
        sgCameraView.recordingTime = 5.0
        sgCameraView.frameRate = 30
        present(sgCameraView, animated: true, completion: nil)
    }
    
    
    
}

