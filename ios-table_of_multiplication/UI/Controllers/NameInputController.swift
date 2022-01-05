import UIKit

final class NameInputController: UIViewController {
    
    // MARK: - Definitions
    
    private struct Constants {
        struct Title {
            static var insets: UIEdgeInsets { .init(top: 20, left: 16, bottom: 0, right: -16) }
        }
        
        struct Name {
            static var height: CGFloat { 36 }
            static var insets: UIEdgeInsets { .init(top: 26, left: 16, bottom: 0, right: -16) }
        }
        
        struct Continue {
            static var height: CGFloat { 56 }
            static var insets: UIEdgeInsets { .init(top: 0, left: 16, bottom: -20, right: -16) }
        }
    }
    
    // MARK: - Subviews
    
    private lazy var titleLabel: UIView = {
        let view = UILabel()
        
        view.textAlignment = .center
        view.font = .tom_title
        
        view.text = "Как тебя зовут?"
        
        #if DEBUG
        view.backgroundColor = .yellow
        #endif
        
        return view
    }()
    
    private lazy var nameTextField: UITextField = {
        let view = UITextField()
        
        view.borderStyle = .roundedRect
        view.clearButtonMode = .whileEditing
        view.autocorrectionType = .no
        
        view.font = .tom_textFieldText
        
        view.placeholder = "Напиши свое имя"
        view.addTarget(self, action: #selector(handleNameTextChange(_:)), for: .editingChanged)
        
        #if DEBUG
        view.backgroundColor = .green
        #endif
        
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let view = ActionButton()
        
        view.setTitle("Начать игру", for: .normal)
        
        view.addTarget(self, action: #selector(onContinue(_:)), for: .touchUpInside)
        
        #if DEBUG
        view.backgroundColor = .orange
        #endif
        
        return view
    }()
    
    // MARK: - Properties
    
    private let keyboardObserver = KeyboardObserver()
    private var name: String {
        nameTextField.text ?? ""
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        keyboardObserver.didChangeYPosition = {
            [weak self] (params) in
            
            let delta = params.delta >= 0 ? 0 : params.delta
            self?.continueButton.performElevate(yDelta: delta, animationDuration: params.duration)
        }
        
        let endEditingTap = UITapGestureRecognizer(target: self, action: #selector(handleEndEditingTapGesture(_:)))
        view.addGestureRecognizer(endEditingTap)
        
        [titleLabel, nameTextField, continueButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        changeEnabledDisabledForContinue()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let titleInsets = Constants.Title.insets
        
        let titleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: titleInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleInsets.left),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: titleInsets.right)
        ]
        
        let nameInsets = Constants.Name.insets
        
        let nameFieldConstraints = [
            nameTextField.heightAnchor.constraint(equalToConstant: Constants.Name.height),
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: nameInsets.top),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: nameInsets.left),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: nameInsets.right)
        ]
        
        let continueInsets = Constants.Continue.insets
        
        let continueConstraints = [
            continueButton.heightAnchor.constraint(equalToConstant: Constants.Continue.height),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: continueInsets.left),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: continueInsets.right),
            continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: continueInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(titleConstraints)
        NSLayoutConstraint.activate(nameFieldConstraints)
        NSLayoutConstraint.activate(continueConstraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    
    @objc
    private func handleNameTextChange(_ sender: Any?) {
        changeEnabledDisabledForContinue()
    }
    
    @objc
    private func handleEndEditingTapGesture(_ recognizer: UITapGestureRecognizer) {
        endEditing()
    }
    
    @objc
    private func onContinue(_ sender: Any?) {
        endEditing()
        let controller = GameSelectorController()
        show(controller, sender: self)
    }
    
    // MARK: - Private
    
    private func endEditing() {
        view.endEditing(true)
    }
    
    private func changeEnabledDisabledForContinue() {
        continueButton.isEnabled = !name.isEmpty
    }
}
