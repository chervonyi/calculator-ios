//
//  ViewController.swift
//  Calculator
//
//  Created by Yuri Chervonyi on 4/29/19.
//  Copyright © 2019 CHRGames. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    // UI components
    @IBOutlet var memorySlots: [UIButton]!
    
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var labelInput: UILabel!
    
    @IBOutlet weak var buttonOpenBrackets: UIButton!
    @IBOutlet weak var buttonCloseBrackets: UIButton!
    
    @IBOutlet var buttonsNum: [UIButton]!
    
    @IBOutlet weak var buttonPoint: UIButton!
    
    @IBOutlet weak var buttonPercentage: UIButton!
    @IBOutlet weak var buttonMultiplication: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonDivision: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonCalculation: UIButton!
    
    // Logic
    private let calculator = Calculator()
    
    // Constants
    private let MAX_SYMBOLS = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memorySlots = memorySlots.sorted(by: {$0.tag < $1.tag})
        buttonsNum = buttonsNum.sorted(by: {$0.tag < $1.tag})
        
        updateView()
        
        
        
        for memorySlot in memorySlots {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickMemory))
            let longTapGesutureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongClickMemory))
            
            memorySlot.addGestureRecognizer(tapGestureRecognizer)
            memorySlot.addGestureRecognizer(longTapGesutureRecognizer)
        }
    }

    
    @IBAction func onClickCalculate(_ sender: UIButton) {
        
        guard let input = labelInput.text else {
            return
        }
        
        do {
            let result = try calculator.calculate(expression: input)
        
            updateLabelsWith(labelResult: result.stringFormat, labelInput: result.stringFormat)
            
        } catch Calculator.ErrorType.BAD_SYNTAX {
            updateLabelsWith(labelResult: "Bad Syntax", labelInput: "")
        } catch Calculator.ErrorType.BAD_INPUT {
            updateLabelsWith(labelResult: "?", labelInput: "")
        } catch {
            updateLabelsWith(labelResult: "?", labelInput: "")
        }
    }

    @objc func onClickMemory(sender: UITapGestureRecognizer) {
        let tag = (sender.view?.tag)!
        
        if memorySlots[tag].titleLabel!.text! == "+" {
            if setMemory(slot: tag) {
                updateLabelsWith(labelResult: "0", labelInput: "")
            }
        } else if isLastEquals(string: labelInput.text!, set: "+-*/(") || labelInput.text!.count == 0 {
            append(str: memorySlots[tag].titleLabel!.text!)
        }
    }
    
    @objc func onLongClickMemory(sender: UILongPressGestureRecognizer)  {
        
        if sender.state == .began {
            let tag = (sender.view?.tag)!
            
            if setMemory(slot: tag) {
                updateLabelsWith(labelResult: "0", labelInput: "")
            }
        }
    }
    
    func setMemory(slot id: Int) -> Bool {
        guard let input = labelInput.text else {
            return false
        }
        
        do {
            let result = try calculator.calculate(expression: input)
            memorySlots[id].setTitle(result.stringFormat, for: UIControlState.normal)
            return true
        } catch {
            return false
        }
    }
    
    
    
    func preCalculation() {
        guard let input = labelInput.text else {
            return
        }
        
        do {
            let result = try calculator.calculate(expression: input)
            labelResult.text = result.stringFormat
        } catch {
            labelResult.text = ""
        }
    }
    
    func updateLabelsWith(labelResult str1: String, labelInput str2: String) {
        labelResult.text = str1
        labelInput.text = str2
    }
    
    @IBAction func onClickErase(_ sender: UIButton) {
        if let str = labelInput.text, str.count > 0 {
            labelInput.text = String(str.dropLast())
            preCalculation()
        }
    }
    
    @IBAction func onClickOperator(_ sender: UIButton) {
        
        switch sender {
        case buttonPercentage:      append(str: "%")
        case buttonMultiplication:  append(str: "*")
        case buttonPlus:            append(str: "+")
        case buttonDivision:        append(str: "/")
        case buttonMinus:           append(str: "-")
        case buttonOpenBrackets:    append(str: "(")
        case buttonCloseBrackets:   append(str: ")")
        case buttonPoint:   append(str: ".")
        default: break
        }
    }
    
    @IBAction func onClickNumber(_ sender: UIButton) {
        append(str: String(sender.tag))
    }
    
    func append(str: String) {
        
        var string = str
        
        var input = labelInput.text!
        
        // Check on max symbols in labelInput
        if input.count >= MAX_SYMBOLS {
            return
        }
        
        // Check on empty string of labelInput
        if input.count == 0 && "+-*/%)".contains(string) {
            return
        }
        
        // Check if pointer does not make error
        if string == "." {
            if isLastEquals(string: input, set: "+-*/%(") || input.count == 0 {
                input += "0"
            } else if !isLastNumberWell() || isLastEquals(string: input, set: ")") {
                return;
            }
        }
        
        // Check on main operation symbols
        if "+-*/%".contains(string) {
            if isLastEquals(string: input, set: "+-*/%") {
                // Replace last operator with a new one
                input = String(input.dropLast())
            } else if isLastEquals(string: input, set: ".") {
                return
            }
        }
        
        // Check on "0" symbol
        if string == "0" {
            if input.count == 0 || isLastEquals(string: input, set: "+-*/%(") {
                string += "."
            }
        }
            
        // Conditions for brackets
        if string == "(" {
            if input.count == 0 {
                labelInput.text = input + string
                return
            } else if !isLastEquals(string: input, set: "+-*/%(") {
                return
            }
        } else if string == ")" {
            if isLastEquals(string: input, set: "+-*/%.(") || count(stringToCheck: input, symbol: ")") >= count(stringToCheck: input, symbol: "(") {
                return
            }
        }
        
        labelInput.text = input + string
        preCalculation()
    }
    
    func isLastNumberWell() -> Bool {
        return count(stringToCheck: labelInput.text!, symbol: ".") < 1
    }
    
    func count(stringToCheck str: String, symbol: String) -> Int {
        return Array(str).filter { $0 == symbol.first! }.count
    }
    
    func isLastEquals(string: String, set: String) -> Bool {
        
        if string.count == 0 { return false }
        
        for char in set {
            if string.last! == char {
                return true
            }
        }
        return false
    }
    
    
    func updateView() {
        buttonOpenBrackets.layer.borderWidth = 2
        buttonOpenBrackets.layer.borderColor = #colorLiteral(red: 0.2941176471, green: 0.3098039216, blue: 0.3254901961, alpha: 0.9469445634)
        buttonOpenBrackets.layer.cornerRadius = 5
        
        buttonCloseBrackets.layer.borderWidth = 2
        buttonCloseBrackets.layer.borderColor = #colorLiteral(red: 0.2941176471, green: 0.3098039216, blue: 0.3254901961, alpha: 0.9469445634)
        buttonCloseBrackets.layer.cornerRadius = 5
        
        buttonPercentage.layer.cornerRadius =       buttonPercentage.layer.frame.width / 2
        buttonMultiplication.layer.cornerRadius =   buttonMultiplication.layer.frame.width / 2
        buttonPlus.layer.cornerRadius =             buttonPlus.layer.frame.width / 2
        buttonDivision.layer.cornerRadius =         buttonDivision.layer.frame.width / 2
        buttonMinus.layer.cornerRadius =            buttonMinus.layer.frame.width / 2
        buttonCalculation.layer.cornerRadius =      buttonCalculation.layer.frame.height / 2
    }
}

extension Double {
    var stringFormat: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        
        return formatter.string(from: self as NSNumber)!
    }
}

