//
//  StackoverflowClientTests.swift
//  StackoverflowClientTests
//
//  Created by Anugheerthi E S on 15/11/19.
//  Copyright © 2019 Anugheerthi E S. All rights reserved.
//

import XCTest
@testable import StackoverflowClient

class StackoverflowClientTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    // MARK: SCQuestionCellViewModel Test Case
    
    func testQuestionCellViewModel() {
        let sampleOwner = SCQuestion.SCOwner.init(displayName: "Anug")
        let sampleQuestion = SCQuestion(tags: ["iOS", "Android"], owner: sampleOwner, score: 10, title: "Test Title")
        let cellViewModel = SCQuestionCellViewModel(sampleQuestion)
        XCTAssert(cellViewModel.questionTitle == "Test Title", "Wrong question title text")
        XCTAssert(cellViewModel.upvoteCount == "10", "Wrong upvote count text")
        XCTAssert(cellViewModel.tags == ["iOS", "Android"], "Wrong question tags")
        XCTAssert(cellViewModel.questionTitle == "Test Title", "Wrong question title text")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
