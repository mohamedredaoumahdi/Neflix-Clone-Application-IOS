// MovieDetail.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String?
    let backdropPath: String?
    let posterPath: String?
    let genres: [Genre]?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let status: String?
    let tagline: String?
    let budget: Int?
    let revenue: Int?
    let credits: Credits?
    let videos: VideoResponse?
    let similar: SimilarMoviesResponse?
    
    // Computed property for formatted runtime (e.g., "2h 15m")
    var formattedRuntime: String {
        guard let runtime = runtime else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Formatted release year
    var releaseYear: String {
        guard let releaseDate = releaseDate,
              let date = DateFormatter.yearFormatter.date(from: releaseDate) else {
            return "N/A"
        }
        return DateFormatter.yearOnlyFormatter.string(from: date)
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct Credits: Codable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Codable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int
}

struct Crew: Codable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
}

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    let official: Bool
    
    var isYoutubeTrailer: Bool {
        return site.lowercased() == "youtube" && type.lowercased() == "trailer"
    }
}

struct SimilarMoviesResponse: Codable {
    let results: [Title]
    let page: Int
    let totalPages: Int
    let totalResults: Int
}

// MARK: - Date Formatter Extensions

extension DateFormatter {
    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let yearOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static let readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
}
