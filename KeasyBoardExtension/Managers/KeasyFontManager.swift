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
    
    var largeFont: UIFont = .systemFont(ofSize: 20)
    var regularFont: UIFont = .systemFont(ofSize: 15)
    var smallFont: UIFont = .systemFont(ofSize: 10)
}
