import UIKit

final class GameSelectorController: UIViewController {
    
    // MARK: - Definitions
    
    private struct Constants {
        struct Title {
            static var insets: UIEdgeInsets { .init(top: 20, left: 16, bottom: 0, right: -16) }
        }
        
        struct Collection {
            static var insets: UIEdgeInsets { .init(top: 16, left: 16, bottom: -20, right: -16) }
        }
    }
    
    // MARK: - Subviews
    
    private lazy var titleLabel: UIView = {
        let view = UILabel()
        
        view.textAlignment = .center
        view.font = .tom_title
        
        view.text = "Во что играем?"
        
        #if DEBUG
        view.backgroundColor = .yellow
        #endif
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.register(GameSelectorSwitchCell.self, forCellWithReuseIdentifier: GameSelectorSwitchCell.reuseIdentifier)
        view.register(GameSelectorPushCell.self, forCellWithReuseIdentifier: GameSelectorPushCell.reuseIdentifier)
        
        view.allowsMultipleSelection = true
        
        view.dataSource = dataSource
        view.delegate = delegate
        
        #if DEBUG
        view.backgroundColor = .orange
        #else
        view.backgroundColor = .white
        #endif
        
        return view
    }()
    
    // MARK: - Properties
    
    private lazy var dataSource: GameSelectorDataSource = {
        let object = GameSelectorDataSource()
        object.gameSettingsInform = gameControll
        return object
    }()
    private lazy var delegate: UICollectionViewDelegate = {
        let object = GameSelectorDelegate()
        
        object.didChangeGameSettings = {
            [weak self] exerciseType, isOn in
            
            switch exerciseType {
                case .multiplication:
                    self?.gameControll.isMultiplication = isOn
                case .division:
                    self?.gameControll.isDivision = isOn
            }
            
            let set = IndexSet(integer: GameSelectorSections.settings.rawValue)
            //self?.collectionView.reloadSections(set)
            self?.collectionView.reloadData()
        }
        object.didSelectOperandsGameAtIndex = {
            [weak self] index in
            guard let sSelf = self else { return }
            
            let operand = sSelf.dataSource.operands[index]
            let game = sSelf.gameControll.game(for: operand)
            sSelf.startGame(game)
        }
        object.didSelectAllOperandsGame = {
            [weak self] in
            guard let sSelf = self else { return }
            
            let game = sSelf.gameControll.gameAllOperands()
            sSelf.startGame(game)
        }
        
        return object
    }()
    private lazy var layout: UICollectionViewLayout = {
        let object = UICollectionViewFlowLayout()
        return object
    }()
    private var gameControll = GameControll()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [titleLabel, collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let titleInsets = Constants.Title.insets
        
        let titleConstraints = [
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: titleInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: titleInsets.left),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: titleInsets.right)
        ]
        
        let collectionInsets = Constants.Collection.insets
        
        let collectionViewConstraints = [
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: collectionInsets.top),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: collectionInsets.left),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: collectionInsets.right),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: collectionInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(titleConstraints)
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
    
    // MARK: - Private
    
    private func startGame(_ game: GameEngine.GameType) {
        let controller = GameController(selectedGame: game)
        show(controller, sender: self)
    }
}
