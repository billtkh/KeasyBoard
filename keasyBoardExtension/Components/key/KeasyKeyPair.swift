//
//  KeasyKeyPair.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

struct KeasyKeyPair {
    var main: KeasyKey
    var sub: KeasyKey?
    
    init(main: KeasyKey, sub: KeasyKey? = nil) {
        self.main = main
        self.sub = sub
    }
}
