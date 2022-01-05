import Foundation

struct SingleDivisionProcessor: GameProcessor {
    
    var processed: [GameExercise] {
        var source = Equation.makeSequence(leftExpression: leftExpression)
        
        if !extendedBounds {
            source = source.compactMap { ($0.rightExpression >= 2 && $0.rightExpression <= 9) ? $0 : nil }
        }
                
        return source.map {
            GameExercise(left: $0.result, right: $0.leftExpression, act: .division, result: $0.rightExpression)
        }
    }
    
    init(leftExpression: Int, extendedBounds: Bool) {
        self.leftExpression = leftExpression
        self.extendedBounds = extendedBounds
    }
    
    private let leftExpression: Int
    private let extendedBounds: Bool
}
