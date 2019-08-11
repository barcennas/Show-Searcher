//
//  EpisodeDetailModal.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/28/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class EpisodeDetailModal: UIViewController {

  @IBOutlet weak var viewModalContainer: UIView!
  @IBOutlet weak var imgEpisode: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var lblSeason: UILabel!
  @IBOutlet weak var lblEpisode: UILabel!
  @IBOutlet weak var lblDuration: UILabel!
  @IBOutlet weak var lblSummary: UILabel!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  
  var episode: Episode!
  lazy var session = URLSession.shared
  private var task: URLSessionDataTask?
  var imageCache: NSCache<NSString, UIImage>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  func setupView() {
    self.viewModalContainer.layer.cornerRadius = 10
    self.viewModalContainer.clipsToBounds = true

    lblTitle.text = episode.name
    if let season = episode.season {
      lblSeason.text = "Season \(season)"
    } else {
      lblSeason.text = "Season ?"
    }
    if let episode = episode.number {
      lblEpisode.text = "Episode \(episode)"
    } else {
      lblEpisode.text = "Episode ?"
    }

    lblSummary.text = "No summary found"
    if let summary = episode.summary?.removeHTMLTags(), !summary.isEmpty {
      lblSummary.text = summary
    }

    setLoader(active: true)
    checkForImage(urlString: episode.imageUrl)
  }

  @IBAction func closeModal(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  

  func checkForImage(urlString: String?) {
    guard let urlString = urlString, let url = URL(string: urlString) else {
      setLoader(active: false)
      imgEpisode.contentMode = .scaleAspectFit
      imgEpisode.image = #imageLiteral(resourceName: "noImage")
      return
    }
    if let cachedImage = imageCache?.object(forKey: urlString as NSString) {
      setLoader(active: false)
      imgEpisode.image = cachedImage
    } else {
      downloadImage(urlString: urlString, imageURL: url)
    }
  }

  func downloadImage(urlString: String, imageURL: URL) {
    task = session.dataTask(with: imageURL) { [weak self] (data, response, error) in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.async() {
        guard let downlaodedImage = UIImage(data: data) else { return }
        self?.setLoader(active: false)
        self?.imageCache?.setObject(downlaodedImage, forKey: urlString as NSString)
        self?.imgEpisode.image = UIImage(data: data)
      }
    }
    task?.resume()
  }

  func setLoader(active: Bool){
    self.loader.isHidden = !active
  }

}
