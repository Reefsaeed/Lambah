//
//  DetectedSymbol.swift
//  Lambah
//
//  Created by Reef Saeed on 15/03/2025.
//

import Foundation
import UIKit

// MARK: - DetectedSymbol Model
struct DetectedSymbol {
    let className: String
    let confidence: Float
    
    var title: String {
        return SymbolInfoProvider.getTitle(for: className)
    }
    
    var description: String {
        return SymbolInfoProvider.getDescription(for: className)
    }
    
    var actionText: String {
        return SymbolInfoProvider.getAction(for: className)
    }
    
    var iconName: String {
        return SymbolInfoProvider.getIconName(for: className)
    }
    
    var iconColor: UIColor {
        return SymbolInfoProvider.getIconColor(for: className)
    }
    
    var confidencePercentage: Int {
        return Int(confidence * 100)
    }
}
