//
//  KeasyBoardRow.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation

enum KeasyBoardRowArrangementType {
    case distributed
    case mixed
}

struct KeasyBoardRow {
    var index: Int
    var arrangementType: KeasyBoardRowArrangementType
    var keys: [KeasyKey]
}
