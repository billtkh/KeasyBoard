//
//  KeasyFontManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation
import UIKit

class KeasyFontManager: NSObject {
    static let shared = KeasyFontManager()
    
    var regularFont: UIFont = .systemFont(ofSize: 17)
    var smallFont: UIFont = .systemFont(ofSize: 10)
}
