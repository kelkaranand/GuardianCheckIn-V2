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
    @IBOutlet weak var scrollDownImage: UIImageView!
    @IBOutlet weak var noGuardiansView: UIView!
    @IBOutlet weak var scrollDownText: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    static var student = StudentRecord()
    var guardianList = [GuardianRecord]()
    var staffName : String?
    
    static var back = false
    static var recheckError = false
    
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
        
        //Setup starting position for card
        cardView.center.x = cardView.center.x + self.view.bounds.width
        shadowView.center.x = shadowView.center.x + self.view.bounds.width
        
        //Tap gesture recognizer for addButton
        addButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGuardian)))
        
        //Swipe right to go back
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        rightSwipe.direction = .right
        self.view.addGestureRecognizer(rightSwipe)
        
        scrollDownImage.image = UIImage.gifImageWithName("whitedown")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        if !StudentGuardianSelectionViewController.back {
            fetchGuardians()
        }
        if (guardianList.count > 4) {
            scrollDownImage.isHidden = false
            scrollDownText.isHidden = false
            noGuardiansView.isHidden = true
        }
        else if (guardianList.count == 0) {
            scrollDownImage.isHidden = true
            scrollDownText.isHidden = true
            noGuardiansView.isHidden = false
            addButtonView.pulsate()
        }
        else {
            scrollDownImage.isHidden = true
            scrollDownText.isHidden = true
            noGuardiansView.isHidden = true
        }
        studentNameLabel.text = StudentGuardianSelectionViewController.student.fname + " " + StudentGuardianSelectionViewController.student.lname
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
        if StudentGuardianSelectionViewController.recheckError {
            StudentGuardianSelectionViewController.recheckError = false
            AlertViewController.msg = "A family member record with these details already exists. Please check the list of family members associated with the student again."
            AlertViewController.img = "error"
            let storyboard = UIStoryboard(name: "Alert", bundle: nil)
            let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
            myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(myAlert, animated: true, completion: nil)
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

    
    private func fetchGuardians() {
        let url = URL(string:RestHelper.urls["Get_Family_Members"]!+StudentGuardianSelectionViewController.student.id)!
        print(url)
        let jsonString = RestHelper.makePost(url, ["identifier": LaunchViewController.identifier!, "key": LaunchViewController.key!])
        let data = jsonString.data(using: .utf8)!
        do {
                
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,String>]{
                    
                for item in jsonArray {
                    self.guardianList.append(GuardianRecord(item["Name"]!, item["Id"]!, item["Relationship"]!))
                }
                    
                } else {
                    print("bad json")
                }
                
        } catch let error as NSError {
                print(error)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "moveToAddGuardian"){
            let dest = segue.destination as! AddGuardianViewController
            dest.student = StudentGuardianSelectionViewController.student
        }
    }
    
    func moveToConfirmation(_ fname:String) {
        OptionSelectionViewController.fname = fname
        OptionSelectionViewController.staffName = ""
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
        cell.layer.borderColor = UIColor.white.cgColor
        
        cell.nameLabel.text = guardianList[indexPath.row].name
        cell.relationshipLabel.text = guardianList[indexPath.row].relation
        cell.addGestureRecognizer(CustomTapGestureRecognizer())
        
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
        OptionSelectionViewController.familyMemberId = guardianList[indexPath.row].id
        moveToConfirmation(guardianList[indexPath.row].name)
    }
}
