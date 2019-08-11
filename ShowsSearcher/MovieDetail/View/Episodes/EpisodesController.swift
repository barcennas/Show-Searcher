//
//  EpisodesController.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

protocol EpisodesControllerDelegate: class {
  func userTappedOnEpisode(episode: Episode)
}

class EpisodesController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  weak var delegate: EpisodesControllerDelegate?
  var seasons: [[Episode]] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTable()
  }

  func setupTable() {
    tableView.register(EpisodeCell.nib(), forCellReuseIdentifier: EpisodeCell.reuseIdentifier())
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .clear
  }

}

extension EpisodesController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Season \(section)"
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let episodeModel = seasons[indexPath.section][indexPath.row]
    delegate?.userTappedOnEpisode(episode: episodeModel)
  }

}

extension EpisodesController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return seasons.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return seasons[section].count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let episodeModel = seasons[indexPath.section][indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseIdentifier(), for: indexPath)
    (cell as? EpisodeCell)?.configure(number: episodeModel.number, name: episodeModel.name)
    return cell
  }
}
