//
//  KeasySpacingManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation
import UIKit

class KeasySpacingManager: NSObject {
    static let shared = KeasySpacingManager()
    
    var boardHeight = UIScreen.main.bounds.height * 0.3
    
    var boardSpacing: Double = 0
    var rowSpacing: Double = 0
    var keySpacing: Double = 0
    
    var rowPadding: Double = 8
    var keyPadding: Double = 4
}
