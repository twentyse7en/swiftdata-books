//
//  Favourite.swift
//  Books
//
//  Created by Abijith B on 31/03/25.
//
import SwiftUI
import SwiftData

@Model
class FavouriteBook {
    @Attribute(.unique)
    var bookName: String
    
    init(bookName: String) {
        self.bookName = bookName
    }
}
