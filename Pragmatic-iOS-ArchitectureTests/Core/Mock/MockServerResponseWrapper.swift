//
//  MockServerResponseWrapper.swift
//  Pragmatic-iOS-Architecture
//
//  Created by Nunu Nugraha on 16/12/25.
//
import Foundation
@testable import Pragmatic_iOS_Architecture

// File: MockTestHelpers.swift (atau di dalam UserRepositoryTests.swift)
struct MockServerResponseWrapper<T: Codable>: Codable {
    let meta: Meta
    let data: T
    
    // Helper untuk membuat wrapper sukses
    static func success(data: T) -> MockServerResponseWrapper<T> {
        let successMeta = Meta(
            message: "Authentication Success",
            code: 200,
            status: "success"
        )
        return MockServerResponseWrapper(meta: successMeta, data: data)
    }
}
