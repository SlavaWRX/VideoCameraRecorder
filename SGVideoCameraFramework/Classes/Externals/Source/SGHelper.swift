//
//  SGHelper.swift
//  SGVideoCameraFramework
//
//  Created by Viacheslav Goroshniuk on 7/30/19.
//  Copyright © 2019 Viacheslav Goroshniuk. All rights reserved.
//

import Foundation

public class SGHelper {
    
    public static func shareVideo(_ url: URL, viewController: UIViewController, completion: @escaping () -> Void) {
        let videoLink = NSURL(fileURLWithPath: url.absoluteString)
        let objectsToShare = [videoLink]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        viewController.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            let exportPath = NSTemporaryDirectory().appendingFormat("tmp.mov")
            deleteFileAt(exportPath)
            completion()
        }
    }
    
    static func deleteFileAt(_ fileURL: String) {
        do {
            try FileManager.default.removeItem(atPath: fileURL)
        } catch {
            // No-op
        }
    }
    
}
