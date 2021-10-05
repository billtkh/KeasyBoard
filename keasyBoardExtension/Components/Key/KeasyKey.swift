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
    case next
    
    // alphanumeric keys
    case typing(String)
    
    // selection
    case selection(KeasyWord?)
    case endSelection
    case previousSelectionPage
    case nextSelectionPage
    
    var size: KeasyKeySize {
        switch self {
        case .delete, .shift, .next:
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
        case let .selection(word):
            return word?.word ?? ""
        default:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case let .typing(text):
            return text
        case let .selection(word):
            return word?.word ?? ""
        case .inputModeSwitch:
            return "⚙︎"
        case .emoji:
            return "😀"
        case .next:
            return "⏎"
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
        case .delete, .shift, .next, .space, .function:
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
