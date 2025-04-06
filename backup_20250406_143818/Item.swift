//
//  Item.swift
//  writing_app
//
//  Created by DKAdmin on 29/03/25.
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
