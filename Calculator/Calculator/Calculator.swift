//
//  Calculator.swift
//  Calculator
//
//  Created by Yuri Chervonyi on 4/30/19.
//  Copyright © 2019 CHRGames. All rights reserved.
//

import Foundation

class Calculator {
    
    enum ErrorType: Error {
        case BAD_SYNTAX
        case BAD_INPUT
    }
    
    private final let DELIMITER = "."
    
    // String of expression
    private var source: String!
    
    // Result of calculated part of expression
    private var result: Double!
    private var num: Double!
    private var _operator: Lexem!
    
    func calculate(expression: String) throws -> Double {
        
        if expression.count == 0 {  throw ErrorType.BAD_SYNTAX  }
        
        reset()
        source = expression
        
        // Start a descent by levels
        try level_2()
        
        return result
    }
    
    // The highest level of Recursive descent parser.
    // This method do calculation with lowest priority operations like: + and -.
    func level_2() throws {
        
        // Go to the lower level (Finding for operation with higher priority operation)
        try level_3()
        
        var tmpResult = num != nil ? num! : 0
        
        // Do calculation with appropriate operators (+ and -)
        while _operator.value == "+" || _operator.value == "-" {
            let currentOperator = _operator
            
            
            try level_3()
            
            switch (currentOperator?.value)! {
            case "+": tmpResult += num
            case "-": tmpResult -= num
            default: tmpResult = 0
            }
        }
        
        result = tmpResult
    }
    
    // The lower level of Recursive descent parser.<br>
    // This method do calculation with higher priority operations like: * and /.
    func level_3() throws {
        
        // Go to the lower level (Finding for operation with higher priority operation)
        try level_4()
        
        var tmpResult = num != nil ? num! : 0
        
        // Do calculation with appropriate operators (* and /)
        while _operator.value == "*" || _operator.value == "/" {
            let currentOperator = _operator
            
            try level_4()
            
            switch (currentOperator?.value)! {
            case "*": tmpResult *= num
            case "/":
                guard num != 0 else { throw ErrorType.BAD_INPUT }
                
                tmpResult /= num
                
            default: tmpResult = 0
            }
        }
        
        if tmpResult != 0 { num = tmpResult }
    }
    
    // The lower level of Recursive descent parser.<br>
    // This method do calculation with higher priority operations like: %
    func level_4() throws {
        
        // Go to the lowest level (To read a number or an operator)
        try level_5()
        
        var tmpResult = num != nil ? num! : 0
        
        // Do calculation with appropriate operator - %
        while _operator.value == "%" {
            let currentOperator = _operator
            
            try level_5()
            
            switch (currentOperator?.value)! {
            case "%": tmpResult = tmpResult * num / 100
            default: tmpResult = 0
            }
        }
        
        if tmpResult != 0 { num = tmpResult  }
    }
    
    // The lowest level of Recursive descent parser. <br>
    // This method does not do any calculation,
    // but it's reading any kind of Lexem (numbers or operators)
    // and then assign it into appropriate variables. <br><br>
    func level_5() throws {
        
        if source.count == 0 { return }
        
        let currentLexem = try nextLexem()
        
        if currentLexem.value == "-" {
            try level_5()
            
            num = -num
        } else if currentLexem.type == Lexem.NUMBER {
            
            num = parse(lexem: currentLexem)
            _operator = try nextOperator()
            
        } else if currentLexem.value == "(" {
            try level_2()
            
            if _operator.value == ")" {
                _operator = try nextOperator()
            } else {
                throw ErrorType.BAD_SYNTAX
            }
            
            num = result
            result = 0
        } else {
            throw ErrorType.BAD_SYNTAX
        }
    }
    
    // Convert Lexem to Double
    func parse(lexem: Lexem) -> Double {
        return lexem.type == Lexem.NUMBER ? Double(lexem.value)! : 0
    }
    
    // Read and return the next operator
    func nextOperator() throws -> Lexem {
        if source.count > 0 {
            return try nextLexem()
        }
        return Lexem()
    }
    
    // Read and return the next Lexem
    func nextLexem() throws -> Lexem {
        
        if (source.first?.isNumber)! {
            var number = ""
            var foundPoint = false
            
            // Read numbers
            while (source.first?.isNumber)! || source.first! == Character(DELIMITER) {
                
                if source.first! == Character(DELIMITER) {
                    
                    if foundPoint {
                        throw ErrorType.BAD_SYNTAX
                    } else {
                        foundPoint = true
                    }
                }
                
                number += String(describing: source.first!)
                popElement()
                
                if source.count == 0 { break }
            }
            
            return Lexem(value: number, type: Lexem.NUMBER)
            
        // Read operators
        } else if "+-*/%()".contains(source.first!) {
            let op = source.first!
            popElement()
            
            if source.count == 0 && op != ")" {
                throw ErrorType.BAD_SYNTAX
            }
            
            return Lexem(value: String(op), type: Lexem.OPERATOR)
        }
        
        return Lexem()
    }
    
    // Remove the last symbol from expression
    func popElement() {
        source = String(source.dropFirst())
    }
    
    // Reset all variables
    func reset() {
        source = ""
        result = 0.0
        num = nil
        _operator = Lexem()
    }
}

extension Character {
    // Checks if this character is number (0-9)
    var isNumber: Bool {
        let scalar = String(self).unicodeScalars
        let uni = scalar.first!
        
        return CharacterSet.decimalDigits.contains(uni)
    }
}

