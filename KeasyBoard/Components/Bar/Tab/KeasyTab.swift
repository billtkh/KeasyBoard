//
//  KeasyTab.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 7/10/2021.
//

import Foundation

enum KeasyTab {
    case inputBuffer(String)
}

extension KeasyTab {
    var title: String {
        switch self {
        case let .inputBuffer(text):
            return text
        default:
            return String(describing: self)
        }
    }
    
    var titleSize: KeasyKeyTitleSize {
        switch self {
        default:
            return .regular
        }
    }
}
