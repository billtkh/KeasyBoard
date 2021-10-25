//
//  KeasyBoardBuilder.swift
//  KeasyBoardTests
//
//  Created by Bill Tsang on 25/10/2021.
//

@testable import KeasyBoardExtension
import UIKit

struct BoardViewBuilder {
    func createSUT() -> KeasyBoardView {
        return KeasyBoardView.createBoardView(inputViewController: nil,
                                              textDocumentProxy: nil)
    }
}
