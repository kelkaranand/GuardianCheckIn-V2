//
//  RestHelper.swift
//  CheckIn
//
//  Created by Anand Kelkar on 03/12/18.
//  Copyright © 2018 Anand Kelkar. All rights reserved.
//

import Foundation

/**
    Class to assist with rest api calls
 **/
public class RestHelper {
    
    //Static variable to store the school name used for some apis
    static var schoolName = ""
    //Static variable to store the host
    static let host = "https://ljff.secure.force.com/services/apexrest"
    //Static variable to store all the urls
    static let urls = [
        "Register_Device":host+"/device/register",
        "Get_Registration_Key":host+"/device",
        "Get_Students":host+"/students",
        "Attendance":host+"/event/attendance",
        "Create_Event":host+"/createEvent",
        "Get_Locations":host+"/checkinLocations",
        "Get_Students_By_School":host+"/schools/" + schoolName,
        "Get_Family_Members":host+"/familyMembers/",
        "Add_Family_Member":host+"/add/familyMember",
        "CheckIn":host+"/checkinToLocation"] as Dictionary<String,String>
    
    /**
        Function to make POST REST call
    **/
    class func makePost(_ url:URL, _ params: Dictionary<String,String>) -> String {
        var jsonData = NSData()
        do {
            jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) as NSData
        } catch {
            print(error.localizedDescription)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(jsonData.length)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData as Data
        let (data, _, error) = URLSession.shared.synchronousDataTask(urlrequest: request)
        if let error = error {
            return ("API call returned error: \(error)")
        }
        else {
            print(String(data: data!, encoding: String.Encoding.utf8)!)
            return String(data: data!, encoding: String.Encoding.utf8)!
        }
    }
}

//Extension to allow synchronous calls
extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2
            semaphore.signal()
        }
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return (data, response, error)
    }
}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}
