//
//  GetRelationViewController.swift
//  GuardianApp
//
//  Created by Noah Flaniken on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit

class GetRelationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var relationPicker: UIPickerView!
    @IBAction func relationButton(_ sender: Any) {
        GetRelationViewController.index = self.relationPicker.selectedRow(inComponent: 0)
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
        }, completion : { finished in
            ConfirmationViewController.relation = self.relationList[self.relationPicker.selectedRow(inComponent: 0)]
            self.performSegue(withIdentifier: "confirm", sender: self)
        })
    }
    static var back = false
    static var index = 0
    
    let relationList = ["Mother","Father","Brother","Sister","Cousin","Aunt","Uncle","Guardian","Other"]
    
    
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
        
        relationPicker.dataSource = self
        relationPicker.delegate = self
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.relationPicker.selectRow(GetRelationViewController.index, inComponent: 0, animated: false)
        if (GetRelationViewController.back) {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }
            GetRelationViewController.back = false
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
            label.textColor = UIColor.white
            return label
        }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/1.7
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
        }, completion: { finished in
            GetPhoneNumberViewController.back = true
            self.navigationController?.popViewController(animated: false)
        })
    }
    
}
