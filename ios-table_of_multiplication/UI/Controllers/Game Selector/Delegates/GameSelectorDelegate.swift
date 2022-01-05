import UIKit

final class GameSelectorDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Bindings
    
    var didChangeGameSettings: ((ExerciseType, Bool) -> Void)?
    var didSelectOperandsGameAtIndex: ((Int) -> Void)?
    var didSelectAllOperandsGame: (() -> Void)?
    
    // MARK: - UICollectionViewDelegate
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch GameSelectorSections(rawValue: indexPath.section) {
            case .settings:
                switch ExerciseType(rawValue: indexPath.row) {
                    case .some(let exerciseType):
                        didChangeGameSettings?(exerciseType, true)
                    case .none:
                        break
                }
            case .operands:
                didSelectOperandsGameAtIndex?(indexPath.row)
                collectionView.deselectItem(at: indexPath, animated: true)
            case .allOperands:
                didSelectAllOperandsGame?()
                collectionView.deselectItem(at: indexPath, animated: true)
            case .none:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = GameSelectorSections(rawValue: indexPath.section),
              section == .settings else { return }

        switch ExerciseType(rawValue: indexPath.row) {
            case .some(let exerciseType):
                didChangeGameSettings?(exerciseType, true)
            case .none:
                break
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let section = GameSelectorSections(rawValue: indexPath.section) else { return .zero }
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        let dev_height: CGFloat = 40
        
        switch section {
            case .settings:
                let width = (collectionView.bounds.width - layout.minimumInteritemSpacing) / 2
                return .init(width: width,
                             height: dev_height)
            case .operands:
                let width = (collectionView.bounds.width - (layout.minimumInteritemSpacing * 2)) / 3
                return .init(width: width,
                             height: dev_height)
            case .allOperands:
                return .init(width: collectionView.bounds.width,
                             height: dev_height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        return .init(width: collectionView.bounds.width,
                     height: layout.minimumLineSpacing)
    }
}
