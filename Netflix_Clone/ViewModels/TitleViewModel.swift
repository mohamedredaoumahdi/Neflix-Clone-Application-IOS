//
//  TitleViewModel.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 06/03/2024.
//

import Foundation

struct TitleViewModel {
    let titleName: String
    let posterURL: String
    let releaseDate: String?
    
    // Default initializer for backward compatibility
    init(titleName: String, posterURL: String, releaseDate: String? = nil) {
        self.titleName = titleName
        self.posterURL = posterURL
        self.releaseDate = releaseDate
    }
}
