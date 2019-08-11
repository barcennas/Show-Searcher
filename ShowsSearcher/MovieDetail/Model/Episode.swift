//
//  Episode.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

struct Episode: Codable {
  var id: Int
  var imageUrl: String?
  var season: Int?
  var number: Int?
  var name: String?
  var duration: Int?
  var summary: String?

  enum CodingKeys: String, CodingKey {
    case id
    case image
    case season
    case number
    case name
    case duration = "runtime"
    case summary
  }

  enum ImageKeys: String, CodingKey {
    case original
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(Int.self, forKey: .id)
    season = try? values.decode(Int.self, forKey: .season)
    number = try? values.decode(Int.self, forKey: .number)
    name = try? values.decode(String.self, forKey: .name)
    duration = try? values.decode(Int.self, forKey: .duration)
    summary = try? values.decode(String.self, forKey: .summary)
    if let imageContainer = try? values.nestedContainer(keyedBy: ImageKeys.self, forKey: .image) {
      imageUrl = try? imageContainer.decode(String.self, forKey: .original)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try? container.encode(id, forKey: .id)
    try? container.encode(season, forKey: .season)
    try? container.encode(number, forKey: .number)
    try? container.encode(name, forKey: .name)
  }

}

