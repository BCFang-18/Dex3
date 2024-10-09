//
//  PokemonDetail.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/5/24.
//

import SwiftUI
import CoreData

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var pokemon: Pokemon  // with core dta, you can just use sample preview pokemon
    @State var showShiny = false
    
    var body: some View {
        // data might be long enough for some phone to scroll
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 6)
                
                AsyncImage(url: showShiny ? pokemon.shiny : pokemon.sprite) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/, radius: 6)
                } placeholder: {
                    ProgressView()
                }
            }
            
            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .shadow(color: .white, radius: 1)  // modifier's order matters, have to add shadow here then background later
                        .padding([.top, .bottom], 7)
                        .padding([.leading, .trailing])
                        .background(Color(type.capitalized))
                        .clipShape(.rect(cornerRadius: 50))
                }
                Spacer()
                
                Button {
                    withAnimation {
                        pokemon.favorite.toggle()
                        
                        // have to save, to persist
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                }
                .font(.largeTitle)
                .foregroundStyle(.yellow)
            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            Stats()
                .environmentObject(pokemon)
            
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showShiny.toggle()
                } label: {
                    if showShiny {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(.yellow)
                    } else {
                        Image(systemName: "wand.and.stars.inverse")
                    }
                }
            }
        }
    }
}

#Preview {

    // hidden return, if only this line of code, "return" is optional, but you have multiple line, need explicitly add
    return PokemonDetail()
        .environmentObject(SamplePokemon.samplePokemon)
}
