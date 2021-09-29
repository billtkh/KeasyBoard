//
//  KeasySpacingManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 29/9/2021.
//

import Foundation
import UIKit

class KeasyBoardSpacingManager: NSObject {
    static let shared = KeasyBoardSpacingManager()
    
    var boardHeight = UIScreen.main.bounds.height * 0.3
    var boardPadding: Double = 4
    
    var rowSpacing: Double = 6
    var keyPadding: Double = 4
}
