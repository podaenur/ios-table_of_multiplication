import UIKit

final class ResultController: UIViewController {
    
    // MARK: - Definitions
    
    struct DisplayItem {
        let wins: UInt
        let loses: UInt
        let time: TimeInterval
    }
    
    private enum Motivation: String {
        case best = "Отличный результат! Ура!"
        case good = "Ты молодец, поучи еще немного чтобы быть лучшим!"
        case bad = "Не растраивайся, немного поучи и все у тебя получится!"
    }
    
    private struct Constants {
        static var elementsVerticalSpacing: CGFloat { 16 }
        static var titleAndValueSpacing: CGFloat { 8 }
        static var titleAndContainerSpacing: CGFloat { 36 }
        
        struct Container {
            static var insets: UIEdgeInsets { .init(top: 20, left: 16, bottom: 0, right: -16) }
        }
        
        struct Continue {
            static var insets: UIEdgeInsets { .init(top: 0, left: 16, bottom: -20, right: -16) }
        }
    }
    
    // MARK: - Subviews
    
    private lazy var layoutContainerStackView: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        
        return view
    }()
    
    private lazy var titleLabel: UIView = {
        let view = UILabel()
        
        view.textAlignment = .center
        view.font = .tom_title
        
        view.text = "Твой результат"
        
        #if DEBUG
        view.backgroundColor = .yellow
        #endif
        
        return view
    }()
    
    private lazy var winsKeyLabel: UILabel = {
        let view = UILabel()
        
        view.font = .tom_statisticTextKey
        
        view.text = "Правильных:"
        
        #if DEBUG
        view.backgroundColor = .lightGray
        #endif
        
        return view
    }()
    
    private lazy var winsValueLabel: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .right
        view.font = .tom_statisticTextValue
        
        view.text = "0"
        
        #if DEBUG
        view.backgroundColor = .red
        #endif
        
        return view
    }()
    
    private lazy var losesKeyLabel: UILabel = {
        let view = UILabel()
        
        view.font = .tom_statisticTextKey
        
        view.text = "Ошибок:"
        
        #if DEBUG
        view.backgroundColor = .cyan
        #endif
        
        return view
    }()
    
    private lazy var losesValueLabel: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .right
        view.font = .tom_statisticTextValue
        
        view.text = "0"
        
        #if DEBUG
        view.backgroundColor = .magenta
        #endif
        
        return view
    }()
    
    private lazy var timeResultKeyLabel: UILabel = {
        let view = UILabel()
        
        view.font = .tom_statisticTextKey
        
        view.text = "Твое время:"
        
        #if DEBUG
        view.backgroundColor = .orange
        #endif
        
        return view
    }()
    
    private lazy var timeResultValueLabel: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .right
        view.font = .tom_statisticTextValue
        
        view.text = "0:00"
        
        #if DEBUG
        view.backgroundColor = .green
        #endif
        
        return view
    }()
    
    private lazy var motivationLabel: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .center
        view.numberOfLines = 0
        view.font = .tom_detailsText
        
        view.text = "Мотивация доступна после игры"
        
        #if DEBUG
        view.backgroundColor = .cyan
        #endif
        
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let view = ActionButton()
                
        view.setTitle("Завершить игру", for: .normal)
        
        view.addTarget(self, action: #selector(onContinue(_:)), for: .touchUpInside)
        
        #if DEBUG
        view.backgroundColor = .orange
        #endif
        
        return view
    }()
    
    // MARK: - Properties
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(onContinue(_:)))
        
        [layoutContainerStackView, continueButton].forEach { view.addSubview($0) }
        
        [titleLabel,
         makeLayoutContainer(height: Constants.titleAndContainerSpacing),
         makeSheetTable([winsKeyLabel, losesKeyLabel, timeResultKeyLabel],
                        and: [winsValueLabel, losesValueLabel, timeResultValueLabel]),
         motivationLabel].forEach { layoutContainerStackView.addArrangedSubview($0)
         }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        [layoutContainerStackView,
         titleLabel,
         winsKeyLabel,
         winsValueLabel,
         losesKeyLabel,
         losesValueLabel,
         timeResultKeyLabel,
         timeResultValueLabel,
         motivationLabel,
         continueButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        let containerInsets = Constants.Container.insets
        
        let containerConstraints = [
            layoutContainerStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: containerInsets.top),
            layoutContainerStackView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: containerInsets.left),
            layoutContainerStackView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: containerInsets.right)
        ]
        
        let continueInsets = Constants.Continue.insets
        
        let continueConstraints = [
            continueButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: continueInsets.left),
            continueButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: continueInsets.right),
            continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: continueInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(containerConstraints)
        NSLayoutConstraint.activate(continueConstraints)
    }
    
    // MARK: - Public
    
    final func update(with item: DisplayItem) {
        let wins = Int(item.wins)
        let loses = Int(item.loses)
        
        winsValueLabel.text = "\(wins)"
        losesValueLabel.text = "\(loses)"
        timeResultValueLabel.text = convert(item.time)
        
        //FIXME: не правильно считается результат игры. если сыграть только один раунд и ответить неправильно, то увидим похвалу победы
        let rounds = wins + loses
        let result = 1 - CGFloat(loses * rounds) / 100
        print("🥶 result: \(result)")
        switch result {
        case 0.9...:
            motivationLabel.text = Motivation.best.rawValue
        case 0.5..<0.9:
            motivationLabel.text = Motivation.good.rawValue
        case ..<0.5:
            motivationLabel.text = Motivation.bad.rawValue
        default:
            motivationLabel.text = nil
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func onContinue(_ sender: Any?) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Private
    
    private func makeSheetTable(_ left: [UIView], and right: [UIView]) -> UIView {
        let leftSide = makeSheetVerticalStackView(with: left)
        let rightSide = makeSheetVerticalStackView(with: right)
        
        let stack = UIStackView()
        stack.spacing = Constants.titleAndValueSpacing
        [leftSide, rightSide].forEach { stack.addArrangedSubview($0) }
        
        return stack
    }
    
    private func makeSheetVerticalStackView(with views: [UIView]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.elementsVerticalSpacing
        views.forEach { stack.addArrangedSubview($0) }
        stack.addArrangedSubview(LayoutView())
        return stack
    }
    
    private func makeLayoutContainer(height: CGFloat) -> UIView {
        let view = LayoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: height)])
        return view
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
