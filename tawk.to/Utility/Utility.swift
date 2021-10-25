
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

extension UIView {
    func drawBorder() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
    }
}

//Utilities
class Utility {
    static func showAlert(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
