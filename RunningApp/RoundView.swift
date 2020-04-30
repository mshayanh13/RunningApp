//
//  RoundView.swift
//  RunningApp
//
//  Created by Mohammad Shayan on 4/30/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

@IBDesignable
class RoundErrorView: UIView {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    func customizeView() {
        
        //MARK: Corner Radius
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        
        //MARK: Shadow
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setErrorMessageLocationAlways() {
        errorMessageLabel.text = "For this app to work\n" +
                "Please go to Setttings\n" +
                "Then Privacy\n" +
                "Then Location Services\n" +
                "Then Running App\n" +
                "Then Select Always"
    }
    
    func setErrorMessageLocationNotFound() {
        errorMessageLabel.text = "Location not found"
    }
    
    func setErrorMessage(_ message: String) {
        errorMessageLabel.text = message
    }
}
