import UIKit

extension UIView {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    func performElevate(yDelta: CGFloat, animationDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut) {
            self.transform = CGAffineTransform(translationX: 0, y: yDelta)
        }
    }
}
