//
//  Item.swift
//  Starrly
//
//  Created by Vitha Watson on 14/09/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
