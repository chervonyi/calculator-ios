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
    
    private var source: String!
    private var result: Double!
    private var num: Double!
    private var _operator: Lexem!
    
    func calculate(expression: String) throws -> Double {
        
        reset()
        
        if expression.count == 0 {
            throw ErrorType.BAD_SYNTAX
        }
        
        source = expression
        
        try level_2()
        
        return result
    }
    
    // + and -
    func level_2() throws {
        
        try level_3()
        
        var tmpResult = num != nil ? num! : 0
        
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
    
    // * and /
    func level_3() throws {
        
        try level_4()
        
        var tmpResult = num != nil ? num! : 0
        
        while _operator.value == "*" || _operator.value == "/" {
            let currentOperator = _operator
            
            try level_4()
            
            switch (currentOperator?.value)! {
            case "*": tmpResult *= num
            case "/":
                guard num != 0 else {
                    throw ErrorType.BAD_INPUT
                }
                
                tmpResult /= num
                
            default: tmpResult = 0
            }
        }
        
        if tmpResult != 0 {
            num = tmpResult
        }
    }
    
    // %
    func level_4() throws {
        
        try level_5()
        
        var tmpResult = num != nil ? num! : 0
        
        while _operator.value == "%" {
            let currentOperator = _operator
            
            try level_5()
            
            switch (currentOperator?.value)! {
            case "%": tmpResult = tmpResult * num / 100
            default: tmpResult = 0
            }
        }
        
        if tmpResult != 0 {
            num = tmpResult
        }
    }
    
    // Reads atoms
    func level_5() throws {
        
        if source.count == 0 {
            return
        }
        
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
    
    func parse(lexem: Lexem) -> Double {
        return lexem.type == Lexem.NUMBER ? Double(lexem.value)! : 0
    }
    
    func nextOperator() throws -> Lexem {
        if source.count > 0 {
            return try nextLexem()
        }
        return Lexem()
    }
    
    func nextLexem() throws -> Lexem {
        
        if (source.first?.isNumber)! {
            var number = ""
            var foundPoint = false
            
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
    
    func popElement() {
        source = String(source.dropFirst())
    }
    
    func reset() {
        source = ""
        result = 0.0
        num = nil
        _operator = Lexem()
    }
    
}

extension Character {
    var isNumber: Bool {
        let scalar = String(self).unicodeScalars
        let uni = scalar.first!
        
        return CharacterSet.decimalDigits.contains(uni)
    }
}

