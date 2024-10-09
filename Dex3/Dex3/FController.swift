//
//  FController.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation

struct FController {
    enum NetworkError: Error {
        case badURL, badResponse, badData
    }
    
    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchAllPokemon() async throws -> [TmpPokemon] {
        var allPokemon: [TmpPokemon] = []
        
        var fetchCompoments = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        fetchCompoments?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        
        guard let fetchURL = fetchCompoments?.url else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any], let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw NetworkError.badData
        }
        
        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }
        
        return allPokemon
        
        
    }
    
    func fetchPokemon(from url: URL) async throws -> TmpPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        let pokemon = try JSONDecoder().decode(TmpPokemon.self, from: data)
        
        print("Fetched \(pokemon.id): \(pokemon.name)")
        return pokemon
    }
    
}
