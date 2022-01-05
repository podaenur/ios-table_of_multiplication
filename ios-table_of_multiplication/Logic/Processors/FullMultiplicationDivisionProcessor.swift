import Foundation

struct FullMultiplicationDivisionProcessor: GameProcessor {
    
    var processed: [GameExercise] {
        let multiplication = FullMultiplicationProcessor(leftExpression: leftExpression,
                                                         extendedBounds: extendedBounds).processed
        let division = FullDivisionProcessor(leftExpression: leftExpression,
                                             extendedBounds: extendedBounds).processed
        
        return [multiplication, division].reduce([GameExercise]()) {
            res, next in
            
            var buffer = res
            buffer.append(contentsOf: next)
            
            return buffer
        }
    }
    
    init(leftExpression: Int, extendedBounds: Bool) {
        self.leftExpression = leftExpression
        self.extendedBounds = extendedBounds
    }
    
    private let leftExpression: Int
    private let extendedBounds: Bool
}
