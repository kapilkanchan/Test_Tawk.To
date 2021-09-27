//
//  Utility.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 26/09/21.
//

import UIKit.UIImageView

extension UIImageView {
    func invertImageColors() {
        guard self.image != nil else {
            return
        }
        let beginImage = CIImage(image: self.image!)
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            if filter.outputImage != nil {
                let newImage = UIImage(ciImage: filter.outputImage!)
                self.image = newImage
            }
        }
    }
}

class Utility {
    static func showAlert(viewController: UIViewController) {
        let alert = UIAlertController.init(title: "Unreachable connectivity", message: "No Internet connection, could not refresh data", preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        alert.present(viewController, animated: true, completion: nil)
    }
}
