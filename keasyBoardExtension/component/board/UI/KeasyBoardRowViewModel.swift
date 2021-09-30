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
    
    var spacingManager: KeasyBoardSpacingManager {
        return KeasyBoardSpacingManager.shared
    }
    
    init(row: KeasyBoardRow) {
        self.row = row
        self.keyPairs = row.keyPairs.viewModels
    }
    
    var index: Int {
        return row.index
    }
    
    var arrangementType: KeasyBoardRowArrangementType {
        return row.arrangementType
    }
    
    var keyPadding: Double {
        return spacingManager.keyPadding
    }
    
    var totalMinimumSpacingBetweenKeys: Double {
        return Double(row.keyPairs.count - 1) * keyPadding
    }
    
    func numOfKeys(size: KeasyKeySize) -> Int {
        return keyPairs.filter { $0.main.size == size }.count
    }
}
