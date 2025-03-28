// TVShowDetail.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import Foundation

struct TVShowDetail: Codable {
    let id: Int
    let name: String
    let overview: String?
    let backdropPath: String?
    let posterPath: String?
    let genres: [Genre]?
    let firstAirDate: String?
    let lastAirDate: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let status: String?
    let tagline: String?
    let voteAverage: Double
    let voteCount: Int
    let credits: Credits?
    let videos: VideoResponse?
    let similar: SimilarTVShowsResponse?
    let seasons: [Season]?
    let createdBy: [Creator]?
    
    // Computed property for duration range
    var yearRange: String {
        let startYear = formatYear(firstAirDate)
        let endYear = status?.lowercased() == "ended" ? formatYear(lastAirDate) : "Present"
        
        return "\(startYear) - \(endYear)"
    }
    
    private func formatYear(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = DateFormatter.yearFormatter.date(from: dateString) else {
            return "N/A"
        }
        return DateFormatter.yearOnlyFormatter.string(from: date)
    }
    
    // IMPORTANT: Add explicit CodingKeys for snake_case mapping
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"
        case genres
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
        case status
        case tagline
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case credits
        case videos
        case similar
        case seasons
        case createdBy = "created_by"
    }
}

struct Creator: Codable {
    let id: Int
    let name: String
    let profilePath: String?
    let creditId: String?
    let gender: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePath = "profile_path"
        case creditId = "credit_id"
        case gender
    }
}

struct Season: Codable {
    let id: Int
    let name: String
    let overview: String?
    let seasonNumber: Int
    let episodeCount: Int
    let airDate: String?
    let posterPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case seasonNumber = "season_number"
        case episodeCount = "episode_count"
        case airDate = "air_date"
        case posterPath = "poster_path"
    }
}

struct SimilarTVShowsResponse: Codable {
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
