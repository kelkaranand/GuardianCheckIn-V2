//
//  CustomTapGestureRecognizer.swift
//  Guardian Check-in
//
//  Created by Anand Kelkar on 28/01/20.
//  Copyright © 2020 Anand Kelkar. All rights reserved.
//

import UIKit.UITapGestureRecognizer

class CustomTapGestureRecognizer : UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        print("Gesture began")
        self.view?.backgroundColor = UIColor.lightGray
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        print("Gesture ended")
        self.view?.backgroundColor = UIColor.clear
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        print("Moved")
        self.view?.backgroundColor = UIColor.clear
    }
}
