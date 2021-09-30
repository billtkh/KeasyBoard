//
//  KeasyKeyViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation

class KeasyKeyViewModel: NSObject {
    var key: KeasyKey
    var isToggleOn: Observable<Bool> = .init(false)
    
    init(_ key: KeasyKey) {
        self.key = key
    }
    
    var size: KeasyKeySize {
        return key.size
    }
    
    var title: String {
        return key.title
    }
    
    var titleSize: KeasyKeyTitleSize {
        return key.titleSize
    }
    
    var isToggleHidden: Bool {
        return !key.canToggle
    }
}
