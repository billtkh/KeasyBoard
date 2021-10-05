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
    
    var selection: KeasyKeyViewModel?
    
    init(_ keyPair: KeasyKeyPair,
         in board: KeasyBoardViewModel) {
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
        guard !isToggleHidden else { return .off }
        
        if isShiftLockOn {
            return .locked
        } else if isShiftOn {
            return .on
        } else {
            return .off
        }
    }
    
    var isShiftOn: Bool {
        return board.isShiftOn
    }
    
    var isShiftLockOn: Bool {
        return board.isShiftLockOn
    }
    
    var primaryKey: KeasyKeyViewModel {
        if let selection = selection, board.isWordSelecting {
            return selection
        } else if isShiftLockOn || isShiftOn {
            return sub ?? main
        } else {
            return main
        }
    }
    
    var secondaryKey: KeasyKeyViewModel? {
        if let _ = selection, board.isWordSelecting {
            return main
        } else if isShiftLockOn || isShiftOn {
            return sub == nil ? nil : main
        } else {
            return sub
        }
    }
}
