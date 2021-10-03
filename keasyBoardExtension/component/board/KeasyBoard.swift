//
//  KeasyBoard.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation

class KeasyBoard {
    static let arrangement: [KeasyBoardRow] = [
        KeasyBoardRow(index: 0, arrangementType: .distributed, keyPairs: [
            KeasyKeyPair(main: .typing("1"), sub: .typing("!")),
            KeasyKeyPair(main: .typing("2"), sub: .typing("@")),
            KeasyKeyPair(main: .typing("3"), sub: .typing("#")),
            KeasyKeyPair(main: .typing("4"), sub: .typing("$")),
            KeasyKeyPair(main: .typing("5"), sub: .typing("%")),
            KeasyKeyPair(main: .typing("6"), sub: .typing("^")),
            KeasyKeyPair(main: .typing("7"), sub: .typing("&")),
            KeasyKeyPair(main: .typing("8"), sub: .typing("*")),
            KeasyKeyPair(main: .typing("9"), sub: .typing("(")),
            KeasyKeyPair(main: .typing("0"), sub: .typing(")")),
        ]),
        KeasyBoardRow(index: 1, arrangementType: .distributed, keyPairs: [
            KeasyKeyPair(main: .typing("q"), sub: .typing("Q")),
            KeasyKeyPair(main: .typing("w"), sub: .typing("W")),
            KeasyKeyPair(main: .typing("e"), sub: .typing("E")),
            KeasyKeyPair(main: .typing("r"), sub: .typing("R")),
            KeasyKeyPair(main: .typing("t"), sub: .typing("T")),
            KeasyKeyPair(main: .typing("y"), sub: .typing("Y")),
            KeasyKeyPair(main: .typing("u"), sub: .typing("U")),
            KeasyKeyPair(main: .typing("i"), sub: .typing("I")),
            KeasyKeyPair(main: .typing("o"), sub: .typing("I")),
            KeasyKeyPair(main: .typing("p"), sub: .typing("P")),
        ]),
        KeasyBoardRow(index: 2, arrangementType: .distributed, keyPairs: [
            KeasyKeyPair(main: .typing("a"), sub: .typing("A")),
            KeasyKeyPair(main: .typing("s"), sub: .typing("S")),
            KeasyKeyPair(main: .typing("d"), sub: .typing("D")),
            KeasyKeyPair(main: .typing("f"), sub: .typing("F")),
            KeasyKeyPair(main: .typing("g"), sub: .typing("G")),
            KeasyKeyPair(main: .typing("h"), sub: .typing("H")),
            KeasyKeyPair(main: .typing("j"), sub: .typing("J")),
            KeasyKeyPair(main: .typing("k"), sub: .typing("K")),
            KeasyKeyPair(main: .typing("l"), sub: .typing("L")),
        ]),
        KeasyBoardRow(index: 3, arrangementType: .mixed, keyPairs: [
            KeasyKeyPair(main: .shift),
            KeasyKeyPair(main: .typing("z"), sub: .typing("Z")),
            KeasyKeyPair(main: .typing("x"), sub: .typing("X")),
            KeasyKeyPair(main: .typing("c"), sub: .typing("C")),
            KeasyKeyPair(main: .typing("v"), sub: .typing("V")),
            KeasyKeyPair(main: .typing("b"), sub: .typing("B")),
            KeasyKeyPair(main: .typing("n"), sub: .typing("N")),
            KeasyKeyPair(main: .typing("m"), sub: .typing("M")),
            KeasyKeyPair(main: .delete),
        ]),
        KeasyBoardRow(index: 4, arrangementType: .mixed, keyPairs: [
            KeasyKeyPair(main: .function),
            KeasyKeyPair(main: .emoji),
            KeasyKeyPair(main: .inputModeSwitch),
            KeasyKeyPair(main: .space),
            KeasyKeyPair(main: .typing(","), sub: .typing("<")),
            KeasyKeyPair(main: .typing("."), sub: .typing(">")),
            KeasyKeyPair(main: .typing("/"), sub: .typing("?")),
            KeasyKeyPair(main: .returnText),
        ]),
    ]
}

