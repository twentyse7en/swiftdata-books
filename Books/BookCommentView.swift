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

func deleteBookNamed(name: String, context: ModelContext) {
    // Create a predicate to fin                        let predicate = #Predicate<FavouriteBook> { book_ in
//                            book_.bookName == book.name
//                        }
//                        
//                        do {
//                            // Fetch books matching the predicate
//                            let booksToDelete = try modelContext.fetch(FetchDescriptor<FavouriteBook>(predicate: predicate))
//                            
//                            // Delete each matching book (should be at most one since bookName is unique)
//                            for book in booksToDelete {
//                                modelContext.delete(book)
//                                print("Deleted book: \(book.bookName)")
//                            }
//                            
//                            // Save the changes
//                            try modelContext.save()
//                        } catch {
//                            print("Error deleting book: \(error)")
//                        }
}

struct BookCommentView: View {
    @Bindable var book: Book
    @Query() var favBooks: [FavouriteBook]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var checkIsFavourite: Bool {
        let isFavourite = favBooks.contains(where: { $0.bookName == book.name })
        return isFavourite
    }
    
    var body: some View {
        VStack {
            Button {
                if (!checkIsFavourite) {
                    print("inserting")
                    let favbook = FavouriteBook(bookName: book.name)
                    modelContext.insert(favbook)
                } else {
                    // We can do better ofcourse
                    do {
                        // NOTE: we can't reference book.name in predicate
                        let bookName = book.name;
                        let predicate = #Predicate<FavouriteBook> { fb in
                            fb.bookName.localizedStandardContains(bookName)
                        }
                        let booksToDelete = try modelContext.fetch(FetchDescriptor<FavouriteBook>(predicate: predicate))
                        for book in booksToDelete {
                            modelContext.delete(book)
                            print("Deleted book: \(book.bookName)")
                        }
                        // Save the changes
                        try modelContext.save()
                    } catch {
                        print("Error deleting book: \(error)")
                    }
                }
            } label: {
                if (checkIsFavourite) {
                    Image(systemName: "heart.fill")
                } else {
                    Image(systemName: "heart")
                }
            }
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
            Text(book.name)
                .font(.title)
            Text(book.allAuthors)
                .font(.title3)
            if (book.genre != nil) {
                Text(book.genre!.name)
                    .tagStyle(genre: book.genre!)
            }
            TextField("Comment", text: $book.comment, axis: .vertical)
                .textFieldStyle(.roundedBorder)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    StartTabView()
        .modelContainer(for: [Book.self, FavouriteBook.self], inMemory: true)
}

#Preview(traits: .mockData) {
    @Previewable @Query var books: [Book]
    BookCommentView(book:books.first! )
}

