//
//  KeasyKeyPairViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

enum KeasyToggleState {
    case off
    case on
    case locked
}

class KeasyKeyPairViewModel: NSObject {
    private var keyPair: KeasyKeyPair
    private(set) var main: KeasyKeyViewModel
    private(set) var sub: KeasyKeyViewModel?
    private(set) var board: KeasyBoardViewModel
    
    init(_ keyPair: KeasyKeyPair, in board: KeasyBoardViewModel) {
        self.keyPair = keyPair
        self.main = KeasyKeyViewModel(keyPair.main)
        self.board = board
        
        if let subKey = keyPair.sub {
            self.sub = KeasyKeyViewModel(subKey)
        }
    }
    
    var isToggleHidden: Bool {
        return main.isToggleHidden
    }
    
    var toggleState: KeasyToggleState {
        if isShiftLockOn {
            return .locked
        } else if isShiftOn {
            return .on
        } else {
            return .off
        }
    }
    
    var isShiftOn: Bool {
        return board.isShiftOn.value
    }
    
    var isShiftLockOn: Bool {
        return board.isShiftLockOn.value
    }
    
    var primaryKey: KeasyKeyViewModel {
        if board.isShiftOn.value || board.isShiftLockOn.value {
            return sub ?? main
        } else {
            return main
        }
    }
    
    var secondaryKey: KeasyKeyViewModel? {
        if board.isShiftOn.value || board.isShiftLockOn.value {
            return sub == nil ? nil : main
        } else {
            return sub
        }
    }
}
