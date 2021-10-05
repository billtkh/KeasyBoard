//
//  KeasyWord.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 5/10/2021.
//

import Foundation

struct KeasyWord {
    let keys: String
    let word: String
    let index: Int
    
    init(word: Word) {
        self.keys = (word.keys ?? "") as String
        self.word = (word.word ?? "") as String
        self.index = Int(word.index)
    }
}
