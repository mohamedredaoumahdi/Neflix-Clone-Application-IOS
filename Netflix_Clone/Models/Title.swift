// Title.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 04/03/2024.
// Updated on 28/03/2025.
//

import Foundation

struct TrendingTitleResponse: Codable {
    let results: [Title]
    let page: Int?
    let totalPages: Int?
    let totalResults: Int?
}

struct Title: Codable {
    let id: Int
    let mediaType: String?
    let originalName: String?
    let originalTitle: String?
    let posterPath: String?
    let overview: String?
    let voteCount: Int?
    let releaseDate: String?
    let voteAverage: Double?
    let backdropPath: String?
    
    // Additional fields for enhanced functionality
    let genreIds: [Int]?
    let popularity: Double?
    let firstAirDate: String?  // For TV shows
    let originCountry: [String]?  // For TV shows
    
    // Computed properties for convenience
    var formattedReleaseDate: String? {
        guard let dateString = releaseDate ?? firstAirDate else { return nil }
        
        // Convert from "yyyy-MM-dd" to "MMMM d, yyyy"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    var releaseYear: String? {
        guard let dateString = releaseDate ?? firstAirDate else { return nil }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    var displayTitle: String {
        return originalTitle ?? originalName ?? "Unknown"
    }
    
    var displayRating: String {
        guard let rating = voteAverage else { return "N/A" }
        return String(format: "%.1f", rating)
    }
    
    // For API compatibility with older endpoints
    enum CodingKeys: String, CodingKey {
        case id
        case mediaType = "media_type"
        case originalName = "original_name"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case overview
        case voteCount = "vote_count"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case popularity
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
    }
    
    // Factory method for creating a Title object from WatchlistItem
    static func fromWatchlistItem(_ item: WatchlistItem) -> Title {
        return Title(
            id: Int(item.id),
            mediaType: item.mediaType,
            originalName: item.mediaType == "tv" ? item.title : nil,
            originalTitle: item.mediaType == "movie" ? item.title : nil,
            posterPath: item.posterPath,
            overview: item.overview,
            voteCount: 0,
            releaseDate: item.releaseDate,
            voteAverage: item.voteAverage,
            backdropPath: item.backdropPath,
            genreIds: nil,
            popularity: nil,
            firstAirDate: nil,
            originCountry: nil
        )
    }
}
