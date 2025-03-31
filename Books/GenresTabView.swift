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
actor UpdateDataHandler {
    func persist() {
        // Start time measurement
        let startTime = Date()
        
        // Fetch and delete all existing genres
        if let existingBooks = try? modelContext.fetch(FetchDescriptor<Book>()) {
            for existingBook in existingBooks {
                modelContext.delete(existingBook)
            }
            print("Deleted \(existingBooks.count) existing genres")
        }
        
        let importData = ImportModel.fetchMockDataV2()
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
        // Calculate and log the elapsed time
        let elapsedTime = Date().timeIntervalSince(startTime)
        print("Data persistence operation completed in \(String(format: "%.3f", elapsedTime)) seconds")
    }
}

struct GenresTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Genre.name) var genres: [Genre]
    var body: some View {
        NavigationStack {
            List(genres) { genre in
                HStack {
                    Text(genre.name)
                    Spacer()
                    Text("^[\(genre.books.count) book](inflect: true)")
                }
                .listRowBackground(genre.colorStyle)
                .foregroundStyle(genre.textColor)
            }
            .navigationTitle("Genres")
            Button {
                print("Starting migration ----------")
                print("Deleting current data")
                print("Uploading new data")
                Task {
                    let cache = UpdateDataHandler(modelContainer: modelContext.container)
                    await cache.persist()
                }
            } label: {
                Text("Update With new Data")
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    GenresTabView()
        .modelContainer(for: Book.self, inMemory: true)
}

#Preview(traits: .mockData) {
    GenresTabView()
}
