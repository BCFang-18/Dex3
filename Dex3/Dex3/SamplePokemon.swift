//
//  SamplePokemon.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation
import CoreData

// constant
struct SamplePokemon {
    static let samplePokemon = {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try! context.fetch(fetchRequest)
        
        return results.first!
    }()
}
