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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memorySlots = memorySlots.sorted(by: {$0.tag < $1.tag})
        buttonsNum = buttonsNum.sorted(by: {$0.tag < $1.tag})
        
        updateView()
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
        labelInput.text = labelInput.text! + str
        preCalculation()
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

