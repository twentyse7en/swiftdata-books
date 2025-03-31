//
//----------------------------------------------
// Original project:
// by  Stewart Lynch on 9/14/24
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2024 CreaTECH Solutions. All rights reserved.

import SwiftUI
import SwiftData

@ModelActor
actor CachedDataHandler {
    func persist() {
        let importData = ImportModel.fetchMockData()
        importData?.genres.forEach({ genreI in
            let genre = Genre(name: genreI.name, color: genreI.color)
            modelContext.insert(genre)
        })
        importData?.authors.forEach({ authorI in
            let author = Author(firstName: authorI.firstName, lastName: authorI.lastName)
            modelContext.insert(author)
        })
        
        let genres = try? modelContext.fetch(FetchDescriptor<Genre>())
        let authors = try? modelContext.fetch(FetchDescriptor<Author>())
        if let genres, let authors {
            importData?.books.forEach { bookI in
                guard let genre = genres.first(where: {$0.name == bookI.genre}) else {
                    print("Could not find \(bookI.genre)")
                    return
                }
                let book = Book(name: bookI.name, genre: genre)
                genre.books.append(book)
                bookI.authorIds.forEach { authorId in
                    guard let author = authors.first(where: {$0.fullName == authorId}) else {
                        print("Could not find \(authorId)")
                        return
                    }
                    book.authors.append(author)
                }
                modelContext.insert(book)
            }
        }
        try? modelContext.save()
    }
}

struct StartTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Books", systemImage: "books.vertical") {
                BooksTabView()
            }
            Tab("Authors", systemImage: "person") {
                AuthorsTabView()
            }
            Tab("Genres", systemImage: "swatchpalette") {
                GenresTabView()
            }
        }
        .task(priority: .background) {
            let cache = CachedDataHandler(modelContainer: modelContext.container)
            await cache.persist()
        }
    }
}

#Preview {
    StartTabView()
        .modelContainer(for: Book.self, inMemory: true)
}

#Preview(traits: .mockData) {
    StartTabView()
}
