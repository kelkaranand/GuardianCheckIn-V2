//
//  CoreDataHelper.swift
//  CheckIn
//
//  Created by Alexander Stevens on 1/8/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import CoreData
import Foundation
import UIKit

/**
    The class was created to make the core data operations easier.
 **/
public class CoreDataHelper {
    
    //static variable to store names of all locations
    static var allLocations = [String]()
    //static variable to store all options for all the location
    static var allOptions = [String]()
    //static variable to store guardian indicators for all the stored locations
    static var allGuardianFlags = [Bool]()
    //static variable to store the selected location name
    static var locationName = ""
    //static variable to store the options for the selection location
    static var locationOptions = ""
    //static variable to store the guardian flag for the selected location
    static var locationGuardianFlag = true
    static var selectedStudentApi = ""
    
    /**
        Function to get the count of a given core data entity
    **/
    class func countOfEntity(_ entityName: String) -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        return try! managedContext.count(for: fetchRequest)
    }
    
    /**
        Function to save student data in core data
    **/
    class func saveStudentData(_ jsonObj: [String:String], _ entityName: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let descrEntity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        let obj = NSManagedObject(entity: descrEntity, insertInto: managedContext)
        obj.setValue(jsonObj["FirstName"], forKey: "fname")
        obj.setValue(jsonObj["APS_Student_ID"], forKey: "id")
        obj.setValue(jsonObj["LastName"], forKey: "lname")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
        Function to store the location data in core data
     **/
    class func saveLocationData(_ name:String,_ options:String,_ guardianCheck:Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let descrEntity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
        let obj = NSManagedObject(entity: descrEntity, insertInto: managedContext)
        obj.setValue(name, forKey: "name")
        obj.setValue(options, forKey: "options")
        obj.setValue(guardianCheck, forKey: "guardianCheck")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
        Function to get stored data for a given core data entity
    **/
    class func retrieveData(_ entityName: String) -> [Any]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let result = try managedContext.fetch(fetchRequest)
            return result
        } catch {
            print("Failed")
        }
        return []
    }
    
    /**
        Funtion to delete core data for a given entity
    **/
    class func deleteAllData(from entityName: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try! managedContext.execute(request)
    }
    
    
    
}
