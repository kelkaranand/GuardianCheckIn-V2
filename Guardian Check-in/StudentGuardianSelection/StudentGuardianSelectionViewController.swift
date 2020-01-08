//
//  StudentGuardianSelectionViewController.swift
//  GuardianApp
//
//  Created by Alexander Stevens on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit
import CoreData

class StudentGuardianSelectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var staffNameTextField: UITextField!
    @IBOutlet weak var checkInWithStaffView: UILabel!
    
    static var student = StudentRecord()
    var guardianList = [GuardianRecord]()
    var staffName : String?
    
    static var back = false
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shouldRasterize = false
        shadowView.layer.borderWidth = 1
        
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 1
        
        addButtonView.layer.cornerRadius = 10
        addButtonView.layer.shouldRasterize = false
        addButtonView.layer.borderWidth = 2
        addButtonView.backgroundColor = UIColor.lightGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //staffNameTextField.delegate = (self as! UITextFieldDelegate)
        
        //Setup starting position for card
        cardView.center.x = cardView.center.x + self.view.bounds.width
        shadowView.center.x = shadowView.center.x + self.view.bounds.width
        
        //Tap gesture recognizer for addButton
        addButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGuardian)))
        
        checkInWithStaffView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInWithStaff)))
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        studentNameLabel.text = StudentGuardianSelectionViewController.student.fname + " " + StudentGuardianSelectionViewController.student.lname
        fetchGuardians()
        if (StudentGuardianSelectionViewController.back) {
            UIView.animate(withDuration: 0.5) {
                self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
                self.shadowView.center.x = self.shadowView.center.x + self.view.bounds.width
            }
            StudentGuardianSelectionViewController.back = false
        }
        else {
            UIView.animate(withDuration: 0.5) {
                self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
                self.shadowView.center.x = self.shadowView.center.x - self.view.bounds.width
            }
        }
    }
    
    @objc func goBack() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
            self.shadowView.center.x = self.shadowView.center.x + self.view.bounds.width
        }, completion: { finished in
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    @objc func addGuardian() {
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
            self.shadowView.center.x = self.shadowView.center.x - self.view.bounds.width
        }, completion : { finished in
            self.performSegue(withIdentifier: "moveToAddGuardian", sender: self)
        })
    }

    @objc func checkInWithStaff() {
        staffName = staffNameTextField.text
        
        // check if form is complete
        if staffNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            // create the alert that user has not completed form
            let incompleteAlert = UIAlertController(title: "Incomplete!", message: "Please add the staff member's name", preferredStyle: UIAlertController.Style.alert)
            // add the OK button
            incompleteAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                return
            }
            ))
            // show the alert
            self.present(incompleteAlert, animated: true, completion: nil)
        } else {
            
            self.performSegue(withIdentifier: "moveToOptions", sender: self)
        }
    }
    
    private func fetchGuardians() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Guardian")
        fetchRequest.predicate = NSPredicate(format: "studentId = %@", StudentGuardianSelectionViewController.student.id)
        do {
            let results = try context.fetch(fetchRequest)
            let guardians = results as! [Guardian]
            
            for guardian in guardians {
                guardianList.append(GuardianRecord(guardian.fname!,guardian.lname!,guardian.relation!))
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "moveToAddGuardian"){
            let dest = segue.destination as! AddGuardianViewController
            dest.student = StudentGuardianSelectionViewController.student
        }
        
//        if segue.identifier == "moveToOptions" {
//            staffName = staffNameTextField.text!
//
//            let dest = segue.destination as? OptionSelectionViewController
//            //destinaton.maps = sender as? [SkiMap]
//            print("preparing segue")
//            dest.staffName = StudentGuardianSelectionViewController.staffName
//
//        }
    }
    
    func moveToConfirmation(_ fname:String) {
        OptionSelectionViewController.fname = fname
        OptionSelectionViewController.comingFromConfirmation = false
        UIView.animate(withDuration: 0.5, animations: {
           self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
            self.shadowView.center.x = self.shadowView.center.x - self.view.bounds.width
        }, completion : { finished in
            self.performSegue(withIdentifier: "moveToOptions", sender: self)
        })
    }
    
}

extension StudentGuardianSelectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selection", for: indexPath) as! StudentGuardianCollectionCell
        
        cell.layer.cornerRadius = 10
        cell.layer.shouldRasterize = false
        cell.layer.borderWidth = 2
        
        let fragFname = guardianList[indexPath.row].fname
        let fragLname = guardianList[indexPath.row].lname
        cell.nameLabel.text = fragFname + " " + fragLname
        cell.relationshipLabel.text = guardianList[indexPath.row].relation
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return guardianList.count
    }
    
}

extension StudentGuardianSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 20
        return CGSize(width: (self.collectionView.frame.width / 2) - 20, height: (self.collectionView.frame.height / 2) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension StudentGuardianSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        moveToConfirmation(guardianList[indexPath.row].fname)
    }
}
