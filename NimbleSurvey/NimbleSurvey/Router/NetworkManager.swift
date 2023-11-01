//
//  NetworkManager.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - NetworkManager

class NetworkManager {

    // MARK: Lifecycle

    private init() {
        self.config = URLSessionConfiguration.default
        self.session = URLSession(configuration: self.config)
    }

    // MARK: Public

    public static let shared = NetworkManager() // Singleton

    // MARK: Internal

    func request<T: Decodable>(router: Router, completion: @escaping (NetworkResult<T, NetworkError>) -> ()) {
        do {
            let task = try session.dataTask(with: router.request()) { data, urlResponse, error in
                DispatchQueue.main.async {
                    if let error = error as? URLError {
                        completion(.failure(.urlError(error)))
                        return
                    }

                    guard let response = urlResponse as? HTTPURLResponse else {
                        completion(.failure(.unknown)) // or handle appropriately
                        return
                    }

                    if (200...299).contains(response.statusCode) {
                        // Successful response
                        guard let data = data else {
                            completion(.failure(.decodingError(DecodingError.dataCorrupted(DecodingError.Context(
                                codingPath: [],
                                debugDescription: "Data was nil")))))
                            return
                        }

                        do {
                            let result = try JSONDecoder().decode(T.self, from: data)
                            completion(.success(result))
                        } catch let decodingError {
                            completion(.failure(.decodingError(decodingError)))
                        }
                    } else {
                        // Error response, attempt to parse our custom error
                        do {
                            let errorData = data ?? Data() // handle the possibility of no data being received
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: errorData)
                            completion(.failure(.serverError(errorResponse)))
                        } catch let decodingError {
                            completion(.failure(.decodingError(decodingError))) // handle the error if parsing fails
                        }
                    }
                }
            }
            task.resume()
        } catch let error {
            Logger.print("Error: \(error.localizedDescription)")
            completion(.failure(.unknown))
        }
    }

    func setSession(_ newSession: URLSession) {
        self.session = newSession
    }

    // MARK: Private

    private let config: URLSessionConfiguration
    private var session: URLSession

}

extension URLResponse {
    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

// MARK: - NetworkResult

enum NetworkResult<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

// MARK: - EmptyResponse

struct EmptyResponse: Decodable { }

// MARK: - NetworkError

enum NetworkError: Error {
    case urlError(URLError)
    case decodingError(Error)
    case serverError(ErrorResponse) // This is your custom server error
    case unknown
}
