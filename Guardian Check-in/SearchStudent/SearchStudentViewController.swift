//
//  SearchStudentViewController.swift
//  GuardianApp
//
//  Created by Alexander Stevens on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox
import AVFoundation

class SearchStudentViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var searchController: UISearchController?
    var selectedStudent = StudentRecord()
    static var studentRecords = [StudentRecord]()
    var filteredStudentrecords = [StudentRecord]()
    var searchActive = false
    @IBOutlet weak var scrollDownImage: UIImageView!
    @IBOutlet weak var scrollDownText: UILabel!
    @IBOutlet weak var mainCard: UIView!
    @IBOutlet weak var checkInCard: UIView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkInButtonView: UIView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    var moved = false
    var easterEgg = false
    var displayGifs = ["lj1","lj2","lj3","lj4"]
    
    
    override func viewDidLayoutSubviews() {
        
        superView.layer.cornerRadius = 10
        superView.layer.shouldRasterize = false
        
        checkInCard.layer.cornerRadius = 10
        checkInCard.layer.shouldRasterize = false
        checkInCard.layer.borderWidth = 1
        
        checkInCard.layer.shadowRadius = 10
        checkInCard.layer.shadowColor = UIColor.black.cgColor
        checkInCard.layer.shadowOpacity = 1
        
        checkInButtonView.layer.cornerRadius = 10
        checkInButtonView.layer.shouldRasterize = false
        checkInButtonView.layer.borderWidth = 2
        checkInButtonView.backgroundColor = UIColor.lightGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        searchBar.text = ""
        filteredStudentrecords = []
        collectionView.reloadData()
        scrollDownImage.isHidden = true
        scrollDownText.isHidden = true
        scrollDownImage.image = UIImage.gifImageWithName("whitedown")
        checkInButtonView.pulsate()
        if CoreDataHelper.locationName == "" {
            self.performSegue(withIdentifier: "showSetup", sender: self)
        }
        else {
            checkInLabel.text = "WELCOME TO THE \n" + CoreDataHelper.locationName.capitalized
            self.mainCard.alpha = 0
            self.checkInCard.alpha = 1
            self.view.alpha = 1
            moved = false
            searchBar.text = nil
            UIView.animate(withDuration: 0.5) {
                self.superView.center.y = self.superView.center.y - self.view.bounds.height
            }
        }
        self.mainCard.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        //Tap on screen to dismiss keyboard
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
//        tap.cancelsTouchesInView = false
//        self.view.addGestureRecognizer(tap)
        
        //Setup starting position for card
        mainCard.center.y = mainCard.center.y + self.view.bounds.height
        
        //Tap gesture for check-in button
        checkInButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInPressed)))
        
        //Swipe right to flip back card
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(flipBack))
        rightSwipe.direction = .right
        mainCard.addGestureRecognizer(rightSwipe)
        
        //Easter egg gesture recognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showLebron))
        longPress.minimumPressDuration = 5
        logoImage.addGestureRecognizer(longPress)
    
    }
    
    func pulsate(view:UIView) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        view.layer.add(pulse, forKey: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= self.view.frame.height/2 - 30
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
    
    @objc func showLebron() {
        if(!easterEgg)
        {
            easterEgg = true
            let randomInt = Int.random(in: 0..<4)
            UIView.transition(with: logoImage, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
                self.logoImage.alpha = 0
            }, completion: { finished in
                self.logoImage.image = UIImage.gifImageWithName(self.displayGifs[randomInt])
                self.logoImage.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.logoImage.alpha = 0
                    }, completion: { finished in
                        self.logoImage.image = UIImage.init(named: "ips_varsity_k")
                        UIView.animate(withDuration: 0.5, animations: {
                            self.logoImage.alpha = 1
                        })
                        self.easterEgg = false
                    })
                }
            })
        }
    }
    
    @objc func checkInPressed() {
        self.mainCard.isHidden = false
        UIView.transition(with: checkInCard, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], animations: {
            self.checkInCard.alpha = 0
        }, completion: { finished in
            
        })
        UIView.transition(with: mainCard, duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], animations: {
            self.mainCard.alpha = 1
        }, completion: { finished in
            
        })
        print("Check")
    }
    
    @objc func flipBack() {
        UIView.transition(with: mainCard, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
            self.mainCard.alpha = 0
        }, completion: { finished in
            
        })
        UIView.transition(with: checkInCard, duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], animations: {
            self.checkInCard.alpha = 1
        }, completion: { finished in
            self.mainCard.isHidden = true
        })
        print("flip")
    }
    
    func moveToSetup(){
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }, completion: { finished in
            self.performSegue(withIdentifier: "showSetup", sender: self)
        })
    }
    
    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }

}



extension SearchStudentViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("started")
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("done")
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "Password" {
            self.mainCard.endEditing(true)
            moveToSetup()
        }
            filteredStudentrecords.removeAll(keepingCapacity: false)
              guard let text = searchBar.text else { return }
              let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
        
        filteredStudentrecords = SearchStudentViewController.studentRecords.filter({( student : StudentRecord) -> Bool in
            let name = student.fname + " " + student.lname
            return (name.lowercased().contains(searchText.lowercased()))
        })
        
        collectionView.reloadData()
        if filteredStudentrecords.count > 4 {
            scrollDownImage.isHidden = false
            scrollDownText.isHidden = false
        }
        else {
            scrollDownImage.isHidden = true
            scrollDownText.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentConfirmation" {
            OptionSelectionViewController.fname = selectedStudent.fname + " " + selectedStudent.lname
            StudentConfirmationViewController.back = false
        } else if segue.identifier == "showStudentGuardianFork" {
            StudentOrGuardianViewController.student = selectedStudent
        }
        
    }
}

extension SearchStudentViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchStudentCollectionCell
        
        cell.layer.cornerRadius = 10
        cell.layer.shouldRasterize = false
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        let fragFname = filteredStudentrecords[indexPath.row].fname
        let fragLname = filteredStudentrecords[indexPath.row].lname
        cell.nameLabel.text = fragFname + " " + fragLname
        cell.backgroundColor = UIColor.clear
        cell.nameLabel.textColor = UIColor.white
        
        let cellPress = CustomTapGestureRecognizer()
        cell.addGestureRecognizer(cellPress)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredStudentrecords.count
    }
    
}

extension SearchStudentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width) - 20, height: (self.collectionView.frame.height / 3.75) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

extension SearchStudentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStudent = filteredStudentrecords[indexPath.row]
        MultiStudentSelectionViewController.bucket.removeAll()
        MultiStudentSelectionViewController.bucket.append(selectedStudent)
        OptionSelectionViewController.studentAPSId = selectedStudent.id
        UIView.animate(withDuration: 0.5, animations: {
            self.view.endEditing(false)
            self.superView.center.x = self.superView.center.x - self.view.bounds.width
        }, completion: { finished in
            if CoreDataHelper.locationGuardianFlag {
                StudentOrGuardianViewController.back = false
                self.performSegue(withIdentifier: "showStudentGuardianFork", sender: self)
            }
            else {
                StudentConfirmationViewController.back = false
                OptionSelectionViewController.fname = self.selectedStudent.fname + " " + self.selectedStudent.lname
                self.performSegue(withIdentifier: "studentConfirmation", sender: self)
            }
        })
    }
}

extension UIView {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        self.layer.add(pulse, forKey: nil)
    }
    
    func shake(duration: TimeInterval = 0.5, xValue: CGFloat = 12, yValue: CGFloat = 0) {
        self.transform = CGAffineTransform(translationX: xValue, y: yValue)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
}

