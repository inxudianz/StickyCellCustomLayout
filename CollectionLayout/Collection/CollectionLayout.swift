//
//  CollectionLayout.swift
//  CollectionLayout
//
//  Created by William Inx on 03/04/22.
//

import UIKit

class CollectionLayout: UICollectionViewFlowLayout {
    private var allAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var contentSize = CGSize.zero

    var topBarHeight: CGFloat = .zero
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func prepare() {
        setupAttributes()
        setupSticky()
        let lastItemFrame = allAttributes.last?.last?.frame ?? .zero
        contentSize = CGSize(width: lastItemFrame.maxX, height: lastItemFrame.maxY)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()

        for section in allAttributes {
            for item in section where rect.intersects(item.frame) {
                layoutAttributes.append(item)
            }
        }

        return layoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func getIndexPath(for yAxis: CGFloat) -> IndexPath? {
        for (sectionIndex,section) in allAttributes.enumerated() {
            for (itemIndex,item) in section.enumerated() {
                if yAxis <= item.frame.origin.y {
                    if sectionIndex != 1 {
                        return IndexPath(item: itemIndex, section: sectionIndex)
                    }
                    else {
                        continue
                    }
                }
            }
        }
        
        return nil
    }

    private func setupAttributes() {
        allAttributes = []

        var yOffset: CGFloat = 0

        let numberOfSections = collectionView?.numberOfSections ?? .zero
        
        for section in 0..<numberOfSections {
            var sectionItems: [UICollectionViewLayoutAttributes] = []
            let numberOfItem = collectionView?.numberOfItems(inSection: section) ?? .zero
            
            yOffset += sectionInset.top
            for item in 0..<numberOfItem {
                guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
                      let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: IndexPath(item: item, section: section)) else {
                          assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
                          return
                      }
                
                let itemSize = size
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                attributes.frame = CGRect(x: 0, y: yOffset, width: itemSize.width, height: itemSize.height)
                yOffset += itemSize.height + minimumInteritemSpacing
                sectionItems.append(attributes)
            }
            yOffset += sectionInset.bottom
            
            allAttributes.append(sectionItems)
        }
    }
    
    private func setupSticky() {
        for (sectionIndex,section) in allAttributes.enumerated() {
            for (itemIndex,_) in section.enumerated() {
                if sectionIndex == 1 {
                    if itemIndex == 0 {
                        let attributes = allAttributes[sectionIndex][itemIndex]
                        var frame = attributes.frame
                        
                        if frame.minY < collectionView!.contentOffset.y + topBarHeight {
                            frame.origin.y = collectionView!.contentOffset.y + topBarHeight
                            attributes.frame = frame
                            attributes.zIndex = 3
                        }
                    }
                }
            }
        }
    }
}
