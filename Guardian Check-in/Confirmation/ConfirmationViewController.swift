//
//  ConfirmationViewController.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 12/11/19.
//  Copyright © 2019 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit

class ConfirmationViewController : UIViewController {
    
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fnameLabel: UILabel!
    @IBOutlet weak var lnameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var editButton: UIView!
    @IBOutlet weak var confirmButton: UIView!
    static var sname:String?
    static var fname:String?
    static var lname:String?
    static var phone:String?
    static var relation:String?
    static var id:String?
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        mainCardView.layer.cornerRadius = 10
        mainCardView.layer.shouldRasterize = false
        mainCardView.layer.borderWidth = 1
        
        mainCardView.layer.shadowRadius = 10
        mainCardView.layer.shadowColor = UIColor.black.cgColor
        mainCardView.layer.shadowOpacity = 1
        
        editButton.layer.cornerRadius = 10
        editButton.layer.shouldRasterize = false
        editButton.layer.borderWidth = 1
        
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.shouldRasterize = false
        confirmButton.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        //Setup starting position for card
        mainCardView.center.x = mainCardView.center.x + self.view.bounds.width
        
        //Swipe right to go back
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
//        rightSwipe.direction = .right
//        self.view.addGestureRecognizer(rightSwipe)
        
        //Tap on edit button
        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goBack)))
        
        //Tap on confirm button
        confirmButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(done)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        nameLabel.text = ConfirmationViewController.sname
        fnameLabel.text = ConfirmationViewController.fname
        lnameLabel.text = ConfirmationViewController.lname
        phoneLabel.text = ConfirmationViewController.phone
        relationLabel.text = ConfirmationViewController.relation
        UIView.animate(withDuration: 0.5) {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
        }, completion: { finished in
            AddGuardianViewController.back = true
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: AddGuardianViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: false)
                    break
                }
            }
        })
    }
    
    @objc func done() {
        var apiResponse = self.addGuardian()
        //Add guardian api returns a string with " at the front and end.
        //Remove those "
        apiResponse.removeFirst()
        apiResponse.removeLast()
        if(apiResponse.localizedStandardContains("1000")){
            StudentGuardianSelectionViewController.back = true
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: StudentGuardianSelectionViewController.self) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
                    }, completion: { finished in
                        self.navigationController!.popToViewController(controller, animated: false)
                    })
                    break
                }
            }
            StudentGuardianSelectionViewController.recheckError = true
            return
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }, completion: { finished in
            OptionSelectionViewController.fname = self.fnameLabel.text! + " " + self.lnameLabel.text!
            OptionSelectionViewController.familyMemberId = apiResponse
            OptionSelectionViewController.comingFromConfirmation = true
            self.performSegue(withIdentifier: "showOptions", sender: self)
        })
    }
    
    private func addGuardian() -> String {
        print("In add guardian")
        let url = URL(string:RestHelper.urls["Add_Family_Member"]!)!
        print(url)
        let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!, "firstName":fnameLabel.text!, "lastName":lnameLabel.text!, "phoneNum":phoneLabel.text!, "relation":relationLabel.text!, "apsID":ConfirmationViewController.id!])
        return jsonString
    }
    
    
    
    
}
