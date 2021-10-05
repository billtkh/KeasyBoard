//
//  KeasyKeyViewModel.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 28/9/2021.
//

import Foundation
import UIKit

class KeasyKeyViewModel: NSObject {
    var key: KeasyKey
    
    init(_ key: KeasyKey) {
        self.key = key
    }
    
    var size: KeasyKeySize {
        return key.size
    }
    
    var text: String {
        return key.text
    }
    
    var title: String {
        return key.title
    }
    
    var icon: UIImage? {
        return key.icon
    }
    
    var titleSize: KeasyKeyTitleSize {
        return key.titleSize
    }
    
    var isToggleHidden: Bool {
        return !key.canToggle
    }
}
