//
//  MovieSearch.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation
import UIKit

struct MovieSearch: Codable {

  var showData: Data

  enum CodingKeys: String, CodingKey {
    case show
  }

  init(from decoder: Decoder) throws {
    do {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      let dictionary = try values.decode([String: Any].self, forKey: .show)
      showData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
    } catch {
      showData = Data()
        print("Failed to decode MovieSearch")
    }
  }

  func encode(to encoder: Encoder) throws {
  }
}

