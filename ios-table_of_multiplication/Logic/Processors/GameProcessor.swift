import Foundation

protocol GameProcessor {
    
    var processed: [GameExercise] { get }
    
    init(leftExpression: Int, extendedBounds: Bool)
}
