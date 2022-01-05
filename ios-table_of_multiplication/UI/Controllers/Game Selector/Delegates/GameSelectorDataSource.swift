import UIKit

protocol GameSettingsInform: AnyObject {
    var isMultiplication: Bool { get }
    var isDivision: Bool { get }
}

final class GameSelectorDataSource: NSObject, UICollectionViewDataSource {
    
    // MARK: - Definitions
    
    private enum Errors: Error {
        case general
    }
        
    // MARK: - Properties
    
    private(set) var operands = [2, 3, 4, 5, 6, 7, 8, 9]
    weak var gameSettingsInform: GameSettingsInform?
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        GameSelectorSections.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = GameSelectorSections(rawValue: section) else { return 0 }
        
        switch section {
            case .settings:
                return 2
            case .operands:
                return operands.count
            case .allOperands:
                return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        do {
            guard let section = GameSelectorSections(rawValue: indexPath.section) else { throw Errors.general }
            
            switch section {
                case .settings:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameSelectorSwitchCell.reuseIdentifier,
                                                                        for: indexPath) as? GameSelectorSwitchCell
                    else { throw Errors.general }
                    
                    return configuringSettingsCell(cell, at: indexPath.row)
                case .operands:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameSelectorPushCell.reuseIdentifier,
                                                                        for: indexPath) as? GameSelectorPushCell
                    else { throw Errors.general }
                    
                    return configuringOperandCell(cell, at: indexPath.row)
                case .allOperands:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameSelectorPushCell.reuseIdentifier,
                                                                        for: indexPath) as? GameSelectorPushCell
                    else { throw Errors.general }
                        
                    return configuringAllOperandsCell(cell)
            }
        } catch {
            return UICollectionViewCell()
        }
    }
    
    // MARK: - Private
    
    private func configuringSettingsCell(_ cell: GameSelectorSwitchCell, at index: Int) -> UICollectionViewCell {
        switch ExerciseType(rawValue: index) {
            case .multiplication:
                cell.titleLabel.text = "Умножение"
                cell.isSelected = gameSettingsInform?.isMultiplication ?? false
                return cell
            case .division:
                cell.titleLabel.text = "Деление"
                cell.isSelected = gameSettingsInform?.isDivision ?? false
                return cell
            case .none:
                return cell
        }
    }
    
    private func configuringOperandCell(_ cell: GameSelectorPushCell, at index: Int) -> UICollectionViewCell {
        cell.titleLabel.text = "\(operands[index])"
        return cell
    }
    
    private func configuringAllOperandsCell(_ cell: GameSelectorPushCell) -> UICollectionViewCell {
        cell.titleLabel.text = "Все числа"
        return cell
    }
}
