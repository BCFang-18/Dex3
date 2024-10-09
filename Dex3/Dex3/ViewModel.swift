//
//  ViewModel.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import Foundation

@MainActor
class ViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    @Published private(set) var status = Status.notStarted
    
    private let fetchController: FetchController
    
    init(fetchController: FetchController) {
        self.fetchController = fetchController
        
        Task{
            await getPokemon()
        }
    }
    
    private func getPokemon() async {
        status = .fetching
        do {
            guard var pokedex = try await fetchController.fetchAllPokemon() else {
                status = .success
                return
            }
            pokedex.sort{$0.id < $1.id}
        } catch {
            status = .failed(error: error)
        }
    }
}
