//
//  NetworkingEnums.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

typealias Parameters = [String: Any]

enum Task {
  case requestPlain
  case requestParameters(Parameters)
}

enum ParametersEncoding {
  case url
  case json
}

enum NetworkResponse<T> {
  case success(T)
  case failure(NetworkError)
}

enum NetworkError {
  case serverError
  case notFound
}
