import Foundation

struct Equation {
    let leftExpression: Int
    let rightExpression: Int
    var result: Int {
        leftExpression * rightExpression
    }
}

extension Equation {
    
    static func makeSequence(leftExpression: Int) -> [Equation] {
        (1...10).map { Equation(leftExpression: leftExpression, rightExpression: $0) }
    }
}
