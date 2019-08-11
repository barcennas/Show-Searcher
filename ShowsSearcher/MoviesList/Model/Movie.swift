//
//  Movie.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation
import UIKit

class Movie: Codable {
  
  var id: Int
  var title: String?
  var imageURL: String?
  var rating: Double?
  var runtime: Int?
  var genres: [String]?
  var status: String?
  var network: String?
  var premiered: String?
  var officialSite: String?
  var cast: String?
  var time: String?
  var days: [String]?
  var schedule: [Day]?
  var synopsis: String?
  var seasons: [[Episode]]?
  var isFavorite = false

  init(showDBO: ShowDBO) {
    self.id = showDBO.id
    self.title = showDBO.title
    self.imageURL = showDBO.imageURL
    self.rating = showDBO.rating
    self.runtime = showDBO.runtime
    self.genres = showDBO.genres
    self.status = showDBO.status
    self.network = showDBO.network
    self.premiered = showDBO.premiered
    self.officialSite = showDBO.officialSite
    self.synopsis = showDBO.synopsis
  }

  enum CodingKeys: String, CodingKey {
    case id
    case title = "name"
    case image
    case rating
    case runtime
    case genres
    case status
    case network
    case premiered
    case officialSite
    case schedule
    case synopsis = "summary"
  }

  enum ImageKeys: String, CodingKey {
    case imageURL = "medium"
  }

  enum RatingKeys: String, CodingKey {
    case rating = "average"
  }

  enum NetworkKeys: String, CodingKey {
    case network = "name"
  }

  enum ScheduleKeys: String, CodingKey {
    case time
    case days
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    title = try? values.decode(String.self, forKey: .title)
    runtime = try? values.decode(Int.self, forKey: .runtime)
    genres = try? values.decode([String].self, forKey: .genres)
    status = try? values.decode(String.self, forKey: .status)
    premiered = try? values.decode(String.self, forKey: .premiered)
    officialSite = try? values.decode(String.self, forKey: .officialSite)
    synopsis = try? values.decode(String.self, forKey: .synopsis)
    if let imageContainer = try? values.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
      imageURL = try? imageContainer.decode(String.self, forKey: .imageURL)
    }
    if let ratingContainer = try? values.nestedContainer(keyedBy: RatingKeys.self, forKey: .rating) {
      rating = try? ratingContainer.decode(Double.self, forKey: .rating)
    }
    if let networkContainer = try? values.nestedContainer(keyedBy: NetworkKeys.self, forKey: .network) {
      network = try? networkContainer.decode(String.self, forKey: .network)
    }
    if let scheduleContainer = try? values.nestedContainer(keyedBy: ScheduleKeys.self, forKey: .schedule) {
      time = try? scheduleContainer.decode(String.self, forKey: .time)
      days = try? scheduleContainer.decode([String].self, forKey: .days)
      schedule = []
      for name in days ?? [] {
        let day = Day(dayName: name, hour: time)
        self.schedule?.append(day)
      }
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(id, forKey: .id)
    try? container.encode(title, forKey: .title)
    try? container.encode(runtime, forKey: .runtime)
    try? container.encode(genres, forKey: .genres)
    try? container.encode(status, forKey: .status)
    try? container.encode(premiered, forKey: .premiered)
    try? container.encode(officialSite, forKey: .officialSite)
    try? container.encode(synopsis, forKey: .synopsis)
    var imageContainer = container.nestedContainer(keyedBy: ImageKeys.self, forKey: .image)
    try? imageContainer.encode(imageURL, forKey: .imageURL)
    var ratingContainer = container.nestedContainer(keyedBy: RatingKeys.self, forKey: .rating)
    try? ratingContainer.encode(rating, forKey: .rating)
    var networkContainer = container.nestedContainer(keyedBy: NetworkKeys.self, forKey: .network)
    try? networkContainer.encode(network, forKey: .network)
    var scheduleContainer = container.nestedContainer(keyedBy: ScheduleKeys.self, forKey: .schedule)
    try? scheduleContainer.encode(time, forKey: .time)
    try? scheduleContainer.encode(days, forKey: .days)
  }
  
}
