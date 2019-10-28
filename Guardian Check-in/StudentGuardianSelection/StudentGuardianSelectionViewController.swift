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
    
    var student = StudentRecord()
    var guardianList = [GuardianRecord]()
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        cardView.layer.cornerRadius = 10
        cardView.layer.shouldRasterize = false
        cardView.layer.borderWidth = 1
        
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 1
        
        addButtonView.layer.cornerRadius = 10
        addButtonView.layer.shouldRasterize = false
        addButtonView.layer.borderWidth = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(StudentGuardianCollectionCell.self, forCellWithReuseIdentifier: "selection")
        //Setup starting position for card
        cardView.center.y = cardView.center.y + self.view.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        studentNameLabel.text = student.fname + " " + student.lname
        fetchGuardians()
        UIView.animate(withDuration: 1) {
            self.cardView.center.y = self.cardView.center.y - self.view.bounds.height
        }
    }
    
    private func fetchGuardians() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Guardian")
        fetchRequest.predicate = NSPredicate(format: "studentId = %@", student.id)
        do {
            let results = try context.fetch(fetchRequest)
            var guardians = results as! [Guardian]
            
            for guardian in guardians {
                guardianList.append(GuardianRecord(guardian.fname!,guardian.lname!,guardian.relation!))
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
    }
}

extension StudentGuardianSelectionViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selection", for: indexPath) as! StudentGuardianCollectionCell
//        cell.backgroundColor = .red
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
