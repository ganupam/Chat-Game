//
//  ImageVideoPicker.swift
//  Chat Game Demo
//
//  Created by Anupam Godbole on 4/18/23.
//

import Foundation
import UIKit
import PhotosUI

class ImageVideoPicker {
    private static var delegate: ImageVideoPickerDelegate?
    
    class func presentImagePicker(on viewController: UIViewController, completionHandler: @escaping ([PHPickerResult]) -> Void) {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.overrideUserInterfaceStyle = .dark
        picker.view.tintColor = .primary
        Self.delegate = ImageVideoPickerDelegate() { results in
            picker.dismiss(animated: true) {
                completionHandler(results)
                Self.delegate = nil
            }
        }
        picker.delegate = Self.delegate
        picker.presentationController?.delegate = Self.delegate
        viewController.present(picker, animated: true)
    }
}

extension ImageVideoPicker {
    private final class ImageVideoPickerDelegate: NSObject, PHPickerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
        private let completionHandler: ([PHPickerResult]) -> Void
        
        init(completionHandler: @escaping ([PHPickerResult]) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.completionHandler(results)
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.completionHandler([])
        }
    }
}
