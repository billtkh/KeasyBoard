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
    
    let developBaseOnHeight = 812.0
    let currentDeviceHeight = UIScreen.main.bounds.height
    let scale: Double
    
    let smallFontSize = 10.0
    let regularFontSize = 15.0
    let largeFontSize = 20.0
    
    var smallFont: UIFont
    var regularFont: UIFont
    var largeFont: UIFont
    
    private override init() {
        scale = max(0.95, currentDeviceHeight / developBaseOnHeight)
        smallFont = .systemFont(ofSize: smallFontSize * scale)
        regularFont = .systemFont(ofSize: regularFontSize * scale)
        largeFont = .systemFont(ofSize: largeFontSize * scale)
        
        super.init()
    }
}
