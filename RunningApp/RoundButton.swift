//
//  RoundButton.swift
//  RunningApp
//
//  Created by Mohammad Shayan on 4/29/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    func customizeView() {
        
        self.imageView?.contentMode = .scaleAspectFit
        
        //MARK: Corner Radius
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}
