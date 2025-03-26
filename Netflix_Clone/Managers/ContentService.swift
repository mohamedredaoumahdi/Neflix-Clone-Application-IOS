// ContentService.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import Foundation

class ContentService {
    
    // MARK: - Singleton
    
    static let shared = ContentService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let apiCaller = APICaller.shared
    
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
    
    /// Gets detailed information for a movie
    func getMovieDetails(for movieId: Int, completion: @escaping (Result<TitlePreviewViewModel, AppError>) -> Void) {
        // First get the movie details
        apiCaller.getMovieDetails(for: movieId) { [weak self] result in
            switch result {
            case .success(let movieDetail):
                // Get YouTube trailer if videos are available
                let youtubeQuery = "\(movieDetail.title) trailer"
                
                self?.apiCaller.getMovie(with: youtubeQuery) { youtubeResult in
                    // Create view model with movie details
                    switch youtubeResult {
                    case .success(let videoElement):
                        // Create view model with all details and trailer
                        let genreNames = movieDetail.genres?.map { $0.name } ?? []
                        let viewModel = TitlePreviewViewModel(
                            title: movieDetail.title,
                            youtubeView: videoElement,
                            titleOverview: movieDetail.overview ?? "No overview available",
                            releaseDate: movieDetail.releaseDate,
                            voteAverage: movieDetail.voteAverage,
                            genres: genreNames,
                            runtime: movieDetail.formattedRuntime
                        )
                        completion(.success(viewModel))
                        
                    case .failure(_):
                        // Create view model without trailer
                        let genreNames = movieDetail.genres?.map { $0.name } ?? []
                        let viewModel = TitlePreviewViewModel(
                            title: movieDetail.title,
                            youtubeView: nil,
                            titleOverview: movieDetail.overview ?? "No overview available",
                            releaseDate: movieDetail.releaseDate,
                            voteAverage: movieDetail.voteAverage,
                            genres: genreNames,
                            runtime: movieDetail.formattedRuntime
                        )
                        completion(.success(viewModel))
                    }
                }
                
            case .failure(let error):
                completion(.failure(self?.mapError(error) ?? .unknownError))
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
