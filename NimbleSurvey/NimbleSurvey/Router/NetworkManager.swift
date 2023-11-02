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

    func request<T: Decodable>(
        router: Router,
        retryCount: Int = 3,
        completion: @escaping (NetworkResult<T, NetworkError>) -> ())
    {
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
                    } else if response.statusCode == 401, retryCount > 0 { // Unauthorized
                        // Refresh token and retry
                        self.refreshToken { isSuccess in
                            if isSuccess {
                                // Retry original request
                                self.request(router: router, retryCount: retryCount - 1, completion: completion)
                            } else {
                                completion(.failure(.authenticationError))
                            }
                        }
                    } else {
                        // Other error responses
                        do {
                            let errorData = data ?? Data()
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: errorData)
                            completion(.failure(.serverError(errorResponse)))
                        } catch let decodingError {
                            completion(.failure(.decodingError(decodingError)))
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

    private func refreshToken(completion: @escaping (Bool) -> Void) {
        let router = Router.refreshToken(
            grantType: GrantType.refreshToken.rawValue,
            refreshToken: Keychain.shared.getRefreshToken(),
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success(let data):
                guard let data = data.data?.attributes?.refreshToken, !data.isEmpty else {
                    return AlertUtility.showAlert(
                        title: Constants.Keys.appName.localized(),
                        message: Constants.Keys.refresherTokenError.localized())
                    {
                        AppUtility().loginScene()
                    }
                }
                _ = Keychain.shared.saveRefreshToken(data: data)
                completion(true)
            case .failure(let error):
                print("Failed to refresh token: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

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
    case authenticationError
    case unknown
}

// MARK: - MockNetworkManager

class MockNetworkManager: NetworkManager {
    override func request<T: Decodable>(
        router _: Router,
        retryCount _: Int = 3,
        completion: @escaping (NetworkResult<T, NetworkError>) -> ())
    {
        // Replace with your expected successful JSON response
        let successfulResponse = """
            """.data(using: .utf8)!

        do {
            let decodedData = try JSONDecoder().decode(T.self, from: successfulResponse)
            completion(.success(decodedData))
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
}

