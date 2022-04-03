//
//  ContentClass.swift
//  CollectionLayout
//
//  Created by William Inx on 02/04/22.
//

import UIKit

protocol ContentClassCellDelegate: AnyObject {
    func segmentChanged(index: Int)
}

final class ContentClassCell: UICollectionViewCell {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .red
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var segmented: SegmentedList = {
        let segmented = SegmentedList()
        segmented.setTitleTextAttributes([
            .foregroundColor: UIColor.blue
        ], for: .normal)
        segmented.insertSegment(withTitle: "Header", at: 0, animated: true)
        segmented.insertSegment(withTitle: "Content", at: 1, animated: true)
        segmented.insertSegment(withTitle: "List 2", at: 2, animated: true)
        segmented.insertSegment(withTitle: "List 3", at: 3, animated: true)
        segmented.insertSegment(withTitle: "List 4", at: 4, animated: true)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.selectedSegmentIndex = 0
        return segmented
    }()
    
    
    @objc
    func segmentChanged(_ sender: UISegmentedControl) {
        delegate?.segmentChanged(index: sender.selectedSegmentIndex)
    }
    
    func updateSegment(to index: Int) {
        segmented.selectedSegmentIndex = index
    }
    
    func getSegmented() -> Int {
        segmented.selectedSegmentIndex
    }
    
    weak var delegate: ContentClassCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        scrollView.addSubview(segmented)
        contentView.addSubview(scrollView)
        segmented.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            segmented.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            segmented.topAnchor.constraint(equalTo: scrollView.topAnchor),
            segmented.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            segmented.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
    }
}
