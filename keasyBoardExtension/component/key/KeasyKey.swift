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

enum KeasyKey {
    // control keys
    case shift
    case backspace
    case emoji
    case inputSwitch
    case space
    case enter
    
    // alphanumeric keys
    case typing(String)
    
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
    
    var title: String {
        switch self {
        case let .typing(title):
            return title
        case .inputSwitch:
            return "⚙︎"
        case .emoji:
            return "😀"
        case .backspace:
            return "del"
        default:
            return String(describing: self)
        }
    }
}
