//
//  MoviesService.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation

enum MoviesService: ServiceProtocol {

  case allShows(page: Int)
  case showQuery(searchInput: String)
  case castOfShow(showId: Int)
  case episodesOfShow(showId: Int)

  var baseURL: URL {
    return URL(string: "http://api.tvmaze.com/")!
  }

  var path: String {
    switch self {
    case .allShows:
      return "shows"
    case .showQuery:
      return "search/shows"
    case let .castOfShow(showId):
      return "shows/\(showId)/cast"
    case let .episodesOfShow(showId):
      return "shows/\(showId)/episodes"
    }
  }

  var method: HTTPMethod {
    return .get
  }

  var task: Task {
    switch self {
    case let .allShows(page):
      let parameters = ["page": page]
      return .requestParameters(parameters)
    case let .showQuery(searchInput):
      let parameters = ["q": searchInput]
      return .requestParameters(parameters)
    case .castOfShow:
      return .requestPlain
    case .episodesOfShow:
      return .requestPlain
    }
  }

  var headers: Headers? {
    return nil
  }

  var parametersEncoding: ParametersEncoding {
    return .url
  }
}
