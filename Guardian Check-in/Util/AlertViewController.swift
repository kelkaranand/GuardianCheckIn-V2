//
//  AlertViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 12/01/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

/**
    Custom AlertViewController class
 **/
class AlertViewController : UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var alertWindow: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBAction func buttonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //static variable to store the alert message
    static var msg = ""
    //static variable to store the icon image in the alert window
    static var img = ""
    
    override func viewDidLayoutSubviews() {
        alertWindow.layer.cornerRadius = 10
        alertWindow.layer.shouldRasterize = false
        alertWindow.layer.borderWidth = 1
        button.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        image.image = UIImage.init(named: AlertViewController.img)
        message.text = AlertViewController.msg
    }
    
}
