import Foundation

enum ExerciseType: Int {
    case multiplication = 0
    case division
}

struct GameExercise: Hashable {
    let left: Int
    let right: Int
    let act: ExerciseType
    let result: Int
}

extension ExerciseType: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
            case .multiplication:
                return "x"
            case .division:
                return ":"
        }
    }
}

extension GameExercise: CustomDebugStringConvertible {
    
    var debugDescription: String {
        """
        left: \(left)
        right: \(right)
        act: \(act)
        result: \(result)
        """
    }
}
