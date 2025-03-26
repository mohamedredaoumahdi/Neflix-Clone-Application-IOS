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
    
    // In APICaller.swift, update the executeRequest method:
    private func executeRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.failedToGetData))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noDataReturned))
                return
            }
            
            // Print raw JSON for debugging

            if let jsonString = String(data: data, encoding: .utf8) {

                print("Raw JSON first 500 chars: \(jsonString.prefix(500))")

            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
                
            } catch {
                print("Decoding error: \(error)")
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
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/\(movieId)?language=en-US&append_to_response=credits,similar,videos") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
    
    func getTVShowDetails(for tvId: Int, completion: @escaping (Result<TVShowDetail, Error>) -> Void) {
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/tv/\(tvId)?language=en-US&append_to_response=credits,similar,videos") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
}
