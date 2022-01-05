import Foundation

final class GameControll: GameSettingsInform {
    
    var isMultiplication = true {
        didSet {
            guard !isMultiplication && !isDivision else { return }
            isDivision = true
        }
    }
    var isDivision = false {
        didSet {
            guard !isMultiplication && !isDivision else { return }
            isMultiplication = true
        }
    }
    
    func game(for operand: Int) -> GameEngine.GameType {
        switch (isMultiplication, isDivision) {
            case (true, false):
                return .singleMultiplication(leftExpression: operand)
            case (false, true):
                return .singleDivision(leftExpression: operand)
            case (true, true),
                (false, false):
                return .singleMultiplicationDivision(leftExpression: operand)
        }
    }
    
    func gameAllOperands() -> GameEngine.GameType {
        switch (isMultiplication, isDivision) {
            case (true, false):
                return .fullMultiplication
            case (false, true):
                return .fullDivision
            case (true, true),
                (false, false):
                return .fullMultiplicationDivision
        }
    }
}
