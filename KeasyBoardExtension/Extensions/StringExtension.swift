//
//  StringExtension.swift
//  keasyBoardExtension
//
//  Created by Kai Ho Tsang on 3/10/2021.
//

import Foundation
import UIKit

extension String {
    var cangjieCode: String {
        switch self.lowercased() {
        case "q":
            return "手"
        case "w":
            return "田"
        case "e":
            return "水"
        case "r":
            return "口"
        case "t":
            return "廿"
        case "y":
            return "卜"
        case "u":
            return "山"
        case "i":
            return "戈"
        case "o":
            return "人"
        case "p":
            return "心"
            
        case "a":
            return "日"
        case "s":
            return "尸"
        case "d":
            return "木"
        case "f":
            return "火"
        case "g":
            return "土"
        case "h":
            return "竹"
        case "j":
            return "十"
        case "k":
            return "大"
        case "l":
            return "中"
            
        case "z":
            return "重"
        case "x":
            return "難"
        case "c":
            return "金"
        case "v":
            return "女"
        case "b":
            return "月"
        case "n":
            return "弓"
        case "m":
            return "一"

        default:
            return self
        }
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
