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

enum KeasyKeyTitleSize {
    case regular
    case small
}

enum KeasyKey {
    // control keys
    case function
    case shift
    case delete
    case emoji
    case inputModeSwitch
    case space
    case returnText
    
    // alphanumeric keys
    case typing(String)
    
    var size: KeasyKeySize {
        switch self {
        case .delete, .shift, .returnText:
            return .large
        case .space:
            return .flexible
        default:
            return .regular
        }
    }
    
    var text: String {
        switch self {
        case let .typing(text):
            return text
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case let .typing(text):
            return text
        case .inputModeSwitch:
            return "⚙︎"
        case .emoji:
            return "😀"
        case .returnText:
            return "return"
        case .space:
            return ""
        case .function:
            return "fn"
        default:
            return String(describing: self)
        }
    }
    
    var titleSize: KeasyKeyTitleSize {
        switch self {
        case .delete, .shift, .returnText, .space, .function:
            return .small
        default:
            return .regular
        }
    }
    
    var canToggle: Bool {
        switch self {
        case .shift:
            return true
        default:
            return false
        }
    }
}
