//
//  KeasyBoardViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit

class KeasyBoardViewModel: NSObject {
    private var dataSource: [[KeasyKeyViewModel]] = {
        return KeasyBoard.arrangement.map { keys in
            return keys.map { key in
                return KeasyKeyViewModel(key)
            }
        }
    }()
    
    var boardHeight = UIScreen.main.bounds.height * 0.3
    
    var sectionSpacing: CGFloat = 8
    var rowSpacing: CGFloat = 4
    
    func keyViewModelAt(indexPath: IndexPath) -> KeasyKeyViewModel {
        return dataSource[indexPath.section][indexPath.row]
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return dataSource[section].count
    }
    
    var numberOfSections: Int {
        return dataSource.count
    }
    
    func insetOfSection(in collectionView: UICollectionView, section: Int) -> UIEdgeInsets {
        let topSpacing = section == 0 ? sectionSpacing : 0
        
        let viewWidth = collectionView.frame.width
        let cellWidth = widthForItemIn(collectionView: collectionView, section: section)
        let totalCellWidth: CGFloat = CGFloat(cellWidth * CGFloat(dataSource[section].count))
        let spacingWithinCells: CGFloat = CGFloat(dataSource[section].count) * rowSpacing - rowSpacing
        var horizontalSpacing: CGFloat = CGFloat(viewWidth - totalCellWidth - spacingWithinCells) / 2
        horizontalSpacing = max(horizontalSpacing, sectionSpacing)
        return UIEdgeInsets(top: topSpacing, left: horizontalSpacing, bottom: sectionSpacing, right: horizontalSpacing)
    }
    
    func sizeForItemIn(collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        let viewHeight = boardHeight - sectionSpacing * CGFloat(dataSource.count + 1)
        let numOfRow = dataSource.count
        let height: CGFloat = viewHeight / CGFloat(numOfRow)
    
        let width = widthForItemIn(collectionView: collectionView, section: indexPath.section)
        
        return CGSize(width: width, height: height)
    }
    
    func widthForItemIn(collectionView: UICollectionView, section: Int) -> CGFloat {
        let viewWidth = collectionView.frame.width - sectionSpacing - sectionSpacing
        let numOfItem = dataSource.first?.count ?? dataSource[section].count
        let width: CGFloat = viewWidth / CGFloat(numOfItem) - rowSpacing
        return floor(width)
    }
}
