import UIKit

final class KeyboardObserver {
    
    private var tokens = [NSObjectProtocol]()
    
    var didChangeYPosition: (((delta: CGFloat, duration: TimeInterval)) -> Void)?
    
    init() {
        let keyboardWillShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification,
                                                                           object: nil,
                                                                           queue: .main) {
            [weak self] notification in
            guard let userInfo = notification.userInfo else { return }
            self?.handleKeyboardChange(userInfo: userInfo)
        }
        
        let keyboardWillHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                                           object: nil,
                                                                           queue: .main) {
            [weak self] notification in
            guard let userInfo = notification.userInfo else { return }
            self?.handleKeyboardChange(userInfo: userInfo)
        }
        
        self.tokens = [keyboardWillShowToken, keyboardWillHideToken]
    }
    
    deinit {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    private func handleKeyboardChange(userInfo: [AnyHashable: Any]) {
        if #available(iOS 13.0, *) {
            guard UITraitCollection.current.userInterfaceIdiom == .phone else { return }
        } else {
            guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        }
        
        guard
            let beginFrame = userInfo["UIKeyboardFrameBeginUserInfoKey"] as? CGRect,
            let endFrame = userInfo["UIKeyboardFrameEndUserInfoKey"] as? CGRect
        else { return }
        
        let beginY = beginFrame.origin.y
        let endY = endFrame.origin.y
        
        let animationDuration = (userInfo["UIKeyboardAnimationDurationUserInfoKey"] as? TimeInterval) ?? 0.3
        
        didChangeYPosition?((endY - beginY, animationDuration))
    }
}
