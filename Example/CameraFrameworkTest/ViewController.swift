//
//  ViewController.swift
//  CameraFrameworkTest
//
//  Created by Viacheslav Goroshniuk on 7/25/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import SGVideoCameraFramework
import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openCameraButtonTapped(_ sender: Any) {
        let sgCameraView = SGCameraViewController()
        sgCameraView.recordingTime = 5.0
        sgCameraView.frameRate = 30
        present(sgCameraView, animated: true, completion: nil)
    }
    
}

