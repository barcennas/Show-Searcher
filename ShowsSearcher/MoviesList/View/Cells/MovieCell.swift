//
//  MovieCell.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/26/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

protocol MovieCellDelegate: class {
  func userRemovedShowFromFavorite(position: Int)
}

class MovieCell: UICollectionViewCell {

  @IBOutlet weak var viewContent: UIView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var loader: UIActivityIndicatorView!
  @IBOutlet weak var imgMovie: UIImageView!
  @IBOutlet weak var lblRating: UILabel!
  @IBOutlet weak var imgFavorite: UIImageView!

  lazy var showFavoritesHelper = ShowFavoritesHelper()
  lazy var session = URLSession.shared
  private var task: URLSessionDataTask?
  var imageCache: NSCache<NSString, UIImage>?
  var show: Movie!
  weak var delegate: MovieCellDelegate?
  var index = 0

  override func awakeFromNib() {
    super.awakeFromNib()
    setupFavoriteTapGesture()
    imgMovie.contentMode = .scaleAspectFill
    viewContent.layer.borderWidth = 0.5
    viewContent.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.6).cgColor
    viewContent.layer.cornerRadius = 5
    viewContent.clipsToBounds = true
    loader.startAnimating()
  }

  override func prepareForReuse() {
    lblTitle.text = ""
    lblRating.text = ""
    imgMovie.image = nil
    setLoader(active: true)
    cancelDownload()
  }

  func configure(show: Movie, cache: NSCache<NSString, UIImage>) {
    self.show = show
    self.imageCache = cache
    lblTitle.text = show.title
    if let rating = show.rating {
      lblRating.text = "\(rating)"
    }
    imgFavorite.image = show.isFavorite ? #imageLiteral(resourceName: "star_filled") : #imageLiteral(resourceName: "star_unfilled")
    checkForImage(urlString: show.imageURL)
  }


  func checkForImage(urlString: String?) {
    guard let urlString = urlString, let url = URL(string: urlString) else { return }
    if let cachedImage = imageCache?.object(forKey: urlString as NSString) {
      setLoader(active: false)
      imgMovie.image = cachedImage
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
        self?.imgMovie.image = UIImage(data: data)
      }
    }
    task?.resume()
  }

  func cancelDownload(){
    task?.cancel()
  }

  func setLoader(active: Bool){
    if active {
      self.loader.isHidden = false
      self.imgMovie.isHidden = true
    } else {
      self.loader.isHidden = true
      self.imgMovie.isHidden = false
    }
  }

  func setupFavoriteTapGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(setShowFavorite))
    imgFavorite.addGestureRecognizer(tap)
    imgFavorite.isUserInteractionEnabled = true
  }

  @objc func setShowFavorite() {
    if !show.isFavorite {
      showFavoritesHelper.saveShowToFavorites(show: show) { [weak self] (success) in
        if success {
          self?.show.isFavorite = true
          self?.imgFavorite.image = #imageLiteral(resourceName: "star_filled")
        }
      }
    } else {
      showFavoritesHelper.removeShowFromFavorites(showId: show.id) { [weak self] (success) in
        if success {
          self?.show.isFavorite = false
          self?.imgFavorite.image = #imageLiteral(resourceName: "star_unfilled")
          guard let index = self?.index else { return }
          self?.delegate?.userRemovedShowFromFavorite(position: index)
        }
      }
    }

  }

}
