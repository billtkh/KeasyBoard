//
//  KeasyBoardViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit

class KeasyBoardViewModel: NSObject {
    private(set) var proxy: UITextDocumentProxy?
    
    var isShiftOn = Observable(false)
    var isShiftLockOn = Observable(false)
    
    private lazy var dataSource: [KeasyBoardRowViewModel] = {
        return KeasyBoard.arrangement.map { row in
            return KeasyBoardRowViewModel(row: row, in: self)
        }
    }()
    
    init(textDocumentProxy: UITextDocumentProxy?) {
        self.proxy = textDocumentProxy
    }
    
    func setShiftOn(_ on: Bool) {
        if isShiftLockOn.value {
            isShiftLockOn.value = false
        }
        
        isShiftOn.next(on)
    }
    
    func setShiftLockOn(_ on: Bool) {
        isShiftOn.value = on
        
        isShiftLockOn.next(on)
    }
}
    
extension KeasyBoardViewModel {
    private var spacingManager: KeasySpacingManager {
        return KeasySpacingManager.shared
    }
    
    var boardSpacing: Double {
        return spacingManager.boardSpacing
    }
    
    var keySpacing: Double {
        return spacingManager.keySpacing
    }
    
    var rowSpacing: Double {
        return spacingManager.rowSpacing
    }
    
    var boardHeight: Double {
        return spacingManager.boardHeight
    }
    
    func keyViewModelAt(indexPath: IndexPath) -> KeasyKeyPairViewModel {
        return dataSource[indexPath.section].keyPairs[indexPath.row]
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return dataSource[section].keyPairs.count
    }
    
    var numberOfSections: Int {
        return dataSource.count
    }
    
    func insetOfSection(in view: UIView, section: Int) -> UIEdgeInsets {
        let topSpacing = section == 0 ? rowSpacing : 0
        switch dataSource[section].arrangementType {
        case .distributed:
            let row = dataSource[section]
            let viewWidth = view.frame.width
            let cellWidth = regularKeyWidth(in: view)
            let totalCellWidth: CGFloat = CGFloat(cellWidth * CGFloat(row.keyPairs.count))
            let spacingWithinCells: CGFloat = row.totalMinimumSpacingBetweenKeys
            var horizontalSpacing: CGFloat = CGFloat(viewWidth - totalCellWidth - spacingWithinCells) / 2
            horizontalSpacing = max(horizontalSpacing, boardSpacing)
            return UIEdgeInsets(top: topSpacing, left: horizontalSpacing, bottom: rowSpacing, right: horizontalSpacing)
        case .mixed:
            return UIEdgeInsets(top: topSpacing, left: boardSpacing, bottom: rowSpacing, right: boardSpacing)
        }
    }
    
    func sizeForItem(in view: UIView, at indexPath: IndexPath) -> CGSize {
        let row = dataSource[indexPath.section]
        let mainKey = row.keyPairs[indexPath.row].main
        
        let height = keyHeight
        
        switch mainKey.size {
        case .regular:
            let regularKeyWidth = regularKeyWidth(in: view)
            return CGSize(width: regularKeyWidth, height: height)
        case .large:
            let largeKeyWidth = largeKeyWidth(in: view)
            return CGSize(width: largeKeyWidth, height: height)
        case .flexible:
            let spacingBetweenKeys = row.totalMinimumSpacingBetweenKeys
            let numOfRegularKeys = row.numOfKeys(size: .regular)
            let totalWidthOfRegularKeys = regularKeyWidth(in: view) * Double(numOfRegularKeys)
            let numOfLargeKeys = row.numOfKeys(size: .large)
            let totalWidthOfLargeKeys = largeKeyWidth(in: view) * Double(numOfLargeKeys)
            
            let viewWidth = view.frame.width - boardSpacing - boardSpacing - 0.1
            let flexibleKeyWidth = viewWidth - spacingBetweenKeys - totalWidthOfRegularKeys - totalWidthOfLargeKeys
            return CGSize(width: flexibleKeyWidth, height: height)
        }
    }
    
    var keyHeight: Double {
        let viewHeight = boardHeight - rowSpacing * Double(dataSource.count + 1) - 0.1
        let numOfRow = dataSource.count
        let height = viewHeight / Double(numOfRow)
        return height
    }
    
    /// regular key size is calculated by the first row typing keys
    func regularKeyWidth(in view: UIView) -> Double {
        guard let row = dataSource.first(where: { $0.index == 0 }) else { return 0 }
        
        let viewWidth = view.frame.width - boardSpacing - boardSpacing - 0.1
        let numOfKey = row.keyPairs.count
        let regularWidth = (viewWidth - row.totalMinimumSpacingBetweenKeys) / Double(numOfKey)
        return regularWidth
    }
    
    /// large key size is calculated by the fourth row control keys
    func largeKeyWidth(in view: UIView) -> Double {
        guard let row = dataSource.first(where: { $0.index == 3 }) else { return 0 }
        
        let viewWidth = view.frame.width - boardSpacing - boardSpacing - 0.1
        let totalMinimumSpacingWithinKeys = row.totalMinimumSpacingBetweenKeys
        
        let regularKeyWidth = regularKeyWidth(in: view)
        let numOfRegularKey = row.keyPairs.filter({ $0.main.size == .regular }).count
        let totalWidthOfRegularKeys = Double(numOfRegularKey) * regularKeyWidth
        
        let numOfLargeKey = row.keyPairs.filter({ $0.main.size == .large }).count
        var largeKeyWidth = (viewWidth - totalMinimumSpacingWithinKeys - totalWidthOfRegularKeys) / Double(numOfLargeKey)
        largeKeyWidth = min(largeKeyWidth, regularKeyWidth * 2)
        return largeKeyWidth
    }
}

extension KeasyBoardViewModel {
    func didTap(keyPair: KeasyKeyPairViewModel) {
        guard let proxy = proxy else { return }
        switch keyPair.primaryKey.key {
        case .shift:
            break
        case .typing(let value):
            proxy.insertText(value)
        default:
            break
        }
    }
}
