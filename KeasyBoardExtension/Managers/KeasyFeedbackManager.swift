//
//  KeasyFeedbackManager.swift
//  KeasyBoardExtension
//
//  Created by Bill Tsang on 6/10/2021.
//

import Foundation
import AudioToolbox
import UIKit
import AVFoundation

class KeasyFeedbackManager: NSObject {
    static let shared = KeasyFeedbackManager()
    
    let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    let peek = SystemSoundID(1519)
    let pop = SystemSoundID(1520)
    
    func prepare() {
        lightImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
    }
    
    func feedbackToTap() {
//        AudioServicesPlaySystemSound(peek)
        lightImpactGenerator.impactOccurred()
    }
    
    func feedbackToLongPress() {
//        AudioServicesPlaySystemSound(pop)
        heavyImpactGenerator.impactOccurred()
    }
}
