//
//  KeasyBoardRowViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation

class KeasyBoardRowViewModel: NSObject {
    private var row: KeasyBoardRow
    private(set) var keyPairs: [KeasyKeyPairViewModel]
    
    var spacingManager: KeasySpacingManager {
        return KeasySpacingManager.shared
    }
    
    init(row: KeasyBoardRow, in board: KeasyBoardViewModel, shouldExcludeInputModeSwitchKey: Bool = false) {
        self.row = row
        self.keyPairs = row.keyPairs.compactMap { keyPair in
            if shouldExcludeInputModeSwitchKey {
                switch keyPair.main {
                case .inputModeSwitch:
                    return nil
                default:
                    return KeasyKeyPairViewModel(keyPair, in: board)
                }
            } else {
                return KeasyKeyPairViewModel(keyPair, in: board)
            }
        }
    }
    
    var index: Int {
        return row.index
    }
    
    var arrangementType: KeasyBoardRowArrangementType {
        return row.arrangementType
    }
    
    var keySpacing: Double {
        return spacingManager.keySpacing
    }
    
    var totalMinimumSpacingBetweenKeys: Double {
        return Double(row.keyPairs.count - 1) * keySpacing
    }
    
    func numOfKeys(size: KeasyKeySize) -> Int {
        return keyPairs.filter { $0.main.size == size }.count
    }
}
