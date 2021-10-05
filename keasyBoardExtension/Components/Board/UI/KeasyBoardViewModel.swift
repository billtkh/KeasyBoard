//
//  KeasyBoardViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit
import CloudKit

enum KeasyBoardState: Equatable {
    case normal
    case shiftOn
    case shiftLockOn
    case wordSelecting([KeasyWord], Int)
    case shiftLockOnAndWordSelecting([KeasyWord], Int)
    
    static func == (lhs: KeasyBoardState, rhs: KeasyBoardState) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal), (.shiftOn, .shiftOn), (.shiftLockOn, .shiftLockOn):
            return true
        case (let .wordSelecting(lhsWords, lhsPage), let .wordSelecting(rhsWords, rhsPage)):
            return lhsWords == rhsWords && lhsPage == rhsPage
        case (let .shiftLockOnAndWordSelecting(lhsWords, lhsPage), let .shiftLockOnAndWordSelecting(rhsWords, rhsPage)):
            return lhsWords == rhsWords && lhsPage == rhsPage
        default:
            return false
        }
    }
}

class KeasyBoardViewModel: NSObject {
    private(set) var proxy: UITextDocumentProxy?
    
    var currentState = Observable(KeasyBoardState.normal)
    var needsInputModeSwitchKey: Observable<Bool>
    
    private lazy var dataSource: [KeasyBoardRowViewModel] = {
        return prepareKeyboardRowViewModels(rows: KeasyBoard.arrangement)
    }()
    
    private var imeManager: KeasyInputMethodManager {
        return KeasyInputMethodManager.shared
    }
    
    init(textDocumentProxy: UITextDocumentProxy?, needsInputModeSwitchKey: Bool) {
        self.proxy = textDocumentProxy
        self.needsInputModeSwitchKey = Observable(needsInputModeSwitchKey)
        super.init()
        
        imeManager.delegate = self
    }
    
    func setShiftOn(_ on: Bool) {
        switch currentState.value {
        case .shiftLockOn, .shiftLockOnAndWordSelecting(_, _):
            currentState.next(.normal)
        default:
            currentState.next(on ? .shiftOn : .normal)
        }
    }
    
    func setShiftLockOn(_ on: Bool) {
        switch currentState.value {
        default:
            currentState.next(on ? .shiftLockOn : .normal)
        }
    }
    
    func setNeedsInputModeSwitchKey(_ needsInputModeSwitchKey: Bool) {
        self.needsInputModeSwitchKey.nextIfDifferent(needsInputModeSwitchKey)
    }
    
    func selectingWords(_ words: [KeasyWord], page: Int) {
        guard let firstRow = dataSource.first(where: { $0.index == 0 }) else { return }
        let numOfSelection = 9
        
        let firstKey = page == 0 ? KeasyKey.endSelection : KeasyKey.previousSelectionPage
        let numOfPage = Int(words.count / numOfSelection)
        let lastKey = numOfPage == 0 ? KeasyKey.selection(nil) : page == numOfPage ? KeasyKey.firstSelectionPage : KeasyKey.nextSelectionPage
        
        let startIndex = page * numOfSelection
        let endIndex = min(startIndex + numOfSelection - 1, words.count - 1)
        var currentIndex = startIndex
        for keyPair in firstRow.keyPairs {
            if keyPair == firstRow.keyPairs.first {
                keyPair.selection = KeasyKeyViewModel(firstKey)
            } else if keyPair == firstRow.keyPairs.last {
                keyPair.selection = KeasyKeyViewModel(lastKey)
            } else if currentIndex <= endIndex {
                keyPair.selection = KeasyKeyViewModel(.selection(words[currentIndex]))
                currentIndex += 1
            } else {
                keyPair.selection = KeasyKeyViewModel(.selection(nil))
            }
        }
    }
    
    func prepareKeyboardRowViewModels(rows: [KeasyBoardRow]) -> [KeasyBoardRowViewModel] {
        return rows.map { row in
            return KeasyBoardRowViewModel(row: row,
                                          in: self,
                                          shouldExcludeInputModeSwitchKey: !needsInputModeSwitchKey.value)
        }
    }
    
    func reloadDataSource() {
        dataSource = prepareKeyboardRowViewModels(rows: KeasyBoard.arrangement)
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
            let cellWidth = regularKeyWidth(in: view, for: 1)
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
        let rowIndex = indexPath.section
        let row = dataSource[rowIndex]
        let mainKey = row.keyPairs[indexPath.row].main
        
        let height = keyHeight
        
        switch mainKey.size {
        case .regular:
            let regularKeyWidth = regularKeyWidth(in: view, for: min(rowIndex, 1))
            return CGSize(width: regularKeyWidth, height: height)
        case .large:
            let largeKeyWidth = largeKeyWidth(in: view)
            return CGSize(width: largeKeyWidth, height: height)
        case .flexible:
            let spacingBetweenKeys = row.totalMinimumSpacingBetweenKeys
            let numOfRegularKeys = row.numOfKeys(size: .regular)
            let totalWidthOfRegularKeys = regularKeyWidth(in: view, for: 1) * Double(numOfRegularKeys)
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
    
    /// regular key size for row assuming key sizes are distrubuted
    func regularKeyWidth(in view: UIView, for row: Int) -> Double {
        guard let row = dataSource.first(where: { $0.index == row }) else { return 0 }
        
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
        
        let regularKeyWidth = regularKeyWidth(in: view, for: 1)
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
        let primaryKey = keyPair.primaryKey.key
        
        switch primaryKey {
        case .shift:
            setShiftOn(!isShiftOn)
            imeManager.eraseKeyBuffer()
            
        case .delete:
            imeManager.eraseKeyBuffer()
            proxy.deleteBackward()
            
        case .firstSelectionPage:
            if case let .wordSelecting(words, _) = currentState.value {
                currentState.next(.wordSelecting(words, 0))
            }
            
        case .previousSelectionPage:
            if case let .wordSelecting(words, page) = currentState.value {
                currentState.next(.wordSelecting(words, page - 1))
            }
            
        case .nextSelectionPage:
            if case let .wordSelecting(words, page) = currentState.value {
                currentState.next(.wordSelecting(words, page + 1))
            }
            
        case .space:
            imeManager.eraseKeyBuffer()
            proxy.insertText(" ")
            
        case let .typing(key):
            imeManager.inputKey(key: key)
            proxy.insertText(key)
            
        case let .selection(word):
            imeManager.eraseKeyBuffer()
            guard let word = word else { return }
            for _ in Array(word.keys) {
                proxy.deleteBackward()
            }
            proxy.insertText(word.word)
            
        default:
            imeManager.eraseKeyBuffer()
        }
    }
    
    func didLongPress(keyPair: KeasyKeyPairViewModel) {
        let primaryKey = keyPair.primaryKey.key
        switch primaryKey {
        case .shift:
            setShiftLockOn(!isShiftLockOn)
            
        default:
            break
        }
    }
}

extension KeasyBoardViewModel: KeasyInputMethodManagerDelegate {
    var isWordSelecting: Bool {
        switch currentState.value {
        case .wordSelecting(_, _), .shiftLockOnAndWordSelecting(_, _):
            return true
        default:
            return false
        }
    }
    
    var isShiftOn: Bool {
        switch currentState.value {
        case .shiftOn:
            return true
        default:
            return false
        }
    }
    
    var isShiftLockOn: Bool {
        switch currentState.value {
        case .shiftLockOn, .shiftLockOnAndWordSelecting(_, _):
            return true
        default:
            return false
        }
    }
    
    func keysInInputBuffer(keys: String, didMatch anyWords: [KeasyWord]) {
        if anyWords.isEmpty {
            currentState.nextIfDifferent(isShiftLockOn ? .shiftLockOn : .normal)
        } else {
            let startPage = 0
            currentState.next(isShiftLockOn ? .shiftLockOnAndWordSelecting(anyWords, startPage) : .wordSelecting(anyWords, startPage))
        }
//        print("keys: \(keys) construct words: \(anyWords)")
    }
    
    func didEraseInputBuffer() {
        currentState.next(isWordSelecting ? .normal : currentState.value)
    }
}
