//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Yuri Chervonyi on 4/29/19.
//  Copyright © 2019 CHRGames. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {
    
    private var calculator: Calculator!
    
    override func setUp() {
        super.setUp()
        
        calculator = Calculator()
    }
    
    func testCalculation() {
        var res = 0.0
        
        do {
            res = try calculator.calculate(expression: "2*(12/2)+16/2")
        } catch {
            res = -1.0
        }
        
        XCTAssertEqual(res, 20)
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
