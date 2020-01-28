//
//  GetFNameViewController.swift
//  GuardianApp
//
//  Created by Noah Flaniken on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit

class GetFNameViewController: UIViewController {

    @IBOutlet weak var mainCardView: UIView!
    @IBOutlet weak var fnameTextbox: UITextField!
    @IBAction func firstNameButton(_ sender: Any) {
        if (fnameTextbox.text?.isEmpty)! {
            fnameTextbox.shake()
        } else {
            GetFNameViewController.text = fnameTextbox.text!
            UIView.animate(withDuration: 0.5, animations: {
                self.mainCardView.center.x = self.mainCardView.center.x - self.view.bounds.width
            }, completion : { finished in
                ConfirmationViewController.sname = self.student.fname + " " + self.student.lname
                ConfirmationViewController.fname = self.fnameTextbox.text
                ConfirmationViewController.id = self.student.id
                self.performSegue(withIdentifier: "moveToLastName", sender: self)
            })
        }
    }
    
    var student = StudentRecord()
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
        self.fnameTextbox.text = GetFNameViewController.text
        if (GetFNameViewController.back) {
            UIView.animate(withDuration: 0.5) {
                self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
            }
            GetFNameViewController.back = false
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
        GetFNameViewController.text = ""
        GetLNameViewController.text = ""
        GetPhoneNumberViewController.text = ""
        GetRelationViewController.index = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.mainCardView.center.x = self.mainCardView.center.x + self.view.bounds.width
        }, completion: { finished in
            StudentGuardianSelectionViewController.back = true
            self.navigationController?.popViewController(animated: false)
        })
    }
    
}

extension UITextField {
    func shake(completion: (() -> Void)? = nil) {
        let speed = 0.75
        let time = 1.0 * speed - 0.15
        let timeFactor = CGFloat(time / 4)
        let animationDelays = [timeFactor, timeFactor * 2, timeFactor * 3]
        
        let shakeAnimator = UIViewPropertyAnimator(duration: time, dampingRatio: 0.3)
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 20, y: 0)
        })
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: -20, y: 0)
        }, delayFactor: animationDelays[0])
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 20, y: 0)
        }, delayFactor: animationDelays[1])
        shakeAnimator.addAnimations({
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: animationDelays[2])
        shakeAnimator.startAnimation()
        
        shakeAnimator.addCompletion { _ in
            completion?()
        }
        
        shakeAnimator.startAnimation()
    }
}
