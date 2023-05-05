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
    
    class func presentImagePicker(on viewController: UIViewController, allowMultipleSelection: Bool = false, completionHandler: @escaping ([PHPickerResult]) -> Void) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = allowMultipleSelection ? 0 : 1
        let picker = PHPickerViewController(configuration: config)
        picker.overrideUserInterfaceStyle = .dark
        picker.view.tintColor = Asset.Colors.primary.color
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

extension Array where Element == PHPickerResult {
    func images(imageHandler: @escaping (UIImage?) -> Void) {
        for result in self {
            result.image(imageHandler: imageHandler)
        }
    }
}

extension PHPickerResult {
    func image(imageHandler: @escaping (UIImage?) -> Void) {
        guard self.itemProvider.canLoadObject(ofClass: UIImage.self) else { imageHandler(nil); return }
        
        self.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            DispatchQueue.main.async {
                guard let image = image as? UIImage, error == nil else { imageHandler(nil); return }

                imageHandler(image)
            }
        }
    }
}
