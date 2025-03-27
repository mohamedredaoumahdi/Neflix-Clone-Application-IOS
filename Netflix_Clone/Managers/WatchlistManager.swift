// WatchlistManager.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 28/03/2025.
//

import UIKit
import CoreData

/// Manages watchlist operations for saving and retrieving user's saved content
class WatchlistManager {
    
    // MARK: - Singleton
    
    static let shared = WatchlistManager()
    
    private init() {}
    
    // MARK: - Properties
    
    enum WatchlistError: Error {
        case failedToSave
        case failedToFetch
        case failedToDelete
        case titleAlreadyInWatchlist
        case unknown
        
        var localizedDescription: String {
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
        // Check if title already exists in watchlist
        if isTitleInWatchlist(id: title.id) {
            completion(.failure(WatchlistError.titleAlreadyInWatchlist))
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let watchlistItem = Netflix_Clone.WatchlistItem(context: context)
        
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
        
        // Save to Core Data
        do {
            try context.save()
            NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
            completion(.success(()))
        } catch {
            print("Error saving to watchlist: \(error)")
            completion(.failure(WatchlistError.failedToSave))
        }
    }
    
    /// Remove a title from the user's watchlist
    func removeFromWatchlist(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let items = try context.fetch(fetchRequest)
            
            if let item = items.first {
                context.delete(item)
                try context.save()
                NotificationCenter.default.post(name: .watchlistUpdated, object: nil)
                completion(.success(()))
            } else {
                // Item not found
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
        let fetchRequest: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking watchlist: \(error)")
            return false
        }
    }
    
    /// Fetch all titles in the watchlist
    func fetchWatchlist(completion: @escaping (Result<[WatchlistItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(WatchlistError.unknown))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "addedDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let items = try context.fetch(fetchRequest)
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
            originalName: watchlistItem.title,
            originalTitle: watchlistItem.title,
            posterPath: watchlistItem.posterPath,
            overview: watchlistItem.overview,
            voteCount: 0,
            releaseDate: watchlistItem.releaseDate,
            voteAverage: watchlistItem.voteAverage,
            backdropPath: watchlistItem.backdropPath
        )
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let watchlistUpdated = Notification.Name("WatchlistUpdated")
}
