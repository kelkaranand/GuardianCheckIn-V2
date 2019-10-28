//
//  SetupViewController.swift
//  GuardianApp
//
//  Created by Anand Kelkar on 21/10/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class SetupViewController : UIViewController {
    @IBOutlet weak var lockBack: UIImageView!
    @IBOutlet weak var lockFront: UIImageView!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var light1: UIImageView!
    @IBOutlet weak var light2: UIImageView!
    @IBOutlet weak var light3: UIImageView!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var lastRotation:CGFloat = 0
    var rotation:CGFloat = 0
    var counter = 0
    
    var check1 = false
    var check2 = false
    var check3 = false
    
    var lockFlag = true
    
    override func viewDidLoad() {
        
        //Hide test label
        testLabel.isHidden = true
        
        lockFlag = true
        
        //Rotation gesture for the lock
        let rotateLock = UIRotationGestureRecognizer(target: self, action: #selector(rotateLock(_:)))
        self.view.addGestureRecognizer(rotateLock)
    }
    
    //Start - Lock rotation and value calculation
    @objc func rotateLock(_ sender: UIRotationGestureRecognizer) {
        if lockFlag {
            counter = counter + 1
            if(sender.state == .began){
                rotation = rotation + lastRotation
            } else if(sender.state == .changed){
                let newRotation = sender.rotation + rotation
                self.lockFront.transform = CGAffineTransform(rotationAngle: newRotation)
                if (counter > 10){
                    AudioServicesPlaySystemSoundWithCompletion(1157,nil)
                    counter = 0
                }
            } else if(sender.state == .ended) {
                lastRotation = sender.rotation
                let dialValue = getLockValue(lockRotation: rotation+lastRotation)
                testLabel.text = String(dialValue)
                checkLock(dialValue)
            }
        }
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    
    func getLockValue(lockRotation:CGFloat) -> Int {
        var deg = rad2deg(Double(lockRotation))
        deg = deg.truncatingRemainder(dividingBy: 360)
        var integer = Int(deg/3.6)
        print(integer)
        if(integer < 0){
            integer = integer * -1
        }
        else if(integer > 0) {
            integer = 100 - integer
        }
        return integer
    }
    //End - Lock rotation and value calculation
    
    //Lock code evaluation
    //Code is 40 right, 80 left, 20 right
    func checkLock(_ value:Int){
        if !check1 {
            if value>38 && value<42 {
                light1.image = UIImage(named: "green.png")
                check1 = true
            }
        }
        else if !check2 {
            if value>45 && value<78 {
                light1.image = UIImage(named: "red.png")
                check1 = false
            }
            else if value>78 && value<82 {
                light2.image = UIImage(named: "green.png")
                check2 = true
            }
        }
        else if !check3 {
            if value>22 && value<78 {
                light1.image = UIImage.init(named: "red.png")
                light2.image = UIImage.init(named: "red.png")
                check1=false
                check2=false
            }
            if value>18 && value<22 {
                light3.image = UIImage.init(named: "green.png")
                check3 = true
            }
        }
        if check1 && check2 && check3 {
            openLock()
        }
    }
    
    func openLock() {
        UIView.transition(from: lockView, to: contentView, duration: 1.0, options: UIView.AnimationOptions.transitionFlipFromRight, completion: { finished in
            self.lockFlag = false
        }
        )
    }
    
    
}
