//
//  KeasyKey.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit

enum KeasyKeySize {
    case regular
    case large
    case flexible
}

enum KeasyKeyTitleSize {
    case regular
    case small
    case large
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
    case firstSelectionPage
}
    
extension KeasyKey {
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
        case .space:
            return " "
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
            return ""
        case .next:
            return "⏎"
        case .space:
            return ""
        case .function:
            return "fn"
        case .endSelection:
            return ""
        case .previousSelectionPage:
            return "←"
        case .nextSelectionPage:
            return "→"
        case .firstSelectionPage:
            return "⇤"
        default:
            return String(describing: self)
        }
    }
    
    var shiftedTitle: String {
        switch self {
        default:
            return title
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .endSelection:
            return UIImage(named: "icon_cancel")?.withRenderingMode(.alwaysTemplate)
        case .emoji:
            return UIImage(named: "icon_emoji")?.withRenderingMode(.alwaysTemplate)
        default:
            return nil
        }
    }
    
    var titleSize: KeasyKeyTitleSize {
        switch self {
        case .delete, .shift, .space, .function:
            return .small
        case .emoji, .firstSelectionPage, .inputModeSwitch:
            return .large
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
