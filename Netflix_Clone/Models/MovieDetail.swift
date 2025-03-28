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
    
    // IMPORTANT: Add explicit CodingKeys for correct mapping
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case genres
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case status
        case tagline
        case budget
        case revenue
        case credits
        case videos
        case similar
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
        case order
    }
}

struct Crew: Codable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case job
        case department
        case profilePath = "profile_path"
    }
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
    
    enum CodingKeys: String, CodingKey {
        case results
        case page
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
