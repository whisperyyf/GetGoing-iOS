//
//  RatingControl.swift
//  GetGoing
//
//  Created by Alla Bondarenko on 2018-02-24.
//  Copyright © 2018 IBM Canada Ltd. All rights reserved.
//

import Foundation
import UIKit

class RatingControl: UIStackView {
    //MARK: Properties
    private var ratingButtons = [UIButton]()
    public var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
    private func setupButtons(){
        // Clear any existing buttons
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load Button Images
        let filledStar = #imageLiteral(resourceName: "StarFull")
        let emptyStar = #imageLiteral(resourceName: "StarEmpty")
        
        for _ in 0..<5 {
            let button = UIButton()
            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(filledStar, for: .highlighted)
            button.setImage(filledStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
    }
    
}
