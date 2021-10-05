//
//  Utility.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 26/09/21.
//

import UIKit.UIImageView

// protocol oriented approach for implementing generic function
protocol CoreData_Network_Protocol {
    func getId() -> Int
}

extension User: CoreData_Network_Protocol {
    func getId() -> Int {
        return self.id
    }
}

extension Users_DB: CoreData_Network_Protocol {
    func getId() -> Int {
        return Int(self.id)
    }
}
//

protocol cellProtocol {
    
}

extension UIImageView {
    func roundImage() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
    }
    
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

