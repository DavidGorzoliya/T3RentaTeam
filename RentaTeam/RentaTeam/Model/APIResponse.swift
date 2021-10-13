//
//  APIResponse.swift
//  RentaTeam
//
//  Created by Давид Горзолия on 10/13/21.
//

import Foundation
import UIKit

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let created_at: String
    let likes: Int
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
    let small: String
}
