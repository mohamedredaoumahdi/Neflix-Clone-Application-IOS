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
            print("Raw JSON structure:")
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString.prefix(1000)) // Print first 1000 chars
            }
            #endif
            
            // Decode the response
            do {
                let decoder = JSONDecoder()
                // REMOVE THIS LINE - it's causing conflicts with explicit CodingKeys
                // decoder.keyDecodingStrategy = .convertFromSnakeCase
                
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
    
    // CENTRALIZED METHOD: Get upcoming movies with pagination
    func getUPComingMovies(page: Int = 1, completion: @escaping (Result<TrendingTitleResponse, Error>) -> Void) {
        // Format today's date as YYYY-MM-DD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: Date())
        
        // Construct URL with today's date as the minimum
        guard let url = URL(string: "\(Configuration.URLs.TMDB_BASE_URL)/movie/upcoming?language=en-US&page=\(page)&primary_release_date.gte=\(todayString)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = createRequest(with: url)
        executeRequest(request: request, completion: completion)
    }
    
    // Convenience method that returns just the results array
    func getUPComingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        getUPComingMovies(page: 1) { result in
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

// MARK: - Calendar API Extensions
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
            case .success(let response):
                movies = response.results.map { title in
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
            // In getUpcomingContent completion handler
            print("Upcoming movies: \(movies.count), TV shows: \(tvShows.count)")
            print("Sample movie date: \(movies.first?.releaseDate ?? "none")")
            print("Sample TV date: \(tvShows.first?.firstAirDate ?? "none")")
            
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

extension APICaller {
    func getRecentReleases(completion: @escaping (Result<[Title], Error>) -> Void) {
        // Calculate date range (last 30 days until today)
        let today = Date()
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!
        
        // Format dates for API
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromDate = formatter.string(from: thirtyDaysAgo)
        let toDate = formatter.string(from: today)
        
        // For movies
        let movieURL = "\(Configuration.URLs.TMDB_BASE_URL)/discover/movie?include_adult=false&include_video=false&language=en-US&page=1&primary_release_date.gte=\(fromDate)&primary_release_date.lte=\(toDate)&sort_by=primary_release_date.desc"
        
        guard let url = URL(string: movieURL) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var movies: [Title] = []
        var tvShows: [Title] = []
        var fetchError: Error?
        
        // Fetch recent movies
        dispatchGroup.enter()
        let movieRequest = createRequest(with: url)
        executeRequest(request: movieRequest) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                // Mark each title as a movie
                movies = response.results.map { title in
                    var mutableTitle = title
                    mutableTitle.mediaType = "movie"
                    return mutableTitle
                }
            case .failure(let error):
                fetchError = error
            }
            dispatchGroup.leave()
        }
        
        // Fetch recent TV shows
        dispatchGroup.enter()
        let tvURL = "\(Configuration.URLs.TMDB_BASE_URL)/discover/tv?include_adult=false&include_null_first_air_dates=false&language=en-US&page=1&air_date.gte=\(fromDate)&air_date.lte=\(toDate)&sort_by=first_air_date.desc"
        
        guard let tvUrl = URL(string: tvURL) else {
            dispatchGroup.leave()
            if fetchError == nil {
                fetchError = APIError.invalidURL
            }
            return
        }
        
        let tvRequest = createRequest(with: tvUrl)
        executeRequest(request: tvRequest) { (result: Result<TrendingTitleResponse, Error>) in
            switch result {
            case .success(let response):
                // Mark each title as TV
                tvShows = response.results.map { title in
                    var mutableTitle = title
                    mutableTitle.mediaType = "tv"
                    return mutableTitle
                }
            case .failure(let error):
                if fetchError == nil {
                    fetchError = error
                }
            }
            dispatchGroup.leave()
        }
        
        // Combine and sort results when both API calls complete
        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
                return
            }
            
            // Combine movies and TV shows
            let allTitles = movies + tvShows
            
            // Sort by release date, newest first
            let sortedTitles = allTitles.sorted { (title1, title2) -> Bool in
                let date1String = title1.releaseDate ?? title1.firstAirDate ?? ""
                let date2String = title2.releaseDate ?? title2.firstAirDate ?? ""
                
                if let date1 = DateFormatter.yearFormatter.date(from: date1String),
                   let date2 = DateFormatter.yearFormatter.date(from: date2String) {
                    return date1 > date2 // Descending order (newest first)
                }
                return false
            }
            
            completion(.success(sortedTitles))
        }
    }
    
    // Update the getUPComingMovies method to sort by nearest release date
    func getUpcomingMoviesSorted(completion: @escaping (Result<[Title], Error>) -> Void) {
        getUPComingMovies { result in
            switch result {
            case .success(let titles):
                // Debug: Print total number of titles
                print("💡 Total titles received: \(titles.count)")
                
                // Debug: Print all release dates
                print("🗓️ Release Dates:")
                titles.forEach { title in
                    print("- \(title.originalTitle ?? "Unknown Title"): \(title.releaseDate ?? "No Date")")
                }
                
                // Get today's date
                let today = Date()
                print("📅 Today's date: \(today)")
                
                // Create a flexible date formatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // Filter for future releases with more detailed logging
                let futureReleases = titles.filter { title in
                    guard let dateString = title.releaseDate else {
                        print("⚠️ No release date for title: \(title.originalTitle ?? "Unknown")")
                        return false
                    }
                    
                    if let releaseDate = dateFormatter.date(from: dateString) {
                        let isFutureRelease = releaseDate >= today
                        print("🔍 Title: \(title.originalTitle ?? "Unknown"), Date: \(dateString), Is Future Release: \(isFutureRelease)")
                        return isFutureRelease
                    } else {
                        print("❌ Failed to parse date: \(dateString) for title: \(title.originalTitle ?? "Unknown")")
                        return false
                    }
                }
                
                // Debug: Print future releases
                print("🚀 Future Releases Count: \(futureReleases.count)")
                futureReleases.forEach { title in
                    print("✅ Future Title: \(title.originalTitle ?? "Unknown"), Release Date: \(title.releaseDate ?? "No Date")")
                }
                
                // Sort by release date (closest first)
                let sortedTitles = futureReleases.sorted { (title1, title2) -> Bool in
                    let date1String = title1.releaseDate ?? ""
                    let date2String = title2.releaseDate ?? ""
                    
                    if let date1 = dateFormatter.date(from: date1String),
                       let date2 = dateFormatter.date(from: date2String) {
                        return date1 < date2 // Ascending order (closest first)
                    }
                    return false
                }
                
                completion(.success(sortedTitles))
                
            case .failure(let error):
                print("❌ Error fetching upcoming movies: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

// Extension to APICaller for top-rated content improvements
extension APICaller {
    // Get top-rated content with higher vote threshold
    func getHighlyRatedContent(completion: @escaping (Result<[Title], Error>) -> Void) {
        getTopRatedMovies { result in
            switch result {
            case .success(let titles):
                // Filter for truly outstanding titles (8.5+ rating)
                let highlyRated = titles.filter { $0.voteAverage ?? 0.0 >= 8.5 }
                completion(.success(highlyRated))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
