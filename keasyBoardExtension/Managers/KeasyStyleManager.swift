//
//  KeasyStyleManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit

enum KeasyStyle {
    case light
    case dark
}

class KeasyStyleManager: NSObject {
    static let shared = KeasyStyleManager()
    
    var currentStyle: KeasyStyle!
}

extension KeasyStyleManager {
    var backgroundColor: UIColor {
        switch currentStyle {
        case .light:
            return UIColor(red: 214, green: 216, blue: 222)
        case .dark:
            return UIColor(red: 43, green: 43, blue: 43)
        default:
            return UIColor(red: 214, green: 216, blue: 222)
        }
    }
    
    var keyColor: UIColor {
        switch currentStyle {
        case .light:
            return UIColor(rgb: 0x2B2D2F)
        case .dark:
            return UIColor.gray
        default:
            return UIColor(rgb: 0x2B2D2F)
        }
    }
    
    var shiftOffColor: UIColor {
        switch currentStyle {
        case .light:
            return .gray
        case .dark:
            return .darkGray
        default:
            return .gray
        }
    }
    
    var shiftOnColor: UIColor {
        return .systemYellow
    }
    
    var shiftLockOnColor: UIColor {
        return .systemGreen
    }
}
