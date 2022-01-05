import UIKit

final class GameSelectorPushCell: SetupableCollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        
        view.textAlignment = .center
        view.font = .tom_title
        
        view.text = "x 2"
        
        return view
    }()
    
    private lazy var _backgroundView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        
        return view
    }()

    override func setup() {
        super.setup()
        
        backgroundView = _backgroundView
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(titleLabelConstraints)
    }
}
