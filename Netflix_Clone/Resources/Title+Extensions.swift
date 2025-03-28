// Title+Extensions.swift
// Netflix_Clone
//
// Created to enhance the Title model
//

import Foundation

// Extension to add convenience properties to Title model
extension Title {
    // Helper to ensure TV shows have firstAirDate accessible
    mutating func setupTVShowData() {
        if mediaType == "tv" && firstAirDate == nil && releaseDate != nil {
            firstAirDate = releaseDate
        }
    }
    
    // Get the appropriate date depending on content type
    var relevantDate: String? {
        if mediaType == "tv" {
            return firstAirDate ?? releaseDate
        } else {
            return releaseDate ?? firstAirDate
        }
    }
    
    // Get a formatted date string suitable for display
    var formattedDate: String {
        guard let dateString = relevantDate,
              let date = DateFormatter.yearFormatter.date(from: dateString) else {
            return "Coming soon"
        }
        
        return DateFormatter.readableDateFormatter.string(from: date)
    }
}

// Extension for better date comparison
extension Date {
    // Check if date is in the future
    var isFuture: Bool {
        return self > Date()
    }
    
    // Format date to string with specified format
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
