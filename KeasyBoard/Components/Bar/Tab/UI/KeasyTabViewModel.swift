//
//  KeasyTabViewModel.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 7/10/2021.
//

import Foundation
import UIKit

class KeasyTabViewModel: NSObject {
    private(set) var tab: KeasyTab
    
    init(_ tab: KeasyTab) {
        self.tab = tab
    }
    
    var icon: UIImage? {
        return nil
    }
    
    var title: String {
        return tab.title
    }
    
    var titleFont: UIFont {
        switch tab.titleSize {
        case .regular:
            return KeasyFontManager.shared.regularFont
        case .small:
            return KeasyFontManager.shared.smallFont
        case .large:
            return KeasyFontManager.shared.largeFont
        }
    }
}
