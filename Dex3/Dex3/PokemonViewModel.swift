//
//  PokemonViewModel.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation
@MainActor
class PokemonViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success  // this time no need to attach data here rather go to core data sqlite
        case failed(error: Error)
    }
    
    @Published private(set) var status = Status.notStarted
    
    private let controller: FetchController
    
    init(controller: FetchController) {
        self.controller = controller
        
        Task {  // we cannot run async function directly unless its in a Task{}
            await getPokemon()
        }
    }
    
    private func getPokemon() async {
        status = .fetching
        
        do {
            guard var pokedex = try await controller.fetchAllPokemon() else {
                print("Pokemon already fetched. We good.")
                status = .success
                return
            }  // pokemons might not be sorted since fetched async
            
            pokedex.sort {$0.id < $1.id}
            
            for pokemon in pokedex {
                let newPokemon = Pokemon(context: PersistenceController.shared.container.viewContext)  // in core data, you dont have to have values until saving
                newPokemon.id = Int16(pokemon.id)
                newPokemon.name = pokemon.name
                newPokemon.types = pokemon.types
                newPokemon.organizeTypes()
                newPokemon.hp = Int16(pokemon.hp)
                newPokemon.attack = Int16(pokemon.attack)
                newPokemon.defense = Int16(pokemon.defense)
                newPokemon.specialAttack = Int16(pokemon.specialAttack)
                newPokemon.specialDefense = Int16(pokemon.specialDefense)
                newPokemon.speed = Int16(pokemon.speed)
                newPokemon.sprite = pokemon.sprite
                newPokemon.shiny = pokemon.shiny
                newPokemon.favorite = false
                
                // by now, nothing is persisted until we save to storage
                try PersistenceController.shared.container.viewContext.save()
                // after this, we dont have to fetch from online anymore
            }
            
            // purpose of status is to alert ViewModel that it is time to refresh the view
            status = .success
            // unlike BB quote, we dont want to run this init() until user press a button.
            // We want to run asap when APP is launched
            // we dont run this func in User's View, only run here, so we can add private
        } catch {
            status = .failed(error: error)
        }
    }
    
}
