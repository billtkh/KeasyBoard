//
//  KeasyBoardViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum KeasyBoardState: Equatable {
    case normal
    case shiftOn
    case shiftLockOn
    
    static func == (lhs: KeasyBoardState, rhs: KeasyBoardState) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .normal), (.shiftOn, .shiftOn), (.shiftLockOn, .shiftLockOn):
            return true
        default:
            return false
        }
    }
}

struct KeasyWordSelection: Equatable {
    let words: [KeasyWord]
    let page: Int
}

protocol KeasyBoardFeedbackDelegate: AnyObject {
    func feedbackToTap()
    func feedbackToLongPress()
}

class KeasyBoardViewModel: NSObject {
    private(set) var proxy: UITextDocumentProxy?
    
    var currentState = BehaviorRelay(value: KeasyBoardState.normal)
    var currentWordSelection: BehaviorRelay<KeasyWordSelection?> = BehaviorRelay(value: nil)
    
    var needsInputModeSwitchKey = BehaviorRelay(value: false)
    
    let numOfSelection = 9
    
    private weak var feedbackDelegate: KeasyBoardFeedbackDelegate?
    
    private lazy var dataSource: [KeasyBoardRowViewModel] = {
        return prepareKeyboardRowViewModels(rows: KeasyBoard.arrangement)
    }()
    
    private var imeManager: KeasyInputMethodManager {
        return KeasyInputMethodManager.shared
    }
    
    init(textDocumentProxy: UITextDocumentProxy?, needsInputModeSwitchKey: Bool) {
        self.proxy = textDocumentProxy
        super.init()
        
        feedbackDelegate = KeasyFeedbackManager.shared
        imeManager.delegate = self
    }
    
    func setShiftOn(_ on: Bool) {
        switch currentState.value {
        case .shiftLockOn:
            currentState.accept(.normal)
        default:
            currentState.accept(on ? .shiftOn : .normal)
        }
    }
    
    func setShiftLockOn(_ on: Bool) {
        switch currentState.value {
        default:
            currentState.accept(on ? .shiftLockOn : .normal)
        }
    }
    
    func setNeedsInputModeSwitchKey(_ needsInputModeSwitchKey: Bool) {
        self.needsInputModeSwitchKey.accept(needsInputModeSwitchKey)
    }
    
    func selectingWords(_ words: [KeasyWord], page: Int) {
        guard let firstRow = dataSource.first(where: { $0.index == 0 }) else { return }
        let numOfPage = Int(words.count / numOfSelection)
        let toPage = min(page, numOfPage)
        
        let firstKey = toPage == 0 ? KeasyKey.endSelection : KeasyKey.previousSelectionPage
        let lastKey = numOfPage == 0 ? KeasyKey.selection(nil) : toPage == numOfPage ? KeasyKey.firstSelectionPage : KeasyKey.nextSelectionPage
        
        let startIndex = toPage * numOfSelection
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
        return spacingManager.boardHeight - 28.0
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
    func resetShiftStateIfNeeded(tapped key: KeasyKey) {
        if isShiftLockOn {
            switch key {
            case .shift:
                setShiftLockOn(false)
            default:
                break
            }
        } else {
            switch key {
            case .shift:
                setShiftOn(!isShiftOn)
            default:
                setShiftOn(false)
            }
        }
    }
    
    func didTap(keyPair: KeasyKeyPairViewModel) {
        feedbackDelegate?.feedbackToTap()
        
        guard let proxy = proxy else { return }
        let primaryKey = keyPair.primaryKey.key
        
        resetShiftStateIfNeeded(tapped: primaryKey)

        switch primaryKey {
        case .shift:
            // do not erase input buffer for shifting
            break
            
        case .delete:
            _ = imeManager.popInputBuffer()
            proxy.deleteBackward()
            
        case .endSelection:
            imeManager.eraseInputBuffer()
            currentWordSelection.accept(nil)
            
        case .firstSelectionPage:
            if let wordSelection = currentWordSelection.value {
                currentWordSelection.accept(KeasyWordSelection(words: wordSelection.words, page: 0))
            }
            
        case .previousSelectionPage:
            if let wordSelection = currentWordSelection.value {
                currentWordSelection.accept(KeasyWordSelection(words: wordSelection.words, page: wordSelection.page - 1))
            }
            
        case .nextSelectionPage:
            if let wordSelection = currentWordSelection.value {
                let numOfPage = Int(wordSelection.words.count / numOfSelection)
                currentWordSelection.accept(KeasyWordSelection(words: wordSelection.words, page: min(wordSelection.page + 1, numOfPage)))
            }
            
        case .space:
            if let wordSelection = currentWordSelection.value {
                let numOfPage = Int(wordSelection.words.count / numOfSelection)
                
                if wordSelection.page + 1 > numOfPage {
                    currentWordSelection.accept(KeasyWordSelection(words: wordSelection.words, page: 0))
                } else {
                    currentWordSelection.accept(KeasyWordSelection(words: wordSelection.words, page: wordSelection.page + 1))
                }
            }
            
            let space = KeasyKey.space.text
            if proxy.documentContextBeforeInput?.hasSuffix(space) == false || imeManager.isInputBufferEmpty {
                imeManager.inputKey(key: space)
                proxy.insertText(space)
            }
            
        case .next:
            imeManager.eraseInputBuffer()
            proxy.insertText("\n")
            
        case let .typing(key):
            if proxy.documentContextBeforeInput?.hasSuffix(KeasyKey.space.text) == true {
                imeManager.resetInputBuffer()
            }
            
            imeManager.inputKey(key: key)
            proxy.insertText(key)
            
        case let .selection(word):
            imeManager.eraseInputBuffer()
            guard let word = word else { return }
            if proxy.documentContextBeforeInput?.hasSuffix(KeasyKey.space.text) == true {
                proxy.deleteBackward()
            }
            for _ in Array(word.keys) {
                proxy.deleteBackward()
            }
            proxy.insertText(word.word)
            
        default:
            imeManager.eraseInputBuffer()
        }
    }
    
    func didLongPress(keyPair: KeasyKeyPairViewModel) {
        feedbackDelegate?.feedbackToLongPress()
        
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
        return currentWordSelection.value != nil
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
        case .shiftLockOn:
            return true
        default:
            return false
        }
    }
    
    func keysInInputBuffer(keys: String, didMatch anyWords: [KeasyWord]) {
        let startPage = 0
        currentWordSelection.accept(KeasyWordSelection(words: anyWords, page: startPage))
        
//        print("keys: \(keys) construct words: \(anyWords)")
    }
    
    func didEraseInputBuffer() {
        currentWordSelection.accept(nil)
    }
}
