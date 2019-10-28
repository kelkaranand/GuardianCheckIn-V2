//
//  StudentGuardianCollectionCell.swift
//  GuardianApp
//
//  Created by Alexander Stevens on 10/21/19.
//  Copyright © 2019 Alex Stevens. All rights reserved.
//

import UIKit

class StudentGuardianCollectionCell: UICollectionViewCell {
    
    var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Stevens"
        return label
    }()

    var relationshipLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Stevens"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.nameLabel)
        addSubview(self.relationshipLabel)
        nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        relationshipLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 20).isActive = true
          relationshipLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
