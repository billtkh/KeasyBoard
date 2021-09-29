//
//  KeasyBoard.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation

class KeasyBoard {
    static let arrangement: [KeasyBoardRow] = [
        KeasyBoardRow(index: 0, arrangementType: .distributed, keys: [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero]),
        KeasyBoardRow(index: 1, arrangementType: .distributed, keys: [.q, .w, .e, .r, .t, .y, .u, .i, .o, .p]),
        KeasyBoardRow(index: 2, arrangementType: .distributed, keys: [.a, .s, .d, .f, .g, .h, .j, .k, .l]),
        KeasyBoardRow(index: 3, arrangementType: .mixed, keys: [.shift, .z, .x, .c, .v, .b, .n, .m, .backspace]),
        KeasyBoardRow(index: 4, arrangementType: .mixed, keys: [.emoji, .inputSwitch, .space, .comma, .stop, .slash, .enter]),
    ]
}

