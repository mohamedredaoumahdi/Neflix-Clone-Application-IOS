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
}

struct Season: Codable {
    let id: Int
    let name: String
    let overview: String?
    let seasonNumber: Int
    let episodeCount: Int
    let airDate: String?
    let posterPath: String?
}

struct SimilarTVShowsResponse: Codable {
    let results: [Title]
    let page: Int
    let totalPages: Int
    let totalResults: Int
}
