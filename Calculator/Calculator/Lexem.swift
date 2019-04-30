//
//  Lexem.swift
//  Calculator
//
//  Created by Yuri Chervonyi on 4/30/19.
//  Copyright © 2019 CHRGames. All rights reserved.
//

import Foundation

class Lexem {
    
    static let NUMBER = 20001
    static let OPERATOR = 20002
    
    let value: String
    let type: Int
    
    init() {
        value = ""
        type = 0
    }
    
    init(value: String, type: Int) {
        self.value = value
        self.type = type
    }
}
