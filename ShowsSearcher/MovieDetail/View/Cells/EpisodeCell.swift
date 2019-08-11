//
//  EpisodeCell.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

  @IBOutlet weak var lblNumber: UILabel!
  @IBOutlet weak var lblDescription: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  func configure(number: Int?, name: String?) {
    var num = ""
    if let number = number { num = "\(number)" }
    lblNumber.text = "\(num)."
    lblDescription.text = name ?? ""
  }

}
