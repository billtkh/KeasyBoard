//
//  Observable.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 30/9/2021.
//

import Foundation

class Observable<T: Equatable> {
    private(set) var value: T

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }
    
    func update(_ value: T) {
        self.value = value
    }
    
    func next(_ value: T) {
        self.value = value
        listener?(value)
    }
    
    func nextIfDifferent(_ value: T) {
        guard value != self.value else { return }
        self.value = value
        listener?(value)
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}
