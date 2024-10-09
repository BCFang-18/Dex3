//
//  FetchController.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation
import CoreData

struct FetchController {
    enum NetworkError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchAllPokemon() async throws -> [TmpPokemon]? {  // return optional, either an array or nil
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [TmpPokemon] = []
        
        var fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)  // query can not be added directly to url but URLComponents
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        
        guard let fetchURL = fetchComponents?.url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        // till now, we only got a name and a URL, but we need much more for a TmpPokemon
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw NetworkError.badData
        }// keys are always String
        
        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
                
        }
        
        return allPokemon
    }
    
    private func fetchPokemon(from url: URL) async throws -> TmpPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let tempPokemon = try JSONDecoder().decode(TmpPokemon.self, from: data)
        
        print("Fetched \(tempPokemon.id): \(tempPokemon.name)")
        
        return tempPokemon
    }
    
    private func havePokemon() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()  // no to mess with view that running on the foreground with our App
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])  // in url fetchRequest, we use limit to fetch narow down, fetching only n pokemons; but with predicate, we can assign a specific range to fetch
        // in this case, we are fetching id:1 and id:386
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            return checkPokemon.count == 2 ? true : false
        } catch {
            print("Fetch failed \(error)")
            return false  // no pokemon in CoreData yet
        }
    }
    
}
