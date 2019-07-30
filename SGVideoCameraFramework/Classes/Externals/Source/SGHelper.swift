//
//  SGHelper.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/30/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import Foundation

public class SGHelper {
    
    public func shareVideo(_ url: URL, viewController: UIViewController) {
        let videoLink = NSURL(fileURLWithPath: url.absoluteString)
        let objectsToShare = [videoLink]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            let exportPath = NSTemporaryDirectory().appendingFormat("tmp.mov")
            self.deleteFileAt(exportPath)
            viewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func deleteFileAt(_ fileURL: String) {
        do {
            try FileManager.default.removeItem(atPath: fileURL)
        } catch {
            // No-op
        }
    }
    
}
