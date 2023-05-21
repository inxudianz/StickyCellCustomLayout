//
//  TestCollectionVC.swift
//  CollectionLayout
//
//  Created by William Inx on 02/04/22.
//

import Foundation
import UIKit

final class TestCollectionVC: UIViewController {
    
    private lazy var flow: CollectionLayout = {
        let layout = CollectionLayout()
        layout.delegate = self
        layout.stickySection = .init(row: 0, section: 1)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .init(), collectionViewLayout: flow)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(HeaderClassCell.self, forCellWithReuseIdentifier: HeaderClassCell.description())
        collectionView.register(ContentClassCell.self, forCellWithReuseIdentifier: ContentClassCell.description())
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.description())
        return collectionView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flow.sectionInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? .zero
        let statusBarHeight: CGFloat = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero
        flow.topBarHeight = 0 //navbarHeight + statusBarHeight
        
        view.backgroundColor = .darkGray
        
        view.addSubview(collectionView)
        
        view.addConstraints([
            .init(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            .init(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            .init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            .init(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }
    
}

extension TestCollectionVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == .zero {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else if section == 2 {
            return 1
        }
        else if section == 3 {
            return 3
        }
        else if section == 4 {
            return 4
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == .zero {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeaderClassCell.description(), for: indexPath) as? HeaderClassCell else {
                return .init()
                
            }
            if indexPath.row == .zero {
                cell.backgroundColor = .yellow
                cell.setupView()
                return cell
            }
        }
        else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentClassCell.description(), for: indexPath) as? ContentClassCell else {
                return .init()
            }
            if indexPath.row == .zero {
                cell.setupView()
                cell.delegate = self
                return cell
            }
        }
        else if indexPath.section > 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCell.description(), for: indexPath) as? ListCell else {
                return .init()
            }
            
            cell.listCount = indexPath.section
            cell.backgroundColor = .cyan
            cell.setupView()
            return cell
        }
        
        return .init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let collectionOffset = collectionView.contentOffset.y
        let visibleCells = collectionView.visibleCells
        for visibleCell in visibleCells {
            if visibleCell.isKind(of: ContentClassCell.self) {
                guard let contentClassCell = visibleCell as? ContentClassCell else {
                    return
                }
                let indexPath = flow.getIndexPath(for: collectionOffset)
                if indexPath?.section != contentClassCell.getSegmented() {
                    contentClassCell.updateSegment(to: indexPath?.section ?? .zero)
                }
                break
            }
        }
    }
}

extension TestCollectionVC: ContentClassCellDelegate {
    func segmentChanged(index: Int) {
        collectionView.scrollToItem(at: .init(row: 0, section: index), at: .top, animated: true)
    }
}

extension TestCollectionVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == .zero {
            if indexPath.row == .zero {
                return .init(width: view.frame.width, height: 300)
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == .zero {
                return .init(width: view.frame.width, height: 50)
            }
        }
        else if indexPath.section > 1 {
            return .init(width: view.frame.width, height: 200)
        }
        
        return .init(width: view.frame.width, height: 10)
    }
}

extension TestCollectionVC: CollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, sizeForSupplementaryView kind: String, at indexPath: IndexPath) -> CGSize {
        .init(width: 100, height: 100)
    }
}
