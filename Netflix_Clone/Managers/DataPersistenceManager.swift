//
//  DataPersistenceManager.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 24/04/2024.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error, LocalizedError {
        case failedToSaveData
        case failedToFetchData
        case failedToDeleteData
        
        var errorDescription: String? {
            switch self {
            case .failedToSaveData:
                return "Failed to save title to database"
            case .failedToFetchData:
                return "Failed to fetch titles from database"
            case .failedToDeleteData:
                return "Failed to delete title from database"
            }
        }
    }
    
    static let shared = DataPersistenceManager()
    
    private init() {}
    
    // MARK: - Core Data Operations
    
    func downloadTitleWith(model: Title, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(DatabaseError.failedToSaveData))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a new TitleItem entity object
        let item = NSEntityDescription.insertNewObject(forEntityName: "TitleItem", into: context) as! TitleItem
        
        // Populate the entity with values from the model
        item.id = Int64(model.id)
        item.original_title = model.originalTitle
        item.original_name = model.originalName
        item.overview = model.overview
        item.media_type = model.mediaType
        item.poster_path = model.posterPath
        item.release_date = model.releaseDate
        item.vote_count = Int64(model.voteCount ?? 0)
        item.vote_average = model.voteAverage ?? 0.0
        
        // Save the context
        do {
            try context.save()
            completion(.success(()))
        } catch {
            print("Failed to save title: \(error)")
            completion(.failure(DatabaseError.failedToSaveData))
        }
    }
    
    func fetchingTitlesFromDataBase(completion: @escaping (Result<[TitleItem], Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(DatabaseError.failedToFetchData))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for TitleItem entities
        let request = NSFetchRequest<TitleItem>(entityName: "TitleItem")
        
        do {
            let titles = try context.fetch(request)
            completion(.success(titles))
        } catch {
            print("Failed to fetch titles: \(error)")
            completion(.failure(DatabaseError.failedToFetchData))
        }
    }
    
    func deleteTitleWith(model: TitleItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(.failure(DatabaseError.failedToDeleteData))
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Delete the object
        context.delete(model)
        
        // Save the changes
        do {
            try context.save()
            completion(.success(()))
        } catch {
            print("Failed to delete title: \(error)")
            completion(.failure(DatabaseError.failedToDeleteData))
        }
    }
}
