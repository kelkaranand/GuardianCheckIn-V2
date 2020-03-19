//
//  MultiStudentSelection.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 27/02/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MultiStudentSelection : UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var bucketCollectionView: UICollectionView!
    var moved = false
    var searchLabelFrame:CGRect?
    var searchBarFrame:CGRect?
    var searchCollectionFrame:CGRect?
    var filteredStudentrecords = [StudentRecord]()
    var searchController: UISearchController?
    var selectedStudent = StudentRecord()
    
    var searchActive = false
    
    var searchViewPositionY:CGFloat = 0
    
    var bucket = [StudentRecord]()
    
    @IBAction func Animate(_ sender: Any) {
//        if !moved {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.contentView.isHidden = false
//                
//                self.searchLabel.frame.size.width = self.searchCollectionView.frame.size.width
//                self.searchLabel.center.x = self.searchCollectionView.center.x
//                self.searchLabel.frame.origin.y = 30
//                
//                self.searchBar.frame.size.width = self.searchLabel.frame.width
//                self.searchBar.center.x = self.searchLabel.center.x
//                self.searchBar.frame.origin.y = 40 + self.searchLabel.frame.height
//            })
//            moved = true
//        }
//        else{
//            self.searchBar.text="";
//            self.filteredStudentrecords.removeAll()
//            self.searchCollectionView.reloadData()
//            UIView.animate(withDuration: 0.5){
//                self.contentView.isHidden = true
//                self.searchBar.frame.size.width = self.view.frame.width * 0.64
//                self.searchBar.center = self.view.center
//                self.searchLabel.frame.size.width = self.searchBar.frame.width
//                self.searchLabel.center.x = self.searchBar.center.x
//            }
//            moved = false
//        }
    }
    
    override func viewDidLoad() {
//        contentView.isHidden = true
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        //Student data from coredata
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Student")
        
        do {
            let results = try context.fetch(fetchRequest)
            let students = results as! [Student]
            
            for student in students {
                SearchStudentViewController.studentRecords.append(StudentRecord(student.fname!, student.lname!, student.id!))
            }
        }catch let err as NSError {
            print(err.debugDescription)
        }
        searchViewPositionY = searchView.frame.origin.y
        
        //Code to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationCheckViewController.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        contentView.layer.cornerRadius = 10
        contentView.layer.shouldRasterize = false
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.cgColor
        
        searchView.layer.cornerRadius = 10
        searchView.layer.shouldRasterize = false
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor.white.cgColor
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.searchView.frame.origin.y == searchViewPositionY{
                self.searchView.frame.origin.y -= self.searchBar.frame.origin.y
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.searchView.frame.origin.y != searchViewPositionY{
                self.searchView.frame.origin.y = searchViewPositionY
            }
        }
    }
    
    
}

extension MultiStudentSelection: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.searchCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! MultiSelectCollectionCell
        
            cell.layer.cornerRadius = 10
            cell.layer.shouldRasterize = false
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
        
            let fragFname = filteredStudentrecords[indexPath.row].fname
            let fragLname = filteredStudentrecords[indexPath.row].lname
            cell.nameLabel.text = fragFname + " " + fragLname
            cell.nameLabel.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
        
//            let cellPress = CustomTapGestureRecognizer()
//            cell.addGestureRecognizer(cellPress)
        
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bucketCell", for: indexPath) as! MultiSelectionBucketCollectionCell
            
            cell.layer.cornerRadius = 10
            cell.layer.shouldRasterize = false
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            
            let fragFname = bucket[indexPath.row].fname
            let fragLname = bucket[indexPath.row].lname
            cell.nameLabel.text = fragFname + " " + fragLname
            cell.nameLabel.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
            
//            let cellPress = CustomTapGestureRecognizer()
//            cell.addGestureRecognizer(cellPress)
            
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.searchCollectionView) {
            return filteredStudentrecords.count
        }
        else {
            return bucket.count
        }
    }
    
}

extension MultiStudentSelection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.searchCollectionView) {
            return CGSize(width: (self.searchCollectionView.frame.width) - 20, height: (self.searchCollectionView.frame.height / 6.5) - 20)
        }
        else {
            return CGSize(width: (self.bucketCollectionView.frame.width) - 20, height: (self.bucketCollectionView.frame.height / 6.5) - 20)
        }
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

extension MultiStudentSelection: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView == self.searchCollectionView) {
            UIView.animate(withDuration: 0.05, animations: {
                collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.lightGray
            }) { finished in
                self.selectedStudent = self.filteredStudentrecords[indexPath.row]
                print(self.selectedStudent.fname)
                self.searchBar.text = ""
                self.filteredStudentrecords.removeAll()
                self.searchCollectionView.reloadData()
                if (self.bucket.count == 0 || self.bucket.contains(where: {$0.id != self.selectedStudent.id})) {
                    self.bucket.append(self.selectedStudent)
                    self.bucketCollectionView.reloadData()
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.05, animations: {
                collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.lightGray
            }) { finished in
                self.bucket.remove(at: indexPath.row)
                self.bucketCollectionView.reloadData()
            }
        }
    }
}

extension MultiStudentSelection: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredStudentrecords.removeAll(keepingCapacity: false)
        guard let text = searchBar.text else { return }
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
        
        filteredStudentrecords = SearchStudentViewController.studentRecords.filter({( student : StudentRecord) -> Bool in
            let name = student.fname + " " + student.lname
            return (name.lowercased().contains(searchText.lowercased()))
        })
        
        searchCollectionView.reloadData()
        
    }
}
