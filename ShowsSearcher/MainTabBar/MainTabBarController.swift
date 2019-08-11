//
//  MainTabBarController.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/28/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupControllers()
  }

  func setup() {
    self.delegate = self
    self.tabBar.barTintColor = AppColors.mainColor
    self.tabBar.unselectedItemTintColor = AppColors.tabBarItemColor
    self.tabBar.tintColor = AppColors.tabBarItemColor
  }

  func setupControllers(){
    let searchShowsViewController = MoviesListViewController.instantiate()
    searchShowsViewController.currentModuel = .showSearch
    let favoritesShowsViewController = MoviesListViewController.instantiate()
    favoritesShowsViewController.currentModuel = .favoriteShows
    let searchPeopleViewController = UIViewController()

    searchShowsViewController.tabBarItem = UITabBarItem(title: "Shows", image: #imageLiteral(resourceName: "showSearch_normal"), selectedImage: #imageLiteral(resourceName: "showSearch_selected"))
    favoritesShowsViewController.tabBarItem = UITabBarItem(title: "Favorites", image: #imageLiteral(resourceName: "favoriteShow_normal"), selectedImage: #imageLiteral(resourceName: "favoriteShow_selected"))
    searchPeopleViewController.tabBarItem = UITabBarItem(title: "People", image: #imageLiteral(resourceName: "peopleSearch_normal"), selectedImage: #imageLiteral(resourceName: "peopleSearch_selected"))

    let controllers = [searchShowsViewController, favoritesShowsViewController, searchPeopleViewController]
    self.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
  }

}

extension MainTabBarController: UITabBarControllerDelegate {
  /*
    Implemented this way because when i refreshed the controller in viewWillAppear method the collectionView method CellForRowAtIndexPath didn't get called and the screen just appeared black (bug)
   */
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    if let navigation = viewController as? UINavigationController, let controller = navigation.viewControllers.first as? MoviesListViewController, controller.currentModuel == .favoriteShows {
      let favoritesShowsViewController = MoviesListViewController.instantiate()
      favoritesShowsViewController.currentModuel = .favoriteShows
      favoritesShowsViewController.tabBarItem = UITabBarItem(title: "Favorites", image: #imageLiteral(resourceName: "favoriteShow_normal"), selectedImage: #imageLiteral(resourceName: "favoriteShow_selected"))
      navigation.setViewControllers([favoritesShowsViewController], animated: false)
    }
  }
}
