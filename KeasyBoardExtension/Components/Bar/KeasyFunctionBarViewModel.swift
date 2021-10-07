//
//  KeasyFunctionBarViewModel.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 7/10/2021.
//

import Foundation
import UIKit

class KeasyFunctionBarViewModel: NSObject {
    
    private(set) var board: KeasyBoardViewModel
    
    init(board: KeasyBoardViewModel) {
        self.board = board
    }
    
    private lazy var dataSource: [KeasyTabViewModel] = {
        return prepareTabsViewModels()
    }()
    
    private var imeManager: KeasyInputMethodManager {
        return KeasyInputMethodManager.shared
    }
    
    private var feedbackManager: KeasyFeedbackManager {
        return KeasyFeedbackManager.shared
    }
    
    func prepareTabsViewModels() -> [KeasyTabViewModel] {
        let presetTabs: [KeasyTab] = {
            let inputBuffer = imeManager.inputBuffer.value
            guard !inputBuffer.isEmpty else { return [] }
            let englishTab = KeasyTab.inputBuffer(inputBuffer)
            let keys = inputBuffer.map { String($0).cangjieCode }
            let keysTab = KeasyTab.inputBuffer(keys.joined())
            
            return [
                englishTab,
                keysTab
            ]
        }()
        
        return presetTabs.viewModels
    }
    
    func reloadDataSource() {
        dataSource = prepareTabsViewModels()
    }
    
    func didTap(tab: KeasyTabViewModel) {
        board.handleTab(tab)
    }
    
    func didLongPress(tab: KeasyTabViewModel) {
//        board.handleTab(tab)
    }
}

extension KeasyFunctionBarViewModel {
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
        return spacingManager.boardHeight - spacingManager.barHeight
    }
    
    func viewModelAt(indexPath: IndexPath) -> KeasyTabViewModel {
        return dataSource[indexPath.row]
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return dataSource.count
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    func insetOfSection(in view: UIView, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func sizeForItem(in view: UIView, at indexPath: IndexPath) -> CGSize {
        let tabHeight = spacingManager.barHeight
        let tab = dataSource[indexPath.row]
        let font = tab.titleFont
        let contentWidth = tab.title.widthOfString(usingFont: font)
        let tabWidth = contentWidth + spacingManager.barHorizontalPadding + spacingManager.barHorizontalPadding
        let minWidth = max(tabHeight, tabWidth)
        return CGSize(width: minWidth, height: tabHeight)
    }
}
