//
//  NetworkManager.swift
//  RentaTeam
//
//  Created by Давид Горзолия on 10/13/21.
//

import UIKit

enum NetworkResult<D, E> {
    case success(_ data: D)
    case failed(_ error: E)
}

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    func fetchPhotos(page: Int, completion: @escaping (NetworkResult<[Result], Error>) -> Void) {
        guard let url = URL(string: getUrl(at: page)) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil,
                  let data = data else {
                      DispatchQueue.main.async {
                          completion(.failed(error!))
                      }
                      return
                  }
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(jsonResult.results))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failed(error))
                }
            }
        }.resume()
    }

    func fetchImage(with url: URL, completion: @escaping (NetworkResult<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                      DispatchQueue.main.async {
                          completion(.failed(error!))
                      }
                      return
                  }
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }.resume()
    }

    private func getUrl(at page: Int) -> String {
        return "https://api.unsplash.com/search/photos?page=\(page)&per_page=30&query=car&client_id=OcVxCJ8hKR4-qT-v_noqzreeJABQ_HTMABVZcWfHCo4"
    }
}
