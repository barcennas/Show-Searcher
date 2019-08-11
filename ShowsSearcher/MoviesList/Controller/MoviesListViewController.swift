//
//  MoviesListViewController.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/26/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class MoviesListViewController: UIViewController, LoadableViewController {

  static var storyboardFileName = "MoviesList"

  // MARK: Outlets
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var mainLoader: UIStackView!
  @IBOutlet weak var moviesCollectionView: UICollectionView!

  // MARK: Global Variables
  var moviesList: [Movie] = []
  var moviesListSearch: [Movie] = []
  lazy var sessionProvider = URLSessionProvider()
  lazy var showFavoritesHelper = ShowFavoritesHelper()
  let imageCache = NSCache<NSString, UIImage>()
  var isWaiting = false
  var isOnSearch = false
  var dispatchWorkItem: DispatchWorkItem?
  var currentModuel: AppModules = .showSearch

  typealias constants = MoviesListConstants

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupNavigationBar()
    setupSearchBar()
    setupMoviesCollectionView()
    getMovies()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if currentModuel == .showSearch {
      moviesList.forEach { $0.isFavorite = self.showFavoritesHelper.checkIfShowIsFavorite(showId: $0.id) }
      moviesListSearch.forEach { $0.isFavorite = self.showFavoritesHelper.checkIfShowIsFavorite(showId: $0.id) }
      moviesCollectionView.reloadData()
    }
  }

  func setupView() {
    self.view.backgroundColor = AppColors.mainColor
  }

  func setupNavigationBar() {
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    let title = currentModuel == .showSearch ? "Shows" : "Favorite Shows"
    self.navigationController?.setup(title: title)
  }

  func setupSearchBar() {
    if currentModuel == .favoriteShows {
      searchBar.isHidden = true
      return
    }
    searchBar.backgroundColor = AppColors.mainColor
    searchBar.tintColor = AppColors.mainColor
    searchBar.barTintColor = AppColors.mainColor
    searchBar.placeholder = "Search a serie"
    searchBar.delegate = self
      
  }

  func setupMoviesCollectionView() {
    moviesCollectionView.delegate = self
    moviesCollectionView.dataSource = self
    moviesCollectionView.register(MovieCell.nib(), forCellWithReuseIdentifier: MovieCell.reuseIdentifier())
    moviesCollectionView.backgroundColor = .clear
  }

  func hideLoader() {
    DispatchQueue.main.async {
      self.mainLoader.isHidden = true
    }
  }

  func updateWithFavoriteShows(shows: [Movie]) -> [Movie] {
    shows.forEach { $0.isFavorite = showFavoritesHelper.checkIfShowIsFavorite(showId: $0.id) }
    return shows
  }

  func getMovies() {
    if currentModuel == .showSearch {
      getShowsServer()
    } else {
      getFavoriteShowsLocal()
    }
  }

  func getFavoriteShowsLocal() {
    hideLoader()
    moviesList = showFavoritesHelper.getAllFavoriteShows()
    moviesCollectionView.reloadData()
  }

  func getShowsServer() {
    if isUserConnectedToInternet(completion: { (_) in
      self.getMovies()
    }) {
      let page = Int(ceil(Double(moviesList.count)/constants.moviesPerPage))
      sessionProvider.request(type: [Movie].self, service: MoviesService.allShows(page: page)) { [weak self] response in
        switch response {
        case let .success(movies):
          self?.hideLoader()
          self?.isWaiting = false
          DispatchQueue.main.async {
            movies.forEach { $0.isFavorite = self?.showFavoritesHelper.checkIfShowIsFavorite(showId: $0.id) ?? false }
            self?.moviesList.append(contentsOf: movies)
            self?.moviesCollectionView.reloadData()
          }
        case let .failure(error):
          if error == .serverError {
            self?.presentAlert(title: "Lo sentimos", message: "Algo salio mal", completion: { (_) in
              self?.getMovies()
            })
          }
        }
      }
    }
  }

  func getMoviesByQuery(inputText: String) {

    if let worker = dispatchWorkItem { worker.cancel() }

    dispatchWorkItem = DispatchWorkItem {
      if self.isUserConnectedToInternet(completion: nil) {
        self.sessionProvider.request(type: [MovieSearch].self, service: MoviesService.showQuery(searchInput: inputText)) { [weak self] response in
          switch response {
          case let .success(movies):
            let convertedMovies = movies.map { try? JSONDecoder().decode(Movie.self, from: $0.showData) }.compactMap { $0 }
            DispatchQueue.main.async {
              convertedMovies.forEach { $0.isFavorite = self?.showFavoritesHelper.checkIfShowIsFavorite(showId: $0.id) ?? false }
              self?.moviesListSearch = convertedMovies
              self?.moviesCollectionView.reloadData()
            }
          case let .failure(error):
            print("getMoviesByQuery Error: ", error)
          }
        }
      }
    }

    guard let worker = dispatchWorkItem else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: worker)


  }

  func presentMovieDetailWithMovie(movie: Movie) {
    let movieDetailController = MovieDetailController.instantiate()
    movieDetailController.movie = movie
    movieDetailController.imageCache = imageCache
    self.navigationController?.pushViewController(movieDetailController, animated: true)
  }


}

extension MoviesListViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let movieModel = isOnSearch ? moviesListSearch[indexPath.row] : moviesList[indexPath.row]
    presentMovieDetailWithMovie(movie: movieModel)
  }

  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if !isOnSearch && indexPath.row == moviesList.count - 1 && !isWaiting {
      isWaiting = true
      getMovies()
    }
  }
}

extension MoviesListViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return isOnSearch ? moviesListSearch.count : moviesList.count
  }


  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let movieModel = isOnSearch ? moviesListSearch[indexPath.row] : moviesList[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.reuseIdentifier(), for: indexPath)
    (cell as? MovieCell)?.configure(show: movieModel, cache: imageCache)
    (cell as? MovieCell)?.delegate = self
    (cell as? MovieCell)?.index = indexPath.row
    return cell
  }
}

extension MoviesListViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let movieWidth = collectionView.bounds.width/constants.moviesPerRow - constants.spaceBetweenMovies
    let movieHeight = movieWidth * constants.movieHeightProportion
    return CGSize(width: movieWidth, height: movieHeight)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets.zero
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return constants.spaceBetweenRows
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return constants.spaceBetweenMovies
  }

}

extension MoviesListViewController: UISearchBarDelegate {

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    isOnSearch = !searchText.isEmpty
    if isOnSearch {
      getMoviesByQuery(inputText: searchText)
    } else {
      moviesCollectionView.reloadData()
    }
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    self.view.endEditing(true)
  }
}

extension MoviesListViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    self.view.endEditing(true)
  }
}

extension MoviesListViewController: InternetConection {}

extension MoviesListViewController: MovieCellDelegate {

  func userRemovedShowFromFavorite(position: Int) {
    if currentModuel == .favoriteShows {

      moviesList.remove(at: position)
      let indexPath = IndexPath(row: position, section: 0)
      moviesCollectionView.performBatchUpdates({
        moviesCollectionView.deleteItems(at: [indexPath])
      }, completion: {
        (finished: Bool) in
        self.moviesCollectionView.reloadItems(at: self.moviesCollectionView.indexPathsForVisibleItems)
      })
    }
  }
}
