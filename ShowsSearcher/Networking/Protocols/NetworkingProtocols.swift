//
//  NetworkingProtocols.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation

// MARK: ServiceProtocol
typealias Headers = [String: String]

protocol ServiceProtocol {
  var baseURL: URL { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var task: Task { get }
  var headers: Headers? { get }
  var parametersEncoding: ParametersEncoding { get }
}

// MARK: ProviderProtocol
protocol ProviderProtocol {
  func request<T>(type: T.Type, service: ServiceProtocol, completion: @escaping (NetworkResponse<T>) -> ()) where T: Decodable
}

// MARK: URLSessionProtocol
protocol URLSessionProtocol {
  typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()
  func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {
  func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask {
    return dataTask(with: request, completionHandler: completionHandler)
  }
}
