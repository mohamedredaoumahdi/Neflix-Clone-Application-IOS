//
//  WatchlistItem+CoreDataProperties.swift
//  Netflix_Clone
//

import Foundation
import CoreData

// Make sure this extension references the correct WatchlistItem class
extension WatchlistItem {
    // This creates a fetchRequest specifically for this entity
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        return NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }

    // Managed properties from Core Data
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var mediaType: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var addedDate: Date?
}

// MARK: - Helper Methods
extension WatchlistItem {
    // Convert to Title model
    func asTitle() -> Title {
        return Title(
            id: Int(id),
            mediaType: mediaType,
            originalName: mediaType == "tv" ? title : nil,
            originalTitle: mediaType == "movie" ? title : nil,
            posterPath: posterPath,
            overview: overview,
            voteCount: 0,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            backdropPath: backdropPath
        )
    }
    
    // Create from Title model
    static func fromTitle(_ title: Title, context: NSManagedObjectContext) -> WatchlistItem {
        let item = WatchlistItem(context: context)
        item.id = Int64(title.id)
        item.title = title.originalTitle ?? title.originalName
        item.overview = title.overview
        item.posterPath = title.posterPath
        item.backdropPath = title.backdropPath
        item.mediaType = title.mediaType
        item.releaseDate = title.releaseDate
        item.voteAverage = title.voteAverage ?? 0.0
        item.addedDate = Date()
        return item
    }
}
