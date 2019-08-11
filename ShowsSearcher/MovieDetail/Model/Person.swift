//
//  Person.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

struct Person: Codable {
  var id: Int?
  var name: String?

  enum CodingKeys: String, CodingKey {
    case person
  }

  enum PersonKeys: String, CodingKey {
    case id
    case name
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    if let personContainer = try? values.nestedContainer(keyedBy: PersonKeys.self, forKey: .person) {
      id = try? personContainer.decode(Int.self, forKey: .id)
      name = try? personContainer.decode(String.self, forKey: .name)
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    var personContainer = container.nestedContainer(keyedBy: PersonKeys.self, forKey: .person)
    try? personContainer.encode(id, forKey: .id)
    try? personContainer.encode(name, forKey: .name)
  }

}
