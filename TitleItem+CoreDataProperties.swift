//
//  TitleItem+CoreDataProperties.swift
//  Netflix_Clone
//

import Foundation
import CoreData

// Make sure this extension references the correct TitleItem class
extension TitleItem {
    // This creates a fetchRequest specifically for this entity
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TitleItem> {
        return NSFetchRequest<TitleItem>(entityName: "TitleItem")
    }

    // Managed properties from Core Data
    @NSManaged public var id: Int64
    @NSManaged public var media_type: String?
    @NSManaged public var original_name: String?
    @NSManaged public var original_title: String?
    @NSManaged public var overview: String?
    @NSManaged public var poster_path: String?
    @NSManaged public var release_date: String?
    @NSManaged public var vote_average: Double
    @NSManaged public var vote_count: Int64
}

// MARK: - Helper Methods
extension TitleItem {
    // Convert to Title model
    func asTitle() -> Title {
        return Title(
            id: Int(id),
            mediaType: media_type,
            originalName: original_name,
            originalTitle: original_title,
            posterPath: poster_path,
            overview: overview,
            voteCount: Int(vote_count),
            releaseDate: release_date,
            voteAverage: vote_average,
            backdropPath: nil
        )
    }
    
    // Create from Title model
    static func fromTitle(_ title: Title, context: NSManagedObjectContext) -> TitleItem {
        let item = TitleItem(context: context)
        item.id = Int64(title.id)
        item.media_type = title.mediaType
        item.original_name = title.originalName
        item.original_title = title.originalTitle
        item.overview = title.overview
        item.poster_path = title.posterPath
        item.release_date = title.releaseDate
        item.vote_average = title.voteAverage ?? 0.0
        item.vote_count = Int64(title.voteCount ?? 0)
        return item
    }
}
