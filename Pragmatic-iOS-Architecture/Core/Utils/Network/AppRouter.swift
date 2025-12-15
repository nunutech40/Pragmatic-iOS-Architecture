//
//  AppRouter.swift
//  LoginTesting
//
//  Created by Nunu Nugraha on 03/12/25.
//

import Foundation
import Alamofire

// Catatan: Pastikan Anda memiliki 'APIConstants' di scope global atau file terpisah.
// struct APIConstants { static let baseURL = "..." }

// MARK: - Protokol Dasar
protocol APIEndpoint: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var isAuthRequired: Bool { get }
}

// MARK: - Endpoint Enum yang Disesuaikan
enum AppRouter: APIEndpoint {
    
    // GET Requests
    case getCategories
    case searchProducts(query: String, limit: Int) // OK: Menangani query dinamis
    
    // POST Requests
    case login(credentials: [String: String])
    case firebaseLogin(token: String) // Tambahan
    case ssoLogin(token: String, provider: String) // Tambahan
    case getProfile
    case submitOrder(data: [String: String])
    
    // MARK: - Implementasi Protokol
    
    var method: HTTPMethod {
        switch self {
        case .login, .firebaseLogin, .ssoLogin, .submitOrder:
            return .post
        default:
            return .get
        }
    }
    
    // Penentuan Path
    var path: String {
        switch self {
        case .getCategories:
            return "/categories"
        case .searchProducts:
            return "/products/search"
        case .login:
            return "/api/v1/auth/login"
        case .firebaseLogin: return "/api/v1/auth/firebase"
        case .ssoLogin: return "/api/v1/auth/sso"
        case .submitOrder:
            return "/orders"
        case .getProfile:
            return "/api/v1/auth/profile"
        }
    }
    
    // Penentuan Parameter (Body/Query)
    var parameters: Parameters? {
        switch self {
        case .login(let credentials):
            return credentials
        case .firebaseLogin(let token):
            return ["firebase_token": token]
        case .ssoLogin(let token, let provider):
            return ["token": token, "provider": provider]
        case .searchProducts(let query, let limit):
            return ["q": query, "limit": limit]
        default:
            return nil
        }
    }
    
    // Penentuan Encoding
    var encoding: ParameterEncoding {
        switch self.method {
        case .post: return JSONEncoding.default
        default: return URLEncoding.default
        }
    }
    
    // MARK: - Implementasi URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        
        // Asumsi 'APIConstants' sudah tersedia
        let url = try APIConstants.baseURL.asURL()
        let finalURL = url.appendingPathComponent(path)
        
        // Header diset ke nil karena akan ditambahkan di APIClient
        var request = try URLRequest(url: finalURL, method: method, headers: nil)
        
        // Encoding Parameters (Alamofire akan merakit URL/Body sesuai 'encoding')
        request = try encoding.encode(request, with: parameters)
        
        return request
    }
    
    
}

extension AppRouter {
    var isAuthRequired: Bool {
        switch self {
        case .login, .firebaseLogin, .ssoLogin: // Semua jenis login TIDAK butuh token
            return false
        default:
            return true
        }
    }
}
