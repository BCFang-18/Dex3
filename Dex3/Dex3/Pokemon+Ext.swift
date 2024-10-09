//
//  Pokemon+Ext.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation
import SwiftUI

extension Pokemon {  // extend Pokemon Entity
    // something that we can not do in Core Data Dex3
    var background:  ImageResource{
        switch self.types![0] {
        case "normal", "grass", "electric", "poison", "fairy":
            return .normalgrasselectricpoisonfairy
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
            return .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
            return .firedragon
        case "flying", "bug":
            return .flyingbug
        case "ice":
            return .ice
        case "water":
            return .water
        default:
            return .normalgrasselectricpoisonfairy  // not gonna happen anyway
        }
    }
    
    var stats: [Stat] {  // extension property must be computed rather stored
        [
            Stat(id: 1, label: "HP", value: self.hp),
            Stat(id: 2, label: "Attack", value: self.attack),
            Stat(id: 3, label: "Defense", value: self.defense),
            Stat(id: 4, label: "Special Attack", value: self.specialAttack),
            Stat(id: 5, label: "Special Defense", value: self.specialDefense),
            Stat(id: 6, label: "Speed", value: self.speed)
        ]
    }
    
    var highestStat: Stat {
        stats.max { $0.value < $1.value }!
    }
    
    func organizeTypes() {
        if self.types!.count == 2 && self.types!.first == "normal" {
            self.types!.swapAt(0, 1)
        }
    }
}

struct Stat: Identifiable {
    let id: Int
    let label: String
    let value: Int16
}
