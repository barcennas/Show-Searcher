//
//  SynopsisController.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class SynopsisController: UIViewController {

  @IBOutlet weak var lblRuntime: UILabel!
  @IBOutlet weak var lblGenre: UILabel!
  @IBOutlet weak var lblStatus: UILabel!
  @IBOutlet weak var lblNetwork: UILabel!
  @IBOutlet weak var lblPremiered: UILabel!
  @IBOutlet weak var lblOfficialSite: UILabel!
  @IBOutlet weak var lblCast: UILabel!
  @IBOutlet weak var lblSchedule: UILabel!
  @IBOutlet weak var lblSynopsis: UILabel!

  var movie: Movie!

  typealias constants = MovieDetailConstants

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupGestures()
  }

  func setupView() {

    lblOfficialSite.textColor = movie.officialSite == nil ? AppColors.mainColor : AppColors.hyperLinkColor

    if let runtime = movie.runtime {
      lblRuntime.text = "\(runtime) min"
    }
    lblGenre.text = movie.genres?.first
    lblStatus.text = movie.status
    lblNetwork.text = movie.network ?? "Not found"
    lblPremiered.text = movie.premiered?.dateStringFormatt(format: constants.dateFormat)
    lblOfficialSite.text = movie.officialSite ?? "Not found"
    lblCast.text = movie.cast

    lblSynopsis.text = movie.synopsis?.removeHTMLTags()

    guard let scheduleDay = movie.schedule?.last, let dayName = scheduleDay.dayName else { return }
    lblSchedule.text = "\(dayName)  \(scheduleDay.hour ?? "")"
  }

  func setupGestures() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(openWebLink))
    lblOfficialSite.addGestureRecognizer(tap)
    lblOfficialSite.isUserInteractionEnabled = true
  }

  @objc func openWebLink() {
    guard let link = movie.officialSite, let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }


}
