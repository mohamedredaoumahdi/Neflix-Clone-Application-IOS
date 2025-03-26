//
//  Title.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 04/03/2024.
//

import Foundation

struct TrendingTitleResponse : Codable{
    let results: [Title]
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
}
