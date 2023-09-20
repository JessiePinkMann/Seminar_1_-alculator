import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func buttonTouchDown(_ sender: UIButton) {
        if let color = sender.backgroundColor {
            originalColors[sender] = color
            sender.backgroundColor = brighterColor(color: color)
        }
    }

    @IBAction func buttonTouchUp(_ sender: UIButton) {
        if let originalColor = originalColors[sender] {
            sender.backgroundColor = originalColor
        }
    }
    
    var originalColors: [UIButton: UIColor] = [:]
    private var currentNumber: Decimal = 0
    private var previousNumber: Decimal = 0
    private var operation: String? = nil
    private var isFinishedTypingNumber: Bool = true
    private var isNewSequence: Bool = false
    private var isOperationPressed: Bool = false
    private var isNewOperation: Bool = true
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            displayLabel.text = "0"
            
            for button in buttons {
                button.layer.cornerRadius = button.bounds.size.height / 2
                button.clipsToBounds = true
            }
        }
    
    @IBAction func calcButtonPressed(_ sender: UIButton) {
        if let calcMethod = sender.currentTitle {
            isFinishedTypingNumber = true
            switch calcMethod {
            case "AC":
                resetCalculator()
                updateDisplay()
            case "=":
                if !isNewOperation {
                    performOperation()
                }
                isNewSequence = true
                operation = nil
                isOperationPressed = false
                isNewOperation = true
            case "+", "—", "X", "÷":
                if !isNewOperation && !isNewSequence && operation != nil {
                    performOperation()
                }
                previousNumber = currentNumber
                operation = calcMethod
                isNewSequence = false
                isNewOperation = true
            case "+/-":
                currentNumber = -currentNumber
                updateDisplay()
                isFinishedTypingNumber = true
                return
            case "%":
                if operation != nil {
                    currentNumber = (previousNumber * currentNumber) / 100
                    updateDisplay()
                    isNewOperation = false
                } else {
                    currentNumber /= 100
                    updateDisplay()
                }
                isFinishedTypingNumber = true
                return
            default:
                break
            }
        }
    }

    @IBAction func numButtonPressed(_ sender: UIButton) {
        if let numValue = sender.currentTitle {
            if displayLabel.text == "0" || isFinishedTypingNumber {
                if numValue == "." {
                    if isFinishedTypingNumber {
                        displayLabel.text = "0."
                    }
                } else {
                    displayLabel.text = numValue
                }
                isFinishedTypingNumber = false
            } else {
                if numValue == "." && displayLabel.text!.contains(".") {
                    return
                }
                displayLabel.text! += numValue
            }
            currentNumber = Decimal(string: displayLabel.text!) ?? 0
            isNewSequence = false
            isOperationPressed = false
            isNewOperation = false
        }
    }

    private func performOperation() {
        if let op = operation, !isNewOperation {
            switch op {
            case "+":
                currentNumber += previousNumber
            case "—":
                currentNumber = previousNumber - currentNumber
            case "X":
                currentNumber *= previousNumber
            case "÷":
                if currentNumber != 0 {
                    currentNumber = previousNumber / currentNumber
                } else {
                    displayLabel.text = "Error"
                    resetCalculator()
                    return
                }
            default:
                break
            }
            previousNumber = 0
            let doubleValue = NSDecimalNumber(decimal: currentNumber).doubleValue
            let isInteger = floor(doubleValue) == doubleValue
            displayLabel.text = isInteger ? String(format: "%.0f", doubleValue) : String(format: "%.4f", doubleValue)
        }
    }

    
    private func updateDisplay() {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
            
        if let formattedValue = formatter.string(from: NSDecimalNumber(decimal: currentNumber)) {
            displayLabel.text = formattedValue
        }
    }

    private func resetCalculator() {
        currentNumber = 0.0
        previousNumber = 0.0
        operation = nil
        isFinishedTypingNumber = true
        isNewSequence = false
        isOperationPressed = false
    }
}

func brighterColor(color: UIColor) -> UIColor {
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
    if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
        return UIColor(red: min(r * 1.3, 1.0),
                       green: min(g * 1.3, 1.0),
                       blue: min(b * 1.3, 1.0),
                       alpha: a)
    }
    
    return color
}
