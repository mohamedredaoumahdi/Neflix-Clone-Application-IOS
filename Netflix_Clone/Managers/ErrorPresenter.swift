// ErrorPresenter.swift
// Netflix_Clone
//
// Created by mohamed reda oumahdi on 27/03/2025.
//

import UIKit

enum AppError: Error {
    case networkError
    case parsingError
    case apiError(String)
    case downloadError(String)
    case unknownError
    
    var title: String {
        switch self {
        case .networkError:
            return "Network Error"
        case .parsingError:
            return "Data Error"
        case .apiError:
            return "Service Error"
        case .downloadError:
            return "Download Error"
        case .unknownError:
            return "Unknown Error"
        }
    }
    
    var message: String {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .parsingError:
            return "There was a problem processing the data. Please try again later."
        case .apiError(let message):
            return message.isEmpty ? "There was a problem with the service. Please try again later." : message
        case .downloadError(let message):
            return message.isEmpty ? "There was a problem with your download. Please try again." : message
        case .unknownError:
            return "An unexpected error occurred. Please try again later."
        }
    }
}

class ErrorPresenter {
    static func showError(_ error: AppError, on viewController: UIViewController, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            viewController.present(alert, animated: true)
        }
    }
    
    static func showError(_ error: Error, on viewController: UIViewController, completion: (() -> Void)? = nil) {
        let appError: AppError
        
        if let error = error as? AppError {
            appError = error
        } else {
            appError = .apiError(error.localizedDescription)
        }
        
        showError(appError, on: viewController, completion: completion)
    }
}
