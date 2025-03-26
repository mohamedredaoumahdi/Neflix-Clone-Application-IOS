//
//  WatchlistItem+CoreDataProperties.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 26/03/2025.
//
//

import Foundation
import CoreData


extension WatchlistItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItem> {
        return NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
    }

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

extension WatchlistItem : Identifiable {

}
