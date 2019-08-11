//
//  MovieDetailController.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController, LoadableViewController {

  static var storyboardFileName = "MovieDetail"

  // MARK: Outlets
  @IBOutlet weak var imgMovie: UIImageView!
  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var gradientView: UIView!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var mainLoader: UIStackView!

  var movie: Movie!
  var imageCache: NSCache<NSString, UIImage>?
  lazy var sessionProvider = URLSessionProvider()

  private lazy var synopsisViewController: SynopsisController = {
    let controller = SynopsisController(nibName: String(describing: SynopsisController.self), bundle: nil)
    controller.movie = movie
    return controller
  }()

  private lazy var episodesViewController: EpisodesController = {
    let controller = EpisodesController(nibName: String(describing: EpisodesController.self), bundle: nil)
    controller.seasons = movie.seasons ?? []
    controller.delegate = self
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupView()
    setupSegmentControl()
    getShowCastAndEpisodes()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupGradient()
  }

  func setupNavigationBar() {
    //self.view.backgroundColor = .black
    self.navigationItem.title = "Show Detail"
  }

  func setupView() {
    setupGradient()

    lblTitle.text = movie.title
    if let urlString = movie.imageURL, let cachedImage = imageCache?.object(forKey: urlString as NSString) {
      imgMovie.contentMode = .scaleAspectFill
      imgMovie.clipsToBounds = true
      imgMovie.image = cachedImage
    }
  }

  func setupGradient(){
    let layer = CAGradientLayer()
    layer.frame = gradientView.bounds
    layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
    gradientView.layer.addSublayer(layer)
  }

  func setupSegmentControl(){
    segmentControl.tintColor = AppColors.mainColor
    segmentControl.setTitle("Synopsis", forSegmentAt: 0)
    segmentControl.setTitle("Episodes", forSegmentAt: 1)
    segmentControl.isUserInteractionEnabled = false
  }


  // Adds the passed controller to the container view
  private func add(asChildViewController viewController: UIViewController) {
    addChild(viewController)
    containerView.addSubview(viewController.view)
    (viewController as? SynopsisController)?.movie = self.movie
    viewController.view.frame = containerView.bounds
    viewController.didMove(toParent: self)
  }

  // Removes the passed controller from the container view
  private func remove(asChildViewController viewController: UIViewController) {
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
  }

  //Updates the container view depending on the selected option
  private func updateView() {
    if segmentControl.selectedSegmentIndex == 0 {
      remove(asChildViewController: episodesViewController)
      add(asChildViewController: synopsisViewController)
    } else {
      remove(asChildViewController: synopsisViewController)
      add(asChildViewController: episodesViewController)
    }
  }

  func getShowCastAndEpisodes(){
    guard isUserConnectedToInternet(completion: { _ in self.getShowCastAndEpisodes() }) else { return }
    let group = DispatchGroup()
    group.enter()
    sessionProvider.request(type: [Person].self, service: MoviesService.castOfShow(showId: movie.id)) { [weak self] response in
      switch response {
      case let .success(movies):
        self?.movie.cast = movies.map { $0.name }.compactMap { $0 }.joined(separator: ", ")
      case let .failure(error):
        print(error)
      }
      group.leave()
    }

    group.enter()
    sessionProvider.request(type: [Episode].self, service: MoviesService.episodesOfShow(showId: movie.id)) { [weak self] response in
      switch response {
      case let .success(episodes):
        var episodesBySeason: [[Episode]] = []
        var seasonArray: [Episode] = []
        var currentSeason = 1
        for episode in episodes {
          guard let season = episode.season else { continue }
          if season == currentSeason {
            seasonArray.append(episode)
          } else {
            currentSeason = season
            episodesBySeason.append(seasonArray)
            seasonArray = []
          }
        }
        if !seasonArray.isEmpty { episodesBySeason.append(seasonArray) }
        self?.movie.seasons = episodesBySeason
      case let .failure(error):
        if error == .serverError {
          self?.presentAlert(title: "Lo sentimos", message: "Algo salio mal", completion: { (_) in
            self?.getShowCastAndEpisodes()
          })
        }
      }
      group.leave()
    }

    group.notify(queue: .main) {
      self.mainLoader.isHidden = true
      self.segmentControl.isUserInteractionEnabled = true
      self.updateView()
    }
  }


  @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
    updateView()
  }
}

extension MovieDetailController: EpisodesControllerDelegate {
  func userTappedOnEpisode(episode: Episode) {
    let episodeDetailModalController = EpisodeDetailModal(nibName: String(describing: EpisodeDetailModal.self), bundle: nil)
    episodeDetailModalController.modalPresentationStyle = .overCurrentContext
    episodeDetailModalController.modalTransitionStyle = .crossDissolve
    episodeDetailModalController.episode = episode
    present(episodeDetailModalController, animated: true, completion: nil)
  }
}

extension MovieDetailController: InternetConection {}
