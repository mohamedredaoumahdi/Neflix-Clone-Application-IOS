// Title.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 04/03/2024.
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
    // Using var instead of let for these properties
    var mediaType: String?
    var originalName: String?
    var originalTitle: String?
    var posterPath: String?
    var overview: String?
    var voteCount: Int?
    var releaseDate: String?
    var voteAverage: Double?
    var backdropPath: String?
    
    // Simplified initializer with fewer required parameters
    init(id: Int,
         mediaType: String? = nil,
         originalName: String? = nil,
         originalTitle: String? = nil,
         posterPath: String? = nil,
         overview: String? = nil,
         voteCount: Int? = nil,
         releaseDate: String? = nil,
         voteAverage: Double? = nil,
         backdropPath: String? = nil) {
        self.id = id
        self.mediaType = mediaType
        self.originalName = originalName
        self.originalTitle = originalTitle
        self.posterPath = posterPath
        self.overview = overview
        self.voteCount = voteCount
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.backdropPath = backdropPath
    }
    
    // Computed properties
    var displayTitle: String {
        return originalTitle ?? originalName ?? "Unknown"
    }
    
    var formattedReleaseDate: String? {
        guard let dateString = releaseDate ?? firstAirDate else { return nil }
        
        if let date = DateFormatter.yearFormatter.date(from: dateString) {
            return DateFormatter.readableDateFormatter.string(from: date)
        }
        return dateString
    }
    
    // Additional optional properties
    var genreIds: [Int]?
    var popularity: Double?
    var firstAirDate: String?
    var originCountry: [String]?
    
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
}
