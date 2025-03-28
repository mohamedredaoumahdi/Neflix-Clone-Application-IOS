//
//  TitleViewModel.swift
//  Netflix_Clone
//
//  Created by mohamed reda oumahdi on 06/03/2024.
//  Updated for new release and top rated indicators
//

import Foundation

struct TitleViewModel {
    let titleName: String
    let posterURL: String
    let releaseDate: String?
    let isNewRelease: Bool
    let isTopRated: Bool
    
    // Default initializer with all parameters
    init(titleName: String,
         posterURL: String,
         releaseDate: String? = nil,
         isNewRelease: Bool = false,
         isTopRated: Bool = false) {
        self.titleName = titleName
        self.posterURL = posterURL
        self.releaseDate = releaseDate
        self.isNewRelease = isNewRelease
        self.isTopRated = isTopRated
    }
}
