//
//  LaunchViewController.swift
//  GuardianApp
//
//  Created by Anand Kelkar on 21/10/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LaunchViewController : UIViewController {
    
    @IBOutlet var animatedView: UIView!
    
    let imagelayer=CALayer()
    
    //Global identifier and key to use in api calls
    static var key : String?
    static var identifier : String?
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        //fetchData will be replaced by a api call that uses the student id to return guardians
        fetchData()
        generateLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        imagelayer.position=animatedView.center
    }
    
    func getRegKey(identifier : String) -> String {
        let url = URL(string: RestHelper.urls["Get_Registration_Key"]!)!
        let params = ["identifier":identifier] as Dictionary<String,String>
        var response = RestHelper.makePost(url, params)
        //Trim starting and ending "
        response.removeFirst()
        response.removeLast()
        return response
    }
    
    func generateLogo()
    {
        imagelayer.frame=animatedView.bounds
        animatedView.layer.addSublayer(imagelayer)
        imagelayer.contents = UIImage(named: "LJFF_LOGO_W")?.cgImage
        imagelayer.contentsGravity = CALayerContentsGravity.resizeAspect
        imagelayer.backgroundColor=UIColor.black.cgColor
        imagelayer.shadowOpacity = 0.7
        imagelayer.shadowRadius = 10.0
        imagelayer.cornerRadius = imagelayer.frame.width/2
        imagelayer.isHidden = false
        imagelayer.masksToBounds = false
        animatedView.alpha = 0.0
        
        UIView.animate(withDuration: 2.0, animations: {
            self.animatedView.alpha = 1.0
        }, completion: { finished in
            
            UIView.animate(withDuration: 2.0, animations: {
                self.animatedView.alpha = 0
            }, completion: { finished in
                //Read device data
                let coreData = CoreDataHelper.retrieveData("Device_Info")
                let data = coreData.first
                
                LaunchViewController.key = (data as AnyObject).value(forKey: "key") as? String
                LaunchViewController.identifier = (data as AnyObject).value(forKey: "identifier") as? String
                
                if LaunchViewController.identifier == nil {
                    self.performSegue(withIdentifier: "CheckRegistration", sender: self)
                }
                    
                else if LaunchViewController.key == nil {
                    let responseKey = self.getRegKey(identifier: LaunchViewController.identifier!)
                    if responseKey == "Not Authorized" {
                        let registrationAlert = UIAlertController(title: "Not Authorized", message: "Your device registration has not yet been approved. Please wait till device \""+LaunchViewController.identifier!+"\" is verified.", preferredStyle: .alert)
                        registrationAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(registrationAlert, animated: true)
                    }
                    else {
                        self.writeKey(key: responseKey)
                        print("Wrote key "+responseKey)
                        self.performSegue(withIdentifier: "ShowList", sender: self)
                    }
                }
                else {
                    //Move to Landing
                    self.performSegue(withIdentifier: "ShowList", sender: self)
                }
            })
        })
        
        
    }
    
    func writeKey(key : String) {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        //Get device info
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Device_Info")
        do{
            let temp = try managedContext.fetch(fetchRequest).first
            temp?.setValue(key, forKey: "key")
            try managedContext.save()
            LaunchViewController.key = key
        }
        catch _ as NSError {
            print("Error writing key to core data")
        }
    }
    
    private func fetchData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //Student data from coredata
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        
        do {
            let results = try context.fetch(fetchRequest)
            let students = results as! [Student]
            
            for student in students {
                SearchStudentViewController.studentRecords.append(StudentRecord(student.fname!, student.lname!, student.id!))
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
        //Locations data from coredata
        let locationsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        
        do {
            let results = try context.fetch(locationsFetchRequest)
            let locations = results as! [Location]
            
            for location in locations {
                SetupViewController.locations.append(LocationRecord(location.name!, location.options!, location.guardianCheck))
            }
            
        }catch let err as NSError {
            print(err.debugDescription)
        }
        //Setup location from coredata
        let setupLocationFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Setup_Info")
        
        do {
            let results = try context.fetch(setupLocationFetchRequest)
            if(results.count>0){
                let setupLocation = results[0] as AnyObject
                let temp = setupLocation.value(forKey: "location") as! String
                
                if temp != nil {
                    CoreDataHelper.locationName = temp
                    CoreDataHelper.locationGuardianFlag = setupLocation.value(forKey: "guardianCheckin") as! Bool
                    CoreDataHelper.locationOptions = setupLocation.value(forKey: "options") as! String
                }
            }
                //If setup info entry is not created, create a dummy one
            else {
                guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let descrEntity = NSEntityDescription.entity(forEntityName: "Setup_Info", in: managedContext)!
                let obj = NSManagedObject(entity: descrEntity, insertInto: managedContext)
                obj.setValue("", forKey: "location")
                obj.setValue("", forKey: "options")
                obj.setValue(false, forKey: "guardianCheckin")
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
}
