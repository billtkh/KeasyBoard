//
//  KeasyBoardTests.swift
//  KeasyBoardTests
//
//  Created by Bill Tsang on 25/10/2021.
//

import XCTest
@testable import KeasyBoardExtension
import UIKit

class KeasyBoardTests: XCTestCase {
    
    let builder = BoardViewBuilder()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBoardView() throws {
        let sut = builder.createSUT()
    }
}
