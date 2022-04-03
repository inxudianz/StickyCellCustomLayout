//
//  HeaderClass.swift
//  CollectionLayout
//
//  Created by William Inx on 02/04/22.
//

import Foundation
import UIKit

final class HeaderClassCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let label = UILabel()
        label.text = "Header"
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addConstraints([
            .init(item: label, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: label, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        ])
    }
}
