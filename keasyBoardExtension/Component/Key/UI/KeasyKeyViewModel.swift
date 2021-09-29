//
//  KeasyKeyViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation

class KeasyKeyViewModel: NSObject {
    var key: KeasyKey
    
    init(_ key: KeasyKey) {
        self.key = key
    }
    
    var size: KeasyKeySize {
        return key.size
    }
}
