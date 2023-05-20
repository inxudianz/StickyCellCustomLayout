//
//  CollectionLayout.swift
//  CollectionLayout
//
//  Created by William Inx on 03/04/22.
//

import UIKit

protocol CollectionLayoutDelegate: AnyObject {
    /// delegate to receive size for item at specific index path
    /// - Parameters:
    ///   - collectionView: collection view of the conformer
    ///   - indexPath: index path of the item
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize
    
    /// delegate to receive size for supplementary view at specific index path
    /// - Parameters:
    ///   - collectionView: collection view of the conformer
    ///   - kind: kind of supplementary view support by collection view
    ///   - indexPath: index path
    func collectionView(_ collectionView: UICollectionView, sizeForSupplementaryView kind: String, at indexPath: IndexPath) -> CGSize
}

final class CollectionLayout: UICollectionViewLayout {
    // MARK: - Private Property
    /// all primary content cell attributes
    private var allAttributes: [[UICollectionViewLayoutAttributes]] = []
    
    /// all primary header of a section attributes
    private var allHeaderAttributes: [[UICollectionViewLayoutAttributes]] = []
    
    /// content of the collection
    private var contentSize: CGSize = CGSize.zero
    
    /// true origin Y axis of the sticky section
    private var stickySectionOriginalY: CGFloat = .zero
    
    /// true height of the sticky section
    private var stickySectionHeight: CGFloat = .zero
    
    // MARK: - Property
    /// define where you want to make the sticky section at. will be of type IndexPath. this sticky section is **required**.
    var stickySection: IndexPath = IndexPath() {
        didSet {
            invalidateLayout()
        }
    }
    
    /// top bar height if your collection view constraint doesn't include top bar's
    var topBarHeight: CGFloat = .zero
    
    /// inter section distances that will only be added after the sticky section
    var interSectionInsetAfterSticky: CGFloat = .zero
    
    var sectionInset: UIEdgeInsets = .zero
    
    /// delegate requirement of the flow layout. this delegate is **required**
    weak var delegate: CollectionLayoutDelegate?
    
    // MARK: - Function
    /// get current index path for a given y axis in a collection content offset. it will skip over chosen sticky section
    /// - Parameter yAxis: y axis
    /// - Returns: returns index path where y axis point at, if it doesn't find any, it will return nil.
    func getIndexPath(for yAxis: CGFloat) -> IndexPath? {
        for (sectionIndex, section) in allAttributes.enumerated() {
            for (itemIndex, item) in section.enumerated() {
                if yAxis <= item.frame.origin.y {
                    if sectionIndex != stickySection.section {
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
    
    /// clear all layout attributes, for when you want to recalculate all frames
    func clearLayoutCache() {
        allAttributes = []
        allHeaderAttributes = []
    }
    
    // MARK: - Override UICollectionViewFlowLayout
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override func prepare() {
        /// setup all attributes and header frame value
        setupAttributes()
        /// setup the sticky section
        setupSticky()
        
        let lastItemFrame: CGRect = allAttributes.last?.last?.frame ?? .zero
        /// determined the max size of the collection content
        contentSize = CGSize(width: lastItemFrame.maxX, height: lastItemFrame.maxY)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var headerAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        /// find all header attributes that fits the rect  bound of the view
        for section in allHeaderAttributes {
            for item in section where rect.intersects(item.frame) {
                headerAttributes.append(item)
            }
        }
        
        var layoutAttributes: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        /// find all item attributes that fits the rect  bound of the view
        for section in allAttributes {
            for item in section where rect.intersects(item.frame) {
                layoutAttributes.append(item)
            }
        }
        
        return headerAttributes + layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < allAttributes.count {
            if indexPath.row < allAttributes[indexPath.section].count {
                /// calculate layout attributes differently if section is after sticky section
                if indexPath.section > stickySection.section {
                    /// copy the selected attributes to preserve its origin value
                    let originalAttributes: UICollectionViewLayoutAttributes = allAttributes[indexPath.section][indexPath.row]
                    let attributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes()
                    attributes.frame = originalAttributes.frame
                    
                    let headerSize: CGSize = delegate?.collectionView(
                        collectionView ?? UICollectionView(),
                        sizeForSupplementaryView: UICollectionView.elementKindSectionHeader,
                        at: indexPath
                    ) ?? .zero
                    
                    /// update layout to include header section if it is the first item in the section
                    if indexPath.row == .zero {
                        attributes.frame.origin.y -= headerSize.height
                    }
                    
                    /// reduce y value based on the sticky section true height so that the attributes can be displayed fully
                    attributes.frame.origin.y -= stickySectionHeight
                    
                    return attributes
                }
                else {
                    return allAttributes[indexPath.section][indexPath.row]
                }
            }
        }
        
        return nil
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        /// define collection supplementary view kind
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            return allHeaderAttributes[indexPath.section][indexPath.row]
        default:
            return nil
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        return true
    }
    
    // MARK: - Private Function
    private func setupAttributes() {
        /// check if cache attributes are present, so that we don't have to calculate frames every bound changes
        guard allAttributes.isEmpty,
              allHeaderAttributes.isEmpty else { return }
        
        var yOffset: CGFloat = .zero
        
        let numberOfSections: Int = collectionView?.numberOfSections ?? .zero
        
        for section in 0 ..< numberOfSections {
            var headerSectionItems: [UICollectionViewLayoutAttributes] = []
            var sectionItems: [UICollectionViewLayoutAttributes] = []
            let numberOfItem: Int = collectionView?.numberOfItems(inSection: section) ?? .zero
            
            yOffset += sectionInset.top
            for item in 0 ..< numberOfItem {
                guard let collectionView = collectionView,
                      let delegate = delegate
                else {
                    return
                }
                let indexPath: IndexPath = IndexPath(item: item, section: section)
                
                /// append header frame attributes if item index is zero
                if item == .zero {
                    let headerSize: CGSize = delegate.collectionView(
                        collectionView,
                        sizeForSupplementaryView: UICollectionView.elementKindSectionHeader,
                        at: IndexPath(item: item, section: section)
                    )
                    
                    if headerSize.height > .zero {
                        let headerAttributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            with: indexPath
                        )
                        
                        headerAttributes.frame = CGRect(
                            x: .zero,
                            y: yOffset,
                            width: headerSize.width,
                            height: headerSize.height
                        )
                        
                        yOffset += headerSize.height
                        headerSectionItems.append(headerAttributes)
                    }
                }
                
                let size: CGSize = delegate.collectionView(
                    collectionView,
                    sizeForItemAt: IndexPath(item: item, section: section)
                )
                
                let itemSize: CGSize = size
                
                let attributes: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                /// preserve sticky section identity value.
                if section == stickySection.section, item == stickySection.item {
                    stickySectionOriginalY = yOffset
                    stickySectionHeight = size.height
                }
                
                attributes.frame = CGRect(
                    x: .zero,
                    y: yOffset,
                    width: itemSize.width,
                    height: itemSize.height
                )
                
                yOffset += itemSize.height
                sectionItems.append(attributes)
            }
            
            yOffset += sectionInset.bottom
            
            /// add inter section inset after the sticky section
            if section > stickySection.section {
                yOffset += interSectionInsetAfterSticky
            }
            
            allHeaderAttributes.append(headerSectionItems)
            allAttributes.append(sectionItems)
        }
    }
    
    private func setupSticky() {
        guard let collectionView: UICollectionView = collectionView else { return }
        
        /// all attributes must have values that exceed designated sticky section's section
        if allAttributes.count < stickySection.section {
            return
        }
        
        /// all attributes content must have values that exceed designated sticky section's item index
        if allAttributes[stickySection.section].count < stickySection.item {
            return
        }
        
        /// flow layout assume that all attributes have the sticky section in place, it will access it directly to reduce complexity of searching
        let attributes: UICollectionViewLayoutAttributes = allAttributes[stickySection.section][stickySection.item]
        
        var frame: CGRect = attributes.frame

        /// if collection offset is lower than sticky section original y, this to prevent super fast scrolling leaving the frame sticky frame behind.
        if collectionView.contentOffset.y < stickySectionOriginalY {
            frame.origin.y = stickySectionOriginalY
            attributes.frame = frame
            attributes.zIndex = 0
        }
        /// if the sticky frame lowest y value is about to go off the collection view visible view, it will stick it to the top view
        else if frame.minY < collectionView.contentOffset.y + topBarHeight {
            frame.origin.y = collectionView.contentOffset.y + topBarHeight
            attributes.frame = frame
            attributes.zIndex = 3
        }
        else {
            /// if sticky frame lowest y value is higher than the section origin y it will behave as normal. (this to make sure that even when you scroll up, it will stay sticky)
            if frame.minY > stickySectionOriginalY {
                frame.origin.y = collectionView.contentOffset.y + topBarHeight
                attributes.frame = frame
                attributes.zIndex = 3
            }
            else {
                /// if sticky frame is at the original position, it will not stick to the collection again.
                frame.origin.y = stickySectionOriginalY
                attributes.frame = frame
                attributes.zIndex = 0
            }
        }
    }
}

