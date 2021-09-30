//
//  KeasyKeyPairViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

class KeasyKeyPairViewModel: NSObject {
    private var keyPair: KeasyKeyPair
    private(set) var main: KeasyKeyViewModel
    private(set) var sub: KeasyKeyViewModel?
    
    init(_ keyPair: KeasyKeyPair) {
        self.keyPair = keyPair
        self.main = KeasyKeyViewModel(keyPair.main)
        
        if let subKey = keyPair.sub {
            self.sub = KeasyKeyViewModel(subKey)
        }
    }
    
    var isToggleHidden: Bool {
        return main.isToggleHidden
    }
    
    var isToggleOn: Observable<Bool> {
        return main.isToggleOn
    }
    
    func setToggle(_ on: Bool) {
        main.isToggleOn.value = on
    }
}
