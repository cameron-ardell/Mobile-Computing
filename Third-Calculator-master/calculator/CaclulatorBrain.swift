//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Sophia Ardell on 2/9/16.
//  Copyright © 2016 Sophia Ardell. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    //holds all items used for operations, including functions
    private var opStack = [Op]()
    //all known operators
    private var knownOps = [String:Op]()
    
    //setting like this for now since commented out line causes trouble
    //var variableValues: Dictionary<String,Double>
    var variableValues = [String:Double]()
    
    
    var program: AnyObject { // guaranteed to be a PropertyList
        get {
            //converts all items in opStack to their type of Op
            return opStack.map { $0.description }
        }
        set {
            //
            //update property list so all symbols associated with actual function
            //
            if let opSymbols = newValue as? Array<String> {
                
                var newOpStack = [Op]()
                let numberFormatter = NSNumberFormatter()
                
                for opSymbol in opSymbols {
                    //if op is already known to brain, put in in stack
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    //otherwise, it's a digit and it should be put in the stack in string format
                    else if let operand = numberFormatter.numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                    //makes sure that you can add variables to calculator brain
                    else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    //gives you ops in proper format
    private enum Op : CustomStringConvertible {
        //digits
        case Operand(Double)
        //operations like sin, cos, sqrt
        case UnaryOperation(String, Double -> Double)
        //operations like + - * /
        case BinaryOperation(String, (Double, Double) -> Double)
        //for values user chooses to store
        case Variable(String)
        //for preset variables, like pi or e
        case NullaryOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                case .NullaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    
    
    var description: String {
        get {
            var (result, ops) = ("", opStack)
          
            //while there are still operations on the stack
            repeat {
            
                var current: String?
                //gets a single complete operation
                (current, ops) = description(ops)
                
                //if result is equal to an empty string, it is now equal to
                //the most recent returned operation, otherwise it is
                //equal to the most recent operation, followed by the
                //previous ones (so newest to oldest left to right)
                result = result == "" ? current! : "\(current!), \(result)"

            } while ops.count > 0
            return result
        }
    }
    
    //helper recursive function to retrieve description of stack
    private func description(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        
        //only run if there are still ops
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            //do evaluation based on type of op
            switch op {
                
            //returns digit in scientific notation if number too small
            case .Operand(let operand):
                return (String(format: "%g", operand), remainingOps)
            
            
            //for preset values like pi, just need to return since kept in string until need for operation
            case .NullaryOperation(let symbol, _):
                return (symbol, remainingOps)
                
            //for operations that occur on a single variable, only need symbol, not actual function
            case .UnaryOperation(let symbol, _):
                //get previous item in stack that function runs on
                let operandEvaluation = description(remainingOps)
                
                //if there was a result of the call to get the last item, get it
                if let operand = operandEvaluation.result {
                    return ("\(symbol)(\(operand))", operandEvaluation.remainingOps)
                }

            //for operations that occur on two variables, only need symbol, not actual function
            case .BinaryOperation(let symbol, _):
                //get previous two items from stack
                let operandEvaluation = description(remainingOps)
                if var operand1 = operandEvaluation.result {
                    
                    //only keep going for binary operation if there are
                    //more than 2 variables left on stack
                    if remainingOps.count - operandEvaluation.remainingOps.count > 2 {
                        operand1 = "(\(operand1))"
                    }
                    
                    //get second digit from stack
                    let operandEvaluation2 = description(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        //do operation on found digits, return remainingOps of second found digit since we went back 3 items in stack
                        return ("\(operand2) \(symbol) \(operand1)", operandEvaluation2.remainingOps)
                    }
                }
            
            //for variables, only need string, not what it stands for
            case .Variable(let symbol):
                return(symbol, remainingOps)
            }
        }
        
        //if missing operands
        return ("?", ops)
    }
    
    
    
    //initalize CalculatorBrain
    init() {
        
        //makes it so the calculator can learn how to do operations and know constant variables
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        //the various functions and things like pi
        //had to do manual operation for - and / since would flip items otherwise
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷", { $1 / $0} ))
        learnOp(Op.BinaryOperation("−", { $1 - $0}))
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", { sin($0) } ))
        learnOp(Op.UnaryOperation("cos", { cos($0) } ))
        learnOp(Op.UnaryOperation("±", { -$0 }))
        learnOp(Op.NullaryOperation("π", { M_PI }))
       // learnOp(Op.UnaryOperation("→M", { setVariable("M", value: $0)}))
        learnOp(Op.Variable("M") )
        
        
    }
    
    //puts digits on the stack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    //will put variables the user creates on the stack
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    /*takes string sent to brain, checks to see if the symbol is a known function,
     puts it onto the stack if so, then evaluates it*/
    func performOperation(symbol: String)  -> Double?{
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    //adds variable to variable value dictionary
    func setVariable(symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    //empties all dictionaries for reset
    func killEverything() {
        variableValues.removeAll()
        opStack.removeAll()
    }
    
    
    //method to evaluate items on stack, double optinal to handle erros easier
    func evaluate() -> Double? {
        //want to go through stack of Ops recursively, so sending copy of it to helper function
        let (result, _) = evaluate(opStack)
        return result
    }
    
    //helper recursive function to evaluate functions that takes array of ops, returns optional double and remaining ops
    private func evaluate(ops: [Op]) -> (result: Double?,  remainingOps: [Op]) {
        
        //only run if there are still ops
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            //do evaluation based on type of op
            switch op {
            
            //removes digit from stack
            case .Operand(let operand):
                return (operand, remainingOps)
            
            //operation that occurs on single variable based on actual function call, not string attributed to it
            case .UnaryOperation(_, let operation):
                //get the previous item in stack for the function to run on
                let operandEvaluation = evaluate(remainingOps)
                
                //if there was a result of the call to get the last item, get it
                if let operand = operandEvaluation.result {
                    //do the operation on found digit, return the remainingOps of the found digit since we went back 2 items in stack
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            
            //operation that occurs on two variables based on function call, not string attriputed to it
            case .BinaryOperation(_, let operation):
                
                //get previous two items from stack
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        //do operation on found digits, return remainingOps of second found digit since we went back 3 items in stack
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
            
            //returns actual set value of variable and all ops before it on stack
            case .Variable(let symbol):
                //this return automatically gurantees nil if nothing at that place in dictionary
                return (variableValues[symbol], remainingOps)
            
            //returns actual value of preset variable and remaining ops
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            }
        }
        
        //there was nothing to run on
        return (nil, ops)
    }
}