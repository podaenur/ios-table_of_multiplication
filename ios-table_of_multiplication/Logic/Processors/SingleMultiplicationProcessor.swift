import Foundation

struct SingleMultiplicationProcessor: GameProcessor {
    
    private let leftExpression: Int
    private let extendedBounds: Bool
    
    // MARK: - GameProcessor
    
    init(leftExpression: Int, extendedBounds: Bool) {
        self.leftExpression = leftExpression
        self.extendedBounds = extendedBounds
    }
        
    var processed: [GameExercise] {
        var source = Equation.makeSequence(leftExpression: leftExpression)
        
        if !extendedBounds {
            source = source.compactMap { ($0.rightExpression >= 2 && $0.rightExpression <= 9) ? $0 : nil }
        }
        
        return source.map { GameExercise(left: $0.leftExpression, right: $0.rightExpression, act: .multiplication, result: $0.result) }
    }
}
