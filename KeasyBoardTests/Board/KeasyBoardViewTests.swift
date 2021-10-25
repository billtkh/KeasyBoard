//
//  KeasyBoardTests.swift
//  KeasyBoardTests
//
//  Created by Bill Tsang on 25/10/2021.
//

import XCTest
@testable import KeasyBoard
import UIKit

class KeasyBoardTests: XCTestCase {
    
    var window = UIWindow(frame: UIScreen.main.bounds)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_boardView_collectionView_setup() throws {
        let sut = createSUT()
        
        XCTAssertNotNil(sut.boardView.collectionView.delegate)
        XCTAssertNotNil(sut.boardView.collectionView.dataSource)
        XCTAssertNotNil(sut.boardView.viewModel.numberOfSections)
    }
}

extension KeasyBoardTests {
    func createSUT() -> BoardViewController {
        let sut = BoardViewController()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        sut.loadViewIfNeeded()
        return sut
    }
}

