// Configuration.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import Foundation

struct Configuration {
    // MARK: - API Keys and Tokens
    
    struct API {
        // IMPORTANT: In a production app, these would be secured via proper key management
        static let TMDB_API_KEY = "2758db7be33f5f2c077dc91357743490"
        static let TMDB_API_ACCESS_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyNzU4ZGI3YmUzM2Y1ZjJjMDc3ZGM5MTM1Nzc0MzQ5MCIsIm5iZiI6MTcwOTU1Njk4Ni4xOCwic3ViIjoiNjVlNWM0ZmFhNjcyNTQwMTg1YWRiYWFlIiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.0g9nYpYkZ5_qX3QbgYSP62Xu77-z3Txeki13bhLxeSU"
        static let YOUTUBE_API_KEY = "AIzaSyCERrft97Cc9g0KLybOwVBgyaREuZuuNbA"
    }
    
    // MARK: - URL Endpoints
    
    struct URLs {
        static let TMDB_BASE_URL = "https://api.themoviedb.org/3"
        static let TMDB_IMAGE_URL = "https://image.tmdb.org/t/p/w500"
        static let YOUTUBE_BASE_URL = "https://youtube.googleapis.com/youtube/v3/search"
        static let YOUTUBE_EMBED_URL = "https://www.youtube.com/embed/"
    }
    
    // MARK: - UI Constants
    
    struct UI {
        // Common spacing values
        static let standardSpacing: CGFloat = 16
        static let compactSpacing: CGFloat = 8
        static let largeSpacing: CGFloat = 24
        
        // Standard animation durations
        static let standardAnimationDuration: TimeInterval = 0.3
        static let quickAnimationDuration: TimeInterval = 0.15
    }
}
