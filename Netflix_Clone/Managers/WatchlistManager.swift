//
//  WatchlistManager.swift
//  Netflix_Clone
//
//  Updated with debugging and fixes
//

import UIKit
import CoreData

/// Manages watchlist operations for saving and retrieving user's saved content
class WatchlistManager {
    
    // MARK: - Singleton
    
    static let shared = WatchlistManager()
    
    private init() {
        print("WatchlistManager initialized")
    }
    
    // MARK: - Properties
    
    enum WatchlistError: Error, LocalizedError {
        case failedToSave
        case failedToFetch
        case failedToDelete
        case titleAlreadyInWatchlist
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .failedToSave:
                return "Failed to save title to watchlist"
            case .failedToFetch:
                return "Failed to fetch titles from watchlist"
            case .failedToDelete:
                return "Failed to remove title from watchlist"
            case .titleAlreadyInWatchlist:
                return "Title is already in your watchlist"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
    
    // MARK: - Core Methods
    
    /// Add a title to the user's watchlist
    func addToWatchlist(title: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Adding to watchlist: \(title.id) - \(title.displayTitle)")
        
        // Check if title already exists in watchlist
        if isTitleInWatchlist(id: title.id) {
            print("Title already in watchlist: \(title.id)")
            completion(.failure(WatchlistError.titleAlreadyInWatchlist))
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a new WatchlistItem entity object
        let watchlistItem = NSEntityDescription.insertNewObject(forEntityName: "WatchlistItem", into: context) as! WatchlistItem
        
        // Set properties
        watchlistItem.id = Int64(title.id)
        watchlistItem.title = title.originalTitle ?? title.originalName
        watchlistItem.overview = title.overview
        watchlistItem.posterPath = title.posterPath
        watchlistItem.backdropPath = title.backdropPath
        watchlistItem.mediaType = title.mediaType
        watchlistItem.releaseDate = title.releaseDate
        watchlistItem.voteAverage = title.voteAverage ?? 0.0
        watchlistItem.addedDate = Date()
        
        print("Created watchlist item with id: \(watchlistItem.id)")
        
        // Save to Core Data
        do {
            try context.save()
            print("Successfully saved to Core Data")
            NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
            completion(.success(()))
        } catch {
            print("Error saving to watchlist: \(error)")
            completion(.failure(WatchlistError.failedToSave))
        }
    }
    
    /// Remove a title from the user's watchlist
    func removeFromWatchlist(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Removing from watchlist: \(id)")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request with a predicate to find the matching item
        let fetchRequest = NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let items = try context.fetch(fetchRequest)
            print("Found \(items.count) items to remove")
            
            if let item = items.first {
                context.delete(item)
                try context.save()
                print("Successfully deleted item from Core Data")
                NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
                completion(.success(()))
            } else {
                // Item not found - still consider this a success
                print("Item not found in database, considering successful removal")
                completion(.success(()))
            }
        } catch {
            print("Error removing item from watchlist: \(error)")
            completion(.failure(WatchlistError.failedToDelete))
        }
    }
    
    /// Check if a title is already in the watchlist
    func isTitleInWatchlist(id: Int) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request with a predicate to count matching items
        let fetchRequest = NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            print("isTitleInWatchlist check for id \(id): \(count > 0)")
            return count > 0
        } catch {
            print("Error checking watchlist: \(error)")
            return false
        }
    }
    
    /// Fetch all titles in the watchlist
    func fetchWatchlist(completion: @escaping (Result<[WatchlistItem], Error>) -> Void) {
        print("Fetching watchlist items")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for all WatchlistItem entities
        let fetchRequest = NSFetchRequest<WatchlistItem>(entityName: "WatchlistItem")
        
        // Add sort by added date (newest first)
        let sortDescriptor = NSSortDescriptor(key: "addedDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let items = try context.fetch(fetchRequest)
            print("Successfully fetched \(items.count) watchlist items")
            
            // Debug print item information
            for (index, item) in items.enumerated() {
                print("Item \(index): ID=\(item.id), Title=\(item.title ?? "nil")")
            }
            
            completion(.success(items))
        } catch {
            print("Error fetching watchlist: \(error)")
            completion(.failure(WatchlistError.failedToFetch))
        }
    }
    
    /// Convert a WatchlistItem to a Title object
    func convertToTitle(from watchlistItem: WatchlistItem) -> Title {
        return Title(
            id: Int(watchlistItem.id),
            mediaType: watchlistItem.mediaType,
            originalName: watchlistItem.mediaType == "tv" ? watchlistItem.title : nil,
            originalTitle: watchlistItem.mediaType == "movie" ? watchlistItem.title : nil,
            posterPath: watchlistItem.posterPath,
            overview: watchlistItem.overview,
            voteCount: 0,
            releaseDate: watchlistItem.releaseDate,
            voteAverage: watchlistItem.voteAverage,
            backdropPath: watchlistItem.backdropPath
        )
    }
    
    // Debug method to print the Core Data storage location
    func printCoreDataStoreLocation() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not access AppDelegate")
            return
        }
        
        let container = appDelegate.persistentContainer
        guard let storeURL = container.persistentStoreCoordinator.persistentStores.first?.url else {
            print("No persistent store URL found")
            return
        }
        
        print("Core Data store location: \(storeURL)")
    }
    
    // Debug method to clear all watchlist items
    func clearAllWatchlistItems(completion: @escaping (Result<Int, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request to get all items
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WatchlistItem")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let count = result?.result as? Int ?? 0
            try context.save()
            print("Cleared \(count) watchlist items")
            NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
            completion(.success(count))
        } catch {
            print("Failed to clear watchlist: \(error)")
            completion(.failure(error))
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let watchlistUpdated = Notification.Name("WatchlistUpdated")
}
