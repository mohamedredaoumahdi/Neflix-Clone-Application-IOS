// ContentService.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import UIKit

class ContentService {
    
    // MARK: - Singleton
    
    static let shared = ContentService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let apiCaller = APICaller.shared
    
    // MARK: - Loading Detailed Title Information
    
    /// Loads detailed title information and creates a view controller
    func loadDetailedTitle(for title: Title, completion: @escaping (Result<TitlePreviewViewController, AppError>) -> Void) {
        // Determine if this is a movie or TV show
        let isTV = title.mediaType == "tv" || (title.originalName != nil && title.originalTitle == nil)
        let titleId = title.id
        
        // Create loading sequence
        let dispatchGroup = DispatchGroup()
        
        // Variables to store results
        var movieDetail: MovieDetail?
        var tvShowDetail: TVShowDetail?
        var youtubeElement: VideoElement?
        var loadError: Error?
        
        // 1. Fetch YouTube trailer
        dispatchGroup.enter()
        let titleName = title.originalTitle ?? title.originalName ?? "Unknown"
        apiCaller.getMovie(with: "\(titleName) trailer") { result in
            switch result {
            case .success(let videoElement):
                youtubeElement = videoElement
            case .failure(let error):
                print("Failed to fetch trailer: \(error.localizedDescription)")
                // Don't set loadError, as trailer is optional
            }
            dispatchGroup.leave()
        }
        
        // 2. Fetch detailed information
        dispatchGroup.enter()
        if isTV {
            apiCaller.getTVShowDetails(for: titleId) { result in
                switch result {
                case .success(let details):
                    tvShowDetail = details
                case .failure(let error):
                    loadError = error
                    print("Failed to fetch TV details: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        } else {
            apiCaller.getMovieDetails(for: titleId) { result in
                switch result {
                case .success(let details):
                    movieDetail = details
                case .failure(let error):
                    loadError = error
                    print("Failed to fetch movie details: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        // Process results when all operations complete
        dispatchGroup.notify(queue: .main) {
            // Check for errors
            if let error = loadError {
                completion(.failure(self.mapError(error)))
                return
            }
            
            // Create appropriate view model
            let viewModel: TitlePreviewViewModel
            
            if let movieDetail = movieDetail {
                viewModel = TitlePreviewViewModel(movieDetail: movieDetail, youtubeView: youtubeElement)
            } else if let tvShowDetail = tvShowDetail {
                viewModel = TitlePreviewViewModel(tvShowDetail: tvShowDetail, youtubeView: youtubeElement)
            } else {
                // Fallback to basic view model if no detailed info available
                viewModel = TitlePreviewViewModel(
                    title: titleName,
                    youtubeView: youtubeElement,
                    titleOverview: title.overview ?? "No overview available",
                    releaseDate: title.releaseDate,
                    voteAverage: title.voteAverage
                )
            }
            
            // Create and configure view controller
            let viewController = TitlePreviewViewController()
            viewController.configure(with: viewModel)
            
            completion(.success(viewController))
        }
    }
    
    // MARK: - Content Loading Methods
    
    /// Fetches trending movies and handles errors
    func getTrendingMovies(completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.getTrendingMovies { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    /// Fetches trending TV shows and handles errors
    func getTrendingTVShows(completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.getTrendingTVShows { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    /// Fetches popular movies and handles errors
    func getPopularMovies(completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.getPopularMovies { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    /// Fetches upcoming movies and handles errors
    func getUpcomingMovies(completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.getUPComingMovies { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    /// Fetches top rated movies and handles errors
    func getTopRatedMovies(completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.getTopRatedMovies { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    /// Searches for movies by name and handles errors
    func searchMovies(with query: String, completion: @escaping (Result<[Title], AppError>) -> Void) {
        apiCaller.searchForMovieByName(with: query) { result in
            switch result {
            case .success(let titles):
                completion(.success(titles))
            case .failure(let error):
                completion(.failure(self.mapError(error)))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Maps standard Error to AppError for consistent error handling
    private func mapError(_ error: Error) -> AppError {
        if let apiError = error as? APIError {
            switch apiError {
            case .failedToGetData:
                return .apiError("Failed to get data from the server")
            case .invalidURL:
                return .apiError("Invalid URL")
            case .noDataReturned:
                return .apiError("No data returned from the server")
            case .decodingError:
                return .parsingError
            }
        } else if let nsError = error as? NSError {
            // Check for network-related errors
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet,
                     NSURLErrorNetworkConnectionLost,
                     NSURLErrorCannotConnectToHost:
                    return .networkError
                default:
                    break
                }
            }
        }
        
        // Default to unknown error with the original error message
        return .apiError(error.localizedDescription)
    }
}
