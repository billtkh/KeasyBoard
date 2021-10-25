//
//  ArrayExtension.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

extension Array where Element == KeasyKey {
    var viewModels: [KeasyKeyViewModel] { return map { KeasyKeyViewModel($0) } }
}

extension Array where Element == KeasyTab {
    var viewModels: [KeasyTabViewModel] { return map { KeasyTabViewModel($0) } }
}
