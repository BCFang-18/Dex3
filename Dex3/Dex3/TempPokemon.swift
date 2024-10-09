//
//  TempPokemon.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/4/24.
//

import Foundation

struct TempPokemon: Codable {  // help with transition from fetched data to core data, no need for "favorite" attribute since fetch data has no "favorite"
    
    let id: Int
    let name: String
    let types: [String]
    var hp: Int = 0
    var attack: Int = 0
    var defense: Int = 0
    var specialAttack: Int = 0
    var specialDefense: Int = 0
    var speed: Int = 0
    let sprite: URL
    let shiny: URL
    
    enum PokemonKeys: String, CodingKey {  // JSON file not neccessary to match properties before, but String and CodingKey
        // no need to match cases, just raw values
        // enum is automatically set to raw value until you initialize with a certain raw value
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: String, CodingKey {
            case type
            
            enum TypeKeys: String, CodingKey {
                case name
            }
        }
        
        enum StatDictionaryKeys: String, CodingKey {
            case value = "base_stat"
            case stat
            
            enum StatKeys: String, CodingKey {
                case name
            }
        }
        
        enum SpriteKeys: String, CodingKey {
            case sprite = "front_default"
            case shiny = "front_shiny"
            
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: PokemonKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        
        name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)  // Unkeyed: second level type is an array not dict
        while !typesContainer.isAtEnd {
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: PokemonKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: PokemonKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)  // keyedBy: expects an enum type that conforms to the CodingKey protocol. This enum (typeContainer in this example) specifies the keys used inside the nested type dictionary.
            // forKey: specifies the actual key in the current container (typesDictionaryContainer) under which the nested dictionary (or object) is found. This should match one of the cases in the enum used in the parent container (typesDictionaryContainer)
            
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        types = decodedTypes
        
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: PokemonKeys.StatDictionaryKeys.self)
            let statContainer = try statsDictionaryContainer.nestedContainer(keyedBy: PokemonKeys.StatDictionaryKeys.StatKeys.self, forKey: .stat)
            
            switch try statContainer.decode(String.self, forKey: .name) {  // though we only set once for each case, but from compiler's view, we could set a case 6 times!
                // even you change all these "let" to "var" will switch really go to these cases? You may never match! Never initialize!
                // You need to guarantee that every single var to be initialized
                // Just initialize them at the very begining LoL
            case "hp":
                hp = try statsDictionaryContainer.decode(Int.self, forKey: PokemonKeys.StatDictionaryKeys.value)
            case "attack":
                attack = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "defense":
                defense = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "special-attack":  // snake-case?
                specialAttack = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "special-defense":
                specialDefense = try statsDictionaryContainer.decode(Int.self, forKey: .value)
            case "speed":
                speed = try statsDictionaryContainer.decode(Int.self, forKey: .value)
                
            default:
                print("It will Never get here so...")
            }
        }
        
//        var spritesContainer = try container.nestedUnkeyedContainer(forKey: .sprites)
//        let spritesDictionaryContainer = try spritesContainer.nestedContainer(keyedBy: PokemonKeys.SpriteKeys.self)
//        sprite = try spritesDictionaryContainer.decode(URL.self, forKey: .sprite)
//        shiny = try spritesDictionaryContainer.decode(URL.self, forKey: .shiny)
        
        let spriteContainer = try container.nestedContainer(keyedBy: PokemonKeys.SpriteKeys.self, forKey: .sprites)
        sprite = try spriteContainer.decode(URL.self, forKey: .sprite)  // but it is actaully a String instead of URL... Apple is nice to us, they will take care of converting from String to URL
        shiny = try spriteContainer.decode(URL.self, forKey: .shiny)
    }
}
