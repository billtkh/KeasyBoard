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
    
    let developBaseOnHeight = 812.0
    let currentDeviceHeight = UIScreen.main.bounds.height
    let scale: Double
    
    private var baseBoardHeight = 250.0
    private var minBoardHeight = 230.0
    
    private var baseNarrow = 6.0
    private var baseCommon = 8.0
    
    private var baseBarHeight = 28.0
    private var baseBarVerticalPadding = 6.0
    private var baseBarHorizontalPadding = 8.0
    
    private var baseBoardSpacing: Double = 0
    private var baseRowSpacing: Double = 0
    private var baseKeySpacing: Double = 0
    
    private var baseRowPadding: Double = 7
    private var baseKeyPadding: Double = 5
    
    private var baseToggleWidth: Double = 8
    
    private override init() {
        scale = currentDeviceHeight / developBaseOnHeight
        super.init()
    }
    
    func space(_ type: KeasySpacing) -> Double {
        switch type {
        case .boardHeight:
            return max(minBoardHeight, baseBoardHeight * scale)
            
        case .narrow:
            return baseNarrow * scale
        case .common:
            return baseCommon * scale
            
        case .barHeight:
            return baseBarHeight
        case .barVerticalPadding:
            return baseBarVerticalPadding * scale
        case .barHorizontalPadding:
            return baseBarHorizontalPadding * scale
            
        case .boardSpacing:
            return baseBoardSpacing * scale
        case .rowSpacing:
            return baseRowSpacing * scale
        case .keySpacing:
            return baseKeySpacing * scale
            
        case .rowPadding:
            return baseRowPadding * scale
        case .keyPadding:
            return baseKeyPadding * scale
        case .toggleWidth:
            return baseToggleWidth * scale
        }
    }
}

enum KeasySpacing {
    case boardHeight
    
    case narrow
    case common
    
    case barHeight
    case barVerticalPadding
    case barHorizontalPadding
    
    case boardSpacing
    case rowSpacing
    case keySpacing
    
    case rowPadding
    case keyPadding
    
    case toggleWidth
}
