import UIKit

final class GameController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Definitions
    
    private struct Constants {
        
    }
    
    // MARK: - Subviews
    
    private lazy var formulaLabel: UILabel = {
        let view = UILabel()
        
        view.font = .tom_title
        view.textAlignment = .center
        
        view.text = "0 x 0 ="
        
        #if DEBUG
        view.backgroundColor = .green
        #endif
        
        return view
    }()
    
    private lazy var answerTextField: UITextField = {
        let view = UITextField()
        
        view.borderStyle = .roundedRect
        view.font = .tom_textFieldText
        view.textAlignment = .center
        view.keyboardType = .numberPad
        
        view.placeholder = "?"
        
        view.delegate = self
        
        view.addTarget(self, action: #selector(handleNameTextChange(_:)), for: .editingChanged)
        
        #if DEBUG
        view.backgroundColor = .orange
        #endif
        
        return view
    }()
    
    private lazy var formulaContainer: UIView = {
        let view = UIStackView()
        
        view.spacing = 16
        
        [formulaLabel, answerTextField].forEach { view.addArrangedSubview($0) }
        
        return view
    }()
    
    private lazy var timerInfoLabel: UILabel = {
        let view = UILabel()
        
        view.font = .tom_detailsText
        view.textAlignment = .center
        
        view.text = "0:00"
        
        #if DEBUG
        view.backgroundColor = .cyan
        #endif
        
        return view
    }()
    
    private lazy var sendAnswerButton: UIButton = {
        let view = ActionButton()
        
        view.setTitle("Ответить", for: .normal)
        
        view.addTarget(self, action: #selector(onSendAnswer(_:)), for: .touchUpInside)
        
        #if DEBUG
        view.backgroundColor = .lightGray
        #endif
        
        return view
    }()
    
    private lazy var roundProgress: UIProgressView = {
        let view = UIProgressView()
        
        return view
    }()
    
    private lazy var hintLabel: UILabel = {
        let view = UILabel()
        
        view.font = .systemFont(ofSize: 24)
        
        return view
    }()
    
    // MARK: - Properties
    
    private let selectedGame: GameEngine.GameType
    private let keyboardObserver = KeyboardObserver()
    private var value: String {
        answerTextField.text ?? ""
    }
    private lazy var gameEngine: GameEngine = {
        let engine = GameEngine()
        
        engine.didUpdateTimer = {
            [weak self] gameTime in
            
            self?.timerInfoLabel.text = self?.convert(gameTime)
        }
        
        engine.didUpdateEquation = {
            [weak self] equation in
            
            self?.answerTextField.text = nil
            self?.formulaLabel.text = equation
            self?.changeEnabledDisabledForContinue()
        }
        
        engine.didUpdateProgressStepIn = {
            [weak self] (stepsLeft, allSteps) in
            
            let current = Float(stepsLeft) / Float(allSteps)
            
            #if DEBUG
            print("didUpdateProgressStepIn: \(stepsLeft), \(allSteps)")
            print("current: \(current)")
            #endif
            
            self?.roundProgress.setProgress(current, animated: true)
        }
        
        engine.didUpdateHint = {
            [weak self] hint in
            
            self?.hintLabel.text = hint
        }
        
        engine.didUpdateGameResult = {
            [weak self] result in
            
            self?.endEditing()
            let controller = ResultController()
            let displayItem = ResultController.DisplayItem(wins: UInt(result.correctAnswers),
                                                           loses: UInt(result.misstaces),
                                                           time: result.timing)
            controller.update(with: displayItem)
            
            self?.show(controller, sender: self)
        }
        
        return engine
    }()
    
    // MARK: - Life cycle
    
    init(selectedGame: GameEngine.GameType) {
        self.selectedGame = selectedGame
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        keyboardObserver.didChangeYPosition = {
            [weak self] (params) in
            
            let delta = params.delta >= 0 ? 0 : params.delta
            self?.sendAnswerButton.performElevate(yDelta: delta, animationDuration: params.duration)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(onClose(_:)))
        
        let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(handleEndEditingTapGesture(_:)))
        view.addGestureRecognizer(endEditingTap)
        
        [formulaContainer, sendAnswerButton, timerInfoLabel, roundProgress].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        changeEnabledDisabledForContinue()
        
        #if DEBUG
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintLabel)
        #endif
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let answerConstraints = [
            answerTextField.widthAnchor.constraint(equalToConstant: 60)
        ]
        
        let formulaContainerConstraints = [
            formulaContainer.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 40),
            formulaContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        let timerConstraints = [
            timerInfoLabel.topAnchor.constraint(equalTo: formulaContainer.bottomAnchor, constant: 26),
            timerInfoLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
            timerInfoLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16)
        ]
        
        let progressConstraints = [
            roundProgress.topAnchor.constraint(equalTo: timerInfoLabel.bottomAnchor, constant: 16),
            roundProgress.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 16),
            roundProgress.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -16)
        ]
        
        let answerButtonConstraints = [
            sendAnswerButton.heightAnchor.constraint(equalToConstant: 56),
            sendAnswerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sendAnswerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendAnswerButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(answerConstraints)
        NSLayoutConstraint.activate(formulaContainerConstraints)
        NSLayoutConstraint.activate(timerConstraints)
        NSLayoutConstraint.activate(progressConstraints)
        NSLayoutConstraint.activate(answerButtonConstraints)
        
        #if DEBUG
        let hintLabelConstraints = [
            hintLabel.topAnchor.constraint(equalTo: roundProgress.bottomAnchor, constant: 16),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(hintLabelConstraints)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        answerTextField.becomeFirstResponder()
        gameEngine.start(selectedGame, extendedBounds: false)
    }
    
    // MARK: - Actions
    
    @objc
    private func handleEndEditingTapGesture(_ recognizer: UITapGestureRecognizer) {
        endEditing()
    }
    
    @objc
    private func handleNameTextChange(_ sender: Any?) {
        changeEnabledDisabledForContinue()
    }
    
    @objc
    private func onSendAnswer(_ sender: Any?) {
        guard let answer = Int(value) else {
            gameEngine.finish()
            return
        }
        
        do {
            try gameEngine.answer(is: answer)
        } catch {
            //TODO: показать ошибку
            gameEngine.finish()
        }
    }
    
    @objc
    private func onClose(_ sender: Any?) {
        requestGameExitConfirmation()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else { return true }
        
        return (textField.text ?? "").count < 3
    }
    
    // MARK: - Private
    
    private func endEditing() {
        view.endEditing(true)
    }
    
    private func changeEnabledDisabledForContinue() {
        sendAnswerButton.isEnabled = !value.isEmpty
    }
    
    private func requestGameExitConfirmation() {
        let controller = UIAlertController(title: "Завершить игру?", message: "Результаты этой игры будут потеряны.", preferredStyle: .actionSheet)
        
        let perform = UIAlertAction(title: "Выйти из игры", style: .destructive) {
            _ in
            
            self.endEditing()
            self.gameEngine.didUpdateGameResult = nil
            self.gameEngine.finish()
            self.navigationController?.popToRootViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Продолжить игру", style: .cancel)
        
        [perform, cancel].forEach { controller.addAction($0) }
        
        present(controller, animated: true)
    }
    
    private func convert(_ gameTime: TimeInterval) -> String {
        let timings = gameTime.hoursMinutesSecondsSplit
        
        if timings.hours > 0 {
            return String(format: "%d:%02d:%02d", timings.hours, timings.minutes, timings.seconds)
        } else {
            return String(format: "%d:%02d", timings.minutes, timings.seconds)
        }
    }
}
