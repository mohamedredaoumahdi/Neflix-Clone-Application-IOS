// TitlePreviewViewModel.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 21/04/2024.
// Updated on 27/03/2025.
//

import Foundation

struct TitlePreviewViewModel {
    let title: String
    let titleOverview: String
    let youtubeView: VideoElement?
    
    // Additional metadata
    let releaseDate: String?
    let voteAverage: Double?
    let genres: [String]?
    let runtime: String?
    
    // Detailed information
    let movieDetail: MovieDetail?
    let tvShowDetail: TVShowDetail?
    
    // Initializer with full details
    init(title: String, youtubeView: VideoElement?, titleOverview: String,
         releaseDate: String? = nil, voteAverage: Double? = nil,
         genres: [String]? = nil, runtime: String? = nil,
         movieDetail: MovieDetail? = nil, tvShowDetail: TVShowDetail? = nil) {
        self.title = title
        self.youtubeView = youtubeView
        self.titleOverview = titleOverview
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genres = genres
        self.runtime = runtime
        self.movieDetail = movieDetail
        self.tvShowDetail = tvShowDetail
    }
    
    // Convenience initializer from a MovieDetail
    init(movieDetail: MovieDetail, youtubeView: VideoElement?) {
        self.title = movieDetail.title
        self.titleOverview = movieDetail.overview ?? "No overview available"
        self.youtubeView = youtubeView
        self.releaseDate = movieDetail.releaseDate
        self.voteAverage = movieDetail.voteAverage
        self.genres = movieDetail.genres?.map { $0.name }
        self.runtime = movieDetail.formattedRuntime
        self.movieDetail = movieDetail
        self.tvShowDetail = nil
    }
    
    // Convenience initializer from a TVShowDetail
    init(tvShowDetail: TVShowDetail, youtubeView: VideoElement?) {
        self.title = tvShowDetail.name
        self.titleOverview = tvShowDetail.overview ?? "No overview available"
        self.youtubeView = youtubeView
        self.releaseDate = tvShowDetail.firstAirDate
        self.voteAverage = tvShowDetail.voteAverage
        self.genres = tvShowDetail.genres?.map { $0.name }
        self.runtime = "\(tvShowDetail.numberOfSeasons ?? 0) Seasons"
        self.movieDetail = nil
        self.tvShowDetail = tvShowDetail
    }
    
    // Simplified initializer for backward compatibility
    init(title: String, youtubeView: VideoElement, titleOverview: String) {
        self.title = title
        self.youtubeView = youtubeView
        self.titleOverview = titleOverview
        self.releaseDate = nil
        self.voteAverage = nil
        self.genres = nil
        self.runtime = nil
        self.movieDetail = nil
        self.tvShowDetail = nil
    }
}
