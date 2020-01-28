//
//  GetPhoneNumberViewController.swift
//  GuardianApp
//
//  Created by Noah Flaniken on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit

class GetPhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var phoneTextbox: UITextField!
    @IBAction func phoneButton(_ sender: Any) {
        if (phoneTextbox.text?.isEmpty)! {
            phoneTextbox.shake()
        } else {
            GetPhoneNumberViewController.text = self.phoneTextbox.text!
            UIView.animate(withDuration: 0.5, animations: {
                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
            }, completion : { finished in
                ConfirmationViewController.phone = self.phoneTextbox.text!
                self.performSegue(withIdentifier: "moveToRelation", sender: self)
            })
        }
    }
    
    static var back = false
    static var text = ""
    
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
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        self.phoneTextbox.text = GetPhoneNumberViewController.text
        if (GetPhoneNumberViewController.back) {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }
            GetPhoneNumberViewController.back = false
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
            }
        }
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
            GetLNameViewController.back = true
            self.navigationController?.popViewController(animated: false)
        })
    }
    
}

