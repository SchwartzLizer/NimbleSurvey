//
//  Router.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

enum Router {

    // MARK: Sign in/out
    case signIn(grantType: String,email: String, password: String,clientID: String,clientSecret: String)
    case refreshToken(grantType: String,refreshToken: String,clientID: String,clientSecret: String)
    case logout(token: String,clientID: String,clientSecret: String)
    case forgotPassword(email: String,clientID: String,clientSecret: String)

    // MARK: Surveys
    case surveyList(page: Int, perPage: Int, bearerToken: String)

    // MARK: User
    case userProfile(bearerToken: String)

    // MARK: Internal

    func request() throws -> URLRequest {
        var urlString: String
        var httpBody: Data?
        var authorizationHeader: String?

        switch self {
        case .signIn(let grantType, let email, let password, let clientID, let clientSecret):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            let requestBody: [String: Any] = [
                "grant_type": grantType,
                "email": email,
                "password": password,
                "client_id": clientID,
                "client_secret": clientSecret,
            ]
            httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        case .refreshToken(let grantType, let refreshToken, let clientID, let clientSecret):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            let requestBody: [String: Any] = [
                "grant_type": grantType,
                "refresh_token": refreshToken,
                "client_id": clientID,
                "client_secret": clientSecret,
            ]
            httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        case .logout(let token, let clientID, let clientSecret):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            let requestBody: [String: Any] = [
                "token": token,
                "client_id": clientID,
                "client_secret": clientSecret,
            ]
            httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        case .forgotPassword(let email, let clientID, let clientSecret):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            let requestBody: [String: Any] = [
                "user": [
                    "email": email,
                ],
                "client_id": clientID,
                "client_secret": clientSecret,
            ]
            httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        case .surveyList(let page, let perPage, let bearerToken):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            var urlComponents = URLComponents(string: urlString)!
            let pageParam = URLQueryItem(name: "page[number]", value: "\(page)")
            let perPageParam = URLQueryItem(name: "page[size]", value: "\(perPage)")
            urlComponents.queryItems = [pageParam, perPageParam]
            guard let url = urlComponents.url else {
                throw ErrorType.parseUrlFail
            }
            authorizationHeader = "Bearer \(bearerToken)"

        case .userProfile(let bearerToken):
            urlString = "\(Router.surveyBaseURL)\(self.path)"
            authorizationHeader = "Bearer \(bearerToken)"
        }

        guard let url = URL(string: urlString) else {
            throw ErrorType.parseUrlFail
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        request.httpMethod = self.method.value
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authorizationHeader = authorizationHeader {
            request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        }
        if self.method == .post {
            request.httpBody = httpBody
        }

        return request
    }

    // MARK: Private

    private enum HTTPMethod {
        case get
        case post
        case put
        case delete

        var value: String {
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .put: return "PUT"
            case .delete: return "DELETE"
            }
        }
    }

    private static let surveyBaseURL = RouterConfiguration.surveyAPI

    private var method: HTTPMethod {
        switch self {
        case .signIn: return .post
        case .refreshToken: return .post
        case .logout: return .post
        case .forgotPassword: return .post
        case .surveyList: return .get
        case .userProfile: return .get
        }
    }

    private var path: String {
        switch self {
        case .signIn: return "oauth/token"
        case .refreshToken: return "oauth/token"
        case .logout: return "oauth/revoke"
        case .forgotPassword: return "passwords"
        case .surveyList: return "surveys"
        case .userProfile: return "me"
        }
    }

}
