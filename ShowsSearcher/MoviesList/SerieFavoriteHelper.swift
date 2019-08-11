//
//  ShowFavoritesHelper.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/28/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import UIKit
import CoreData


class ShowFavoritesHelper {

  var managedContext: NSManagedObjectContext?

  init() {
      managedContext = nil
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        managedContext = appDelegate.persistentContainer.viewContext
      }
  }

  /*
   This function is used to save a show to core data
   paramenter: Movie object
   */
  func saveShowToFavorites(show: Movie, completion: @escaping (Bool) -> ()) {
    guard let managedContext = managedContext else {
      print("no managed context")
      return
    }
    guard let showEntity = NSEntityDescription.entity(forEntityName: "ShowDBO", in: managedContext) else { return }

    let showDBO = NSManagedObject(entity: showEntity, insertInto: managedContext)
    showDBO.setValue(show.id, forKey: "id")
    showDBO.setValue(show.title, forKey: "title")
    showDBO.setValue(show.imageURL, forKey: "imageURL")
    showDBO.setValue(show.rating, forKey: "rating")
    showDBO.setValue(show.runtime, forKey: "runtime")
    showDBO.setValue(show.genres, forKey: "genres")
    showDBO.setValue(show.status, forKey: "status")
    showDBO.setValue(show.network, forKey: "network")
    showDBO.setValue(show.premiered, forKey: "premiered")
    showDBO.setValue(show.officialSite, forKey: "officialSite")
    showDBO.setValue(show.time, forKey: "time")
    showDBO.setValue(show.days, forKey: "days")
    showDBO.setValue(show.synopsis, forKey: "synopsis")

    do {
      try managedContext.save()
      completion(true)
    } catch {
      print("Core data save failed: ", error.localizedDescription)
      completion(false)
    }
  }

  func checkIfShowIsFavorite(showId: Int) -> Bool {
    guard let managedContext = managedContext else { return false }
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShowDBO")
    fetchRequest.predicate = NSPredicate(format: "id in %@", [showId])
    do {
      let result = try managedContext.fetch(fetchRequest)
      return !result.isEmpty
    } catch {
      print("checkIfShowIsFavorite failed: ", error.localizedDescription)
      return false
    }
  }

  func getAllFavoriteShows() -> [Movie] {
    guard let managedContext = managedContext else { return [] }
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShowDBO")

    do {
      guard let result = try managedContext.fetch(fetchRequest) as? [ShowDBO] else { return [] }
      let series = result.map { Movie(showDBO: $0) }
      series.forEach { $0.isFavorite = true }
      return series
    } catch {
      print("getAllFavoriteShows failed: ", error.localizedDescription)
      return []
    }
  }

  func removeShowFromFavorites(showId: Int, completion: @escaping (Bool) -> ()) {
    guard let managedContext = managedContext else { return }

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShowDBO")
    fetchRequest.predicate = NSPredicate(format: "id in %@", [showId])

    do
    {
      let result = try managedContext.fetch(fetchRequest)
      guard let object = result.first, let objectToDelete = object as? NSManagedObject else { return }
      managedContext.delete(objectToDelete)
      try managedContext.save()
      print("show: \(showId) succesfully removed from favorites")
      completion(true)
    } catch {
      print("deleteShowFromFavorites failed: ", error.localizedDescription)
      completion(false)
    }
  }

}

