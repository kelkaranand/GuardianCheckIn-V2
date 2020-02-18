//
//  StudentOrGuardianViewController.swift
//  Guardian Check-in
//
//  Created by Noah Flaniken on 2/11/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import UIKit
import CoreData

class StudentOrGuardianViewController: UIViewController {

    @IBOutlet weak var guardianCheckInButton: UIView!
    @IBOutlet weak var studentCheckInButton: UIView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var checkInCard: UIView!
    @IBOutlet weak var checkInLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        superView.layer.cornerRadius = 10
        superView.layer.shouldRasterize = false
        
        checkInCard.layer.cornerRadius = 10
        checkInCard.layer.shouldRasterize = false
        checkInCard.layer.borderWidth = 1
        
        checkInCard.layer.shadowRadius = 10
        checkInCard.layer.shadowColor = UIColor.black.cgColor
        checkInCard.layer.shadowOpacity = 1
        
        guardianCheckInButton.layer.cornerRadius = 10
        guardianCheckInButton.layer.shouldRasterize = false
        guardianCheckInButton.layer.borderWidth = 2
        guardianCheckInButton.backgroundColor = UIColor.lightGray
        
        studentCheckInButton.layer.cornerRadius = 10
        studentCheckInButton.layer.shouldRasterize = false
        studentCheckInButton.layer.borderWidth = 2
        studentCheckInButton.backgroundColor = UIColor.lightGray
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        studentCheckInButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInStudent)))
        
        guardianCheckInButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkInGuardian)))
    }
    
    //MARK: Navigation

    @objc func checkInStudent(){
        print("CheckInStudent")
        
    }
    
    @objc func checkInGuardian(){
        print("CheckInGuardian")
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         
//        
//    }
    
    

}
