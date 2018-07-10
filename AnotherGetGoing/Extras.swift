//
//  Extras.swift
//  AnotherGetGoing
//
//  Created by YIfan Yin on 2018-07-09.
//  Copyright © 2018 Alla Bondarenko. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func displayAlertView(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
