// APICaller.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 04/03/2024.
// Updated on 27/03/2025.
//

import Foundation

enum APIError: Error {
    case failedToGetData
    case invalidURL
    case noDataReturned
    case decodingError
}

class APICaller {
    static let shared = APICaller()
    
    private let headers = [
        "accept": "application/json",
        "Authorization": "Bearer \(Configuration.API.TMDB_API_ACCESS_TOKEN)"
    ]
    
    private init() {}
    
    // MARK: - Helper Methods
    
    private func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = 15
        return request
    }
    
    // Helper method for executing requests with proper error handling
    private func executeRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            // Check for data
            guard let data = data else {
                completion(.failure(APIError.noDataReturned))
                return
            }
            
            // Debug JSON for complex responses
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response first 500 chars: \(String(jsonString.prefix(500)))")
            }
            #endif
            
            // Decode the response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                print("Type being decoded: \(T.self)")
                completion(.failure(APIError.decodingError))
            }
        }
        
        task.resume()
    }
    
    private func formatQueryParameter(param: String) -> String {
        return param.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? param
    }

    // MARK: - Movies API Calls
    
    // In APICaller.swift
    func getTrendingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/trending/movie/day?language=en-US") else {
            print("Invalid URL for trending movies")
            completion(.failure(APIError.invalidURL))
            return
        }
        
        print("Attempting to fetch trending movies from: \(url.absoluteString)")
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                print("Successfully fetched \(response.results.count) trending movies")
                completion(.success(response.results))
            case .failure(let error):
                print("Failed to fetch trending movies: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func getPopularMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/popular?language=en-US&page=1") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTrendingTVShows(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/trending/tv/day?language=en-US") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUPComingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/upcoming?language=en-US&page=1") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getTopRatedMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/top_rated?language=en-US&page=1") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchForMovieByName(with query: String? = nil, completing: @escaping (Result<[Title], Error>) -> Void) {
        let searchQuery = formatQueryParameter(param: query ?? "The Walking Dead")
        
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/search/movie?query=\(searchQuery)&include_adult=false&language=en-US&page=1") else {
            completing(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                completing(.success(response.results))
            case .failure(let error):
                completing(.failure(error))
            }
        }
    }
    
    // MARK: - YouTube API Calls
    
    func getMovie(with query: String, completion: @escaping (Result<VideoElement, Error>) -> Void) {
        let searchQuery = formatQueryParameter(param: query)
        
        guard let url = URL(string: "\(Configuration.URLs.YOUTUBE_BASE_URL)?q=\(searchQuery)&key=\(Configuration.API.YOUTUBE_API_KEY)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noDataReturned))
                return
            }
            
            do {
                let results = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                
                if results.items.isEmpty {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                completion(.success(results.items[0]))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Extended TMDB API Calls
    
    func getMovieDetails(for movieId: Int, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        // Append credits, similar, and videos to get all details in one request
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/\(movieId)?append_to_response=credits,similar,videos&language=en-US") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
    
    func getTVShowDetails(for tvId: Int, completion: @escaping (Result<TVShowDetail, Error>) -> Void) {
        // Append credits, similar, and videos to get all details in one request
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/tv/\(tvId)?append_to_response=credits,similar,videos&language=en-US") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
    
    
}


// Add these methods to your APICaller class to support the Calendar functionality

extension APICaller {
    
    // Get upcoming TV shows (released in the future)
    func getUpcomingTVShows(completion: @escaping (Result<[Title], Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/tv/on_the_air?language=en-US&page=1") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                // Filter for upcoming shows by checking if air date is in the future
                let calendar = Calendar.current
                let currentDate = Date()
                
                let upcomingShows = response.results.filter { title in
                    if let firstAirDateString = title.firstAirDate,
                       let date = DateFormatter.yearFormatter.date(from: firstAirDateString) {
                        return date > currentDate
                    }
                    return false
                }
                
                completion(.success(upcomingShows))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get all upcoming content (movies and TV shows) for a unified calendar view
    func getUpcomingContent(completion: @escaping (Result<[Title], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var movies: [Title] = []
        var tvShows: [Title] = []
        var fetchError: Error?
        
        // Fetch upcoming movies
        dispatchGroup.enter()
        getUPComingMovies { result in
            switch result {
            case .success(let titles):
                movies = titles.map { title in
                    var mutableTitle = title
                    if mutableTitle.mediaType == nil {
                        mutableTitle.mediaType = "movie"
                    }
                    return mutableTitle
                }
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        // Fetch upcoming TV shows
        dispatchGroup.enter()
        getUpcomingTVShows { result in
            switch result {
            case .success(let titles):
                tvShows = titles.map { title in
                    var mutableTitle = title
                    if mutableTitle.mediaType == nil {
                        mutableTitle.mediaType = "tv"
                    }
                    return mutableTitle
                }
            case .failure(let error):
                if fetchError == nil {
                    fetchError = error
                }
            }
            dispatchGroup.leave()
        }
        
        // Process results when both calls complete
        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
                return
            }
            
            // Combine and sort by release date
            let allTitles = (movies + tvShows).sorted {
                let date1 = DateFormatter.yearFormatter.date(from: $0.releaseDate ?? $0.firstAirDate ?? "") ?? Date.distantFuture
                let date2 = DateFormatter.yearFormatter.date(from: $1.releaseDate ?? $1.firstAirDate ?? "") ?? Date.distantFuture
                return date1 < date2
            }
            
            completion(.success(allTitles))
        }
    }
    
    // Get releases for a specific date range
    func getReleasesInDateRange(from startDate: Date, to endDate: Date, completion: @escaping (Result<[Title], Error>) -> Void) {
        // First get all upcoming content
        getUpcomingContent { result in
            switch result {
            case .success(let titles):
                // Filter by date range
                let filteredTitles = titles.filter { title in
                    if let dateString = title.releaseDate ?? title.firstAirDate,
                       let releaseDate = DateFormatter.yearFormatter.date(from: dateString) {
                        return releaseDate >= startDate && releaseDate <= endDate
                    }
                    return false
                }
                
                completion(.success(filteredTitles))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
