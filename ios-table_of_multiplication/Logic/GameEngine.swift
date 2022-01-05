import Foundation

final class GameEngine {
    
    // MARK: - Definitions
    
    private enum Errors: Error {
        case exercisesIsEmpty
    }
    
    private struct Constants {
        static var gameTimerCycleTime: TimeInterval { 1 }
        static var multiplicationSymbol: String { "x" }
        static var divisionSymbol: String { ":" }
    }
    
    enum GameType {
        case singleMultiplication(leftExpression: Int)
        case singleDivision(leftExpression: Int)
        case singleMultiplicationDivision(leftExpression: Int)
        case fullMultiplication
        case fullDivision
        case fullMultiplicationDivision
    }
    
    struct GameResult {
        let correctAnswers: Int
        let misstaces: Int
        let timing: TimeInterval
    }
    
    // MARK: - Properties
    
    private var correctAnswers = 0
    private var misstaces = 0
    private var gameTime: TimeInterval = 0
    
    private var allExercises = Set<GameExercise>()
    private var allExercisesCount = 0
    private var currentExercise: GameExercise?
    private var gameTimer: Timer?
    
    // MARK: - Bindings
    
    var didUpdateTimer: ((TimeInterval) -> Void)?
    var didUpdateEquation: ((String) -> Void)?
    var didUpdateProgressStepIn: ((Int, Int) -> Void)?
    var didUpdateHint: ((String) -> Void)?
    var didUpdateGameResult: ((GameResult) -> Void)?
    
    // MARK: - Life cycle
    
    deinit {
        clear()
    }
    
    // MARK: - Public
    
    func start(_ game: GameType = .singleMultiplication(leftExpression: 2), extendedBounds: Bool) {
        prepareNewGame(game, extendedBounds: extendedBounds)
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: Constants.gameTimerCycleTime, repeats: true, block: {
            [weak self] _ in
            guard let sSelf = self else { return }
            
            sSelf.gameTime += Constants.gameTimerCycleTime
            sSelf.didUpdateTimer?(sSelf.gameTime)
        })
        
        do {
            try nextEquation()
        } catch {
            finish()
        }
    }
    
    func finish() {
        didUpdateGameResult?(.init(correctAnswers: correctAnswers, misstaces: misstaces, timing: gameTime))
        clear()
    }
    
    func answer(is answer: Int) throws {
        guard let current = currentExercise else { return }
        
        if answer == current.result {
            correctAnswers += 1
        } else {
            misstaces += 1
        }
        
        try nextEquation()
    }
    
    // MARK: - Private
    
    private func clear() {
        gameTimer?.invalidate()
        gameTimer = nil
        
        correctAnswers = 0
        misstaces = 0
        gameTime = 0
        allExercisesCount = 0
        
        allExercises.removeAll()
        currentExercise = nil
    }
    
    private func prepareNewGame(_ game: GameType, extendedBounds: Bool) {
        clear()
        
        switch game {
            case .singleMultiplication(let leftExpression):
                allExercises = Set(SingleMultiplicationProcessor(leftExpression: leftExpression,
                                                                 extendedBounds: extendedBounds).processed)
            case .singleDivision(let leftExpression):
                allExercises = Set(SingleDivisionProcessor(leftExpression: leftExpression,
                                                           extendedBounds: extendedBounds).processed)
                
            case .singleMultiplicationDivision(leftExpression: let leftExpression):
                var buffer = Set(SingleMultiplicationProcessor(leftExpression: leftExpression,
                                                               extendedBounds: extendedBounds).processed)
                
                Set(SingleDivisionProcessor(leftExpression: leftExpression,
                                            extendedBounds: extendedBounds).processed).forEach { buffer.insert($0) }
                
                allExercises = buffer
            case .fullMultiplication:
                allExercises = Set(FullMultiplicationProcessor(leftExpression: 0,
                                                               extendedBounds: extendedBounds).processed)
            case .fullDivision:
                allExercises = Set(FullDivisionProcessor(leftExpression: 0,
                                                         extendedBounds: extendedBounds).processed)
            case .fullMultiplicationDivision:
                allExercises = Set(FullMultiplicationDivisionProcessor(leftExpression: 0,
                                                                       extendedBounds: extendedBounds).processed)
        }
        
        allExercisesCount = allExercises.count
    }
    
    private func nextEquation() throws {
        guard !allExercises.isEmpty else { throw Errors.exercisesIsEmpty }
        
        currentExercise = allExercises.randomElement()
        
        guard let current = currentExercise else {
            finish()
            return
        }
        
        let questionsLeft = allExercisesCount - allExercises.count
        didUpdateProgressStepIn?(questionsLeft, allExercisesCount)
        
        allExercises.remove(current)
        show(current)
    }
    
    private func show(_ exercise: GameExercise) {
        let displayString: String
        
        #if DEBUG
        print(exercise.debugDescription)
        #endif
        
        switch exercise.act {
            case .multiplication:
                displayString = "\(exercise.left) \(Constants.multiplicationSymbol) \(exercise.right) ="
            case .division:
                displayString = "\(exercise.left) \(Constants.divisionSymbol) \(exercise.right) ="
        }
        
        didUpdateEquation?(displayString)
        
        #if DEBUG
        didUpdateHint?("\(exercise.result)")
        #endif
    }
}
