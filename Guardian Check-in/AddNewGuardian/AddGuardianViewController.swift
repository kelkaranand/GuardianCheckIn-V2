//
//  AddGuardianViewController.swift
//  GuardianApp
//
//  Created by Noah Flaniken on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit

class AddGuardianViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var studentLabel: UILabel!
    @IBOutlet weak var fnameTextbox: UITextField!
    @IBOutlet weak var lnameTextbox: UITextField!
    @IBOutlet weak var phoneTextbox: UITextField!
    @IBOutlet weak var relationPicker: UIPickerView!
    @IBOutlet weak var addButtonView: UIView!
    var student = StudentRecord()
    static var back = false
    
    let relationList = ["Mother","Father","Brother","Sister","Cousin","Aunt","Uncle","Guardian","Other"]
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        mainCardView.layer.cornerRadius = 10
        mainCardView.layer.shouldRasterize = false
        mainCardView.layer.borderWidth = 1
        
        mainCardView.layer.shadowRadius = 10
        mainCardView.layer.shadowColor = UIColor.black.cgColor
        mainCardView.layer.shadowOpacity = 1
        
        addButtonView.layer.cornerRadius = 10
        addButtonView.layer.shouldRasterize = false
        addButtonView.layer.borderWidth = 2
        addButtonView.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup starting position for card
        mainCardView.center.x = mainCardView.center.x + self.view.bounds.width
        
        //Tap on screen to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        //Tap on add button
        addButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGuardian)))
        
        relationPicker.dataSource = self
        relationPicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        studentLabel.text = student.fname + " " + student.lname
        if (AddGuardianViewController.back) {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }
            AddGuardianViewController.back = false
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Chalkboard SE", size: 20)
        label.text =  relationList[row]
        label.textAlignment = .center
        return label
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
        }, completion: { finished in
            StudentGuardianSelectionViewController.back = true
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    @objc func addGuardian() {
        if((self.fnameTextbox.text?.isEmpty)! || (self.lnameTextbox.text?.isEmpty)! || (self.phoneTextbox.text?.isEmpty)!) {
            print("Validation error")
        }
        else {
            UIView.animate(withDuration: 0.5, animations: {
                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
            }, completion : { finished in
                ConfirmationViewController.sname = self.studentLabel.text
                ConfirmationViewController.fname = self.fnameTextbox.text
                ConfirmationViewController.lname = self.lnameTextbox.text
                ConfirmationViewController.phone = self.phoneTextbox.text
                ConfirmationViewController.relation = self.relationList[self.relationPicker.selectedRow(inComponent: 0)]
                ConfirmationViewController.id = self.student.id
                self.performSegue(withIdentifier: "confirm", sender: self)
            })
        }
    }
    
}
