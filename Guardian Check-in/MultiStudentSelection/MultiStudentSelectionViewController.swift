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

class MultiStudentSelectionViewController : UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var bucketCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIButton!
    var moved = false
    var searchLabelFrame:CGRect?
    var searchBarFrame:CGRect?
    var searchCollectionFrame:CGRect?
    var filteredStudentrecords = [StudentRecord]()
    var searchController: UISearchController?
    var selectedStudent = StudentRecord()
    
    var searchActive = false
    
    var searchViewPositionY:CGFloat = 0
    
    static var bucket = [StudentRecord]()
    
    override func viewDidLoad() {
        
        //Setup starting position for card
        cardView.center.x = cardView.center.x + self.view.bounds.width
        
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
        UIView.animate(withDuration: 0.5) {
            self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
        }
        
        doneButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToMultiOptions)))
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
        
        doneButton.layer.cornerRadius = 10
        doneButton.layer.shouldRasterize = false
        doneButton.layer.borderWidth = 1
        
    }
    
    @objc func goBack() {
        StudentConfirmationViewController.back = true
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.center.x = self.cardView.center.x + self.view.bounds.width
        }, completion: { finished in
            self.navigationController?.popViewController(animated: false)
        })
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
    
    @objc func goToMultiOptions(){
        if (MultiStudentSelectionViewController.bucket.count>0){
            UIView.animate(withDuration: 0.5, animations: {
                self.cardView.center.x = self.cardView.center.x - self.view.bounds.width
            }, completion: { finished in
                self.performSegue(withIdentifier: "multiStudentOptions", sender: self)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! MultiOptionSelectionViewController
        dest.studentBucket = MultiStudentSelectionViewController.bucket
    }
    
    
}

extension MultiStudentSelectionViewController: UICollectionViewDataSource {
    
    
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
            
            let fragFname = MultiStudentSelectionViewController.bucket[indexPath.row].fname
            let fragLname = MultiStudentSelectionViewController.bucket[indexPath.row].lname
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
            return MultiStudentSelectionViewController.bucket.count
        }
    }
    
}

extension MultiStudentSelectionViewController: UICollectionViewDelegateFlowLayout {
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

extension MultiStudentSelectionViewController: UICollectionViewDelegate {
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
                if (MultiStudentSelectionViewController.bucket.count == 0 || MultiStudentSelectionViewController.bucket.contains(where: {$0.id != self.selectedStudent.id})) {
                    MultiStudentSelectionViewController.bucket.append(self.selectedStudent)
                    self.bucketCollectionView.reloadData()
                }
            }
        }
        else {
            UIView.animate(withDuration: 0.05, animations: {
                collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.lightGray
            }) { finished in
                MultiStudentSelectionViewController.bucket.remove(at: indexPath.row)
                self.bucketCollectionView.reloadData()
            }
        }
    }
}

extension MultiStudentSelectionViewController: UISearchBarDelegate {
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
