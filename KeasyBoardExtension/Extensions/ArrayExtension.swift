//
//  ArrayExtension.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

extension Array where Element == KeasyKey {
    var viewModels: [KeasyKeyViewModel] {
        return map { key in
            return KeasyKeyViewModel(key)
        }
    }
}
