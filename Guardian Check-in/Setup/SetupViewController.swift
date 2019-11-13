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
import CoreData

class SetupViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lockBack: UIImageView!
    @IBOutlet weak var lockFront: UIImageView!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var light1: UIImageView!
    @IBOutlet weak var light2: UIImageView!
    @IBOutlet weak var light3: UIImageView!
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var setLocationButton: UIView!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var lockStatusImage: UIImageView!
    @IBOutlet weak var superSecretMessage: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var downloadDataButton: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    var lastRotation:CGFloat = 0
    var rotation:CGFloat = 0
    var counter = 0
    
    var check1 = false
    var check2 = false
    var check3 = false
    
    var lockFlag = true
    
    var lockStatus = true
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        mainCardView.layer.cornerRadius = 10
        mainCardView.layer.shouldRasterize = false
        mainCardView.layer.borderWidth = 1
        
        separatorView.layer.shouldRasterize = false
        separatorView.layer.borderWidth = 1
        
        downloadDataButton.layer.cornerRadius = 10
        downloadDataButton.layer.shouldRasterize = false
        downloadDataButton.layer.borderWidth = 1
        
        setLocationButton.layer.cornerRadius = 10
        setLocationButton.layer.shouldRasterize = false
        setLocationButton.layer.borderWidth = 1
        
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shouldRasterize = false
        shadowView.layer.borderWidth = 1
        
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        
        //Hide test label
        testLabel.isHidden = true
        
        //Rotation gesture for the lock
        let rotateLock = UIRotationGestureRecognizer(target: self, action: #selector(rotateLock(_:)))
        self.view.addGestureRecognizer(rotateLock)
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        mainCardView.addGestureRecognizer(rightSwipe)
        
        //Swipe right to go back
        let rightSwipeOnLockScreen = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeLock))
        rightSwipeOnLockScreen.direction = .right
        lockView.addGestureRecognizer(rightSwipeOnLockScreen)
        
        //Tap for set location button
        setLocationButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setLocation)))
        
        //Tap to toggle lock status
        lockStatusImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(lockStatusToggle)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        readLockStatus()
        if !lockStatus {
            lockView.isHidden = true
            lockFlag = false
            lockStatusImage.image = UIImage(named: "unlocked")
            superSecretMessage.text = "Super secret lock inactive"
        }
        else {
            lockView.isHidden = false
            lockFlag = true
            lockStatusImage.image = UIImage(named: "locked")
            superSecretMessage.text = "Super secret lock active"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CoreDataHelper.allLocations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CoreDataHelper.allLocations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Chalkboard SE", size: 20)
        label.text =  CoreDataHelper.allLocations[row]
        label.textAlignment = .center
        return label
    }
    
    @objc func setLocation(){
        let selectedIndex = locationPicker.selectedRow(inComponent: 0)
        CoreDataHelper.locationName = CoreDataHelper.allLocations[selectedIndex]
        CoreDataHelper.locationGuardianFlag = CoreDataHelper.allGuardianFlags[selectedIndex]
        CoreDataHelper.locationOptions = CoreDataHelper.allOptions[selectedIndex]
        writeLocationToCoreData()
        print("location set")
    }
    
    func writeLocationToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Setup_Info")
        do {
            let setupObj = try managedContext.fetch(fetchRequest)
            let objectUpdate = setupObj.first as! NSManagedObject
            objectUpdate.setValue(CoreDataHelper.locationName, forKey: "location")
            objectUpdate.setValue(CoreDataHelper.locationOptions, forKey: "options")
            objectUpdate.setValue(CoreDataHelper.locationGuardianFlag, forKey: "guardianCheckin")
            do{
                try managedContext.save()
                print("Location Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func readLockStatus() {
        let coreData = CoreDataHelper.retrieveData("Device_Info")
        let data = coreData.first
        let temp = (data as AnyObject).value(forKey: "lock") as? Bool
        
        if temp == nil || !temp! {
            lockStatus = false
        }
        else {
            lockStatus = true
        }
        
    }
    
    @objc func lockStatusToggle() {
        print("lock pressed")
        if lockStatus {
            lockStatusImage.image = UIImage(named: "unlocked")
            superSecretMessage.text = "Super secret lock inactive"
            lockFlag = false
            saveLockStatus(false)
        }
        else {
            lockStatusImage.image = UIImage(named: "locked")
            superSecretMessage.text = "Super secret lock active"
            lockFlag = true
            saveLockStatus(true)
        }
    }
    
    func saveLockStatus(_ status:Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Device_Info")
        do {
            let DeviceInfoObj = try managedContext.fetch(fetchRequest)
            let objectUpdate = DeviceInfoObj[0] as! NSManagedObject
            objectUpdate.setValue(status, forKey: "lock")
            do{
                try managedContext.save()
                print("Lock Updated!")
            }catch{
                print(error)
            }
        } catch {
            print(error)
        }
        
    }
    
    @objc func rightSwipeLock() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.shadowView.center.x = self.shadowView.center.x + self.view.bounds.width
            self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
        }, completion: { finished in
            self.navigationController?.popViewController(animated: false)
        })
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
