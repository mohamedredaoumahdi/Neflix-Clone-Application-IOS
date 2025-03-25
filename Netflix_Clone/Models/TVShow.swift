//
//  TVShow.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 04/03/2024.
//

import Foundation

struct TrendingTVShowResponse : Codable{
    let results: [TVShow]
}

struct TVShow : Codable {
    
    let id : Int
    let media_type : String?
    let original_name : String?
    let original_titile : String?
    let poster_path : String?
    let overview : String?
    let vote_count : Int
    let release_date : String?
    let vote_average : Double
}
