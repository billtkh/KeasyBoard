//
//  KeasyKey.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation

enum KeasyKeySize {
    case regular
    case large
    case flexible
}

enum KeasyKey: String {
    // Typing keys
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    
    case q
    case w
    case e
    case r
    case t
    case y
    case u
    case i
    case o
    case p
    
    case a
    case s
    case d
    case f
    case g
    case h
    case j
    case k
    case l
    
    case z
    case x
    case c
    case v
    case b
    case n
    case m
    
    case comma = ","
    case stop = "."
    case slash = "/"
    
    // Control keys
    case shift = "shift"
    case backspace = "del"
    case emoji = "😀"
    case inputSwitch = "⚙︎"
    case space
    case enter
    
    var size: KeasyKeySize {
        switch self {
        case .backspace, .shift, .enter:
            return .large
        case .space:
            return .flexible
        default:
            return .regular
        }
    }
}
