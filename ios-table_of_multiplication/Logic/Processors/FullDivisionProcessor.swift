import Foundation

struct FullDivisionProcessor: GameProcessor {
    
    var processed: [GameExercise] {
        let range: ClosedRange<Int>
        
        if extendedBounds {
            range = 1...10
        } else {
            range = 2...9
        }
        
        return range.map { SingleDivisionProcessor(leftExpression: $0,
                                                   extendedBounds: extendedBounds).processed }
            .reduce([GameExercise]()) {
                res, next in
                
                var buffer = res
                buffer.append(contentsOf: next)
                
                return buffer
            }
    }
    
    init(leftExpression: Int, extendedBounds: Bool) {
        self.extendedBounds = extendedBounds
    }
    
    private let extendedBounds: Bool
}
