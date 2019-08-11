//
//  ShowDBO+CoreDataProperties.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/28/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation
import CoreData

extension ShowDBO {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<ShowDBO> {
    return NSFetchRequest<ShowDBO>(entityName: "ShowDBO")
  }

  @NSManaged public var id: Int
  @NSManaged public var title: String?
  @NSManaged public var imageURL: String?
  @NSManaged public var rating: Double
  @NSManaged public var runtime: Int
  @NSManaged public var genres: [String]?
  @NSManaged public var status: String?
  @NSManaged public var network: String?
  @NSManaged public var premiered: String?
  @NSManaged public var officialSite: String?
  @NSManaged public var time: String?
  @NSManaged public var days: [String]?
  @NSManaged public var synopsis: String?
}

