//
//  SegmentedList.swift
//  CollectionLayout
//
//  Created by William Inx on 03/04/22.
//

import Foundation
import UIKit

final class SegmentedList: UISegmentedControl {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
