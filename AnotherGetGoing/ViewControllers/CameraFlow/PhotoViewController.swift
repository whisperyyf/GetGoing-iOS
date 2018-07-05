//
//  PhotoViewController.swift
//  GetGoing
//
//  Created by Alla Bondarenko on 2018-03-23.
//  Copyright © 2018 IBM Canada Ltd. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var photo: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo
    }
    
    @IBAction func savePhoto(_ sender: UIButton) {
        if let photo = photo {
            UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
        }
    }
    
}
