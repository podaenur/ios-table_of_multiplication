import UIKit.UIButton

final class ActionButton: UIButton {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    private func initialSetup() {
        let color = UIColor.black
        
        titleLabel?.font = .tom_actionButton
        setTitleColor(color, for: .normal)
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        layer.cornerRadius = 12
    }
}
