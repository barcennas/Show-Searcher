//
//  Protocols.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/27/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation
import UIKit

protocol InternetConection {
  func isUserConnectedToInternet(completion: ((UIAlertAction) -> Void)?) -> Bool
  func presentAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)?)
}

extension InternetConection where Self: UIViewController {
  func isUserConnectedToInternet(completion: ((UIAlertAction) -> Void)?) -> Bool {
    if Reachability.isConnectedToNetwork(){
      return true
    }else{
      presentAlert(title: "No internet", message: "It looks like you are not connected to internet.", completion: completion)
      return false
    }
  }


  func presentAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)?) {
    DispatchQueue.main.async {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let retryAction = UIAlertAction(title: "Retry", style: .default, handler: completion)
      alert.addAction(retryAction)
      self.present(alert, animated: true)
    }
  }
}

protocol LoadableViewController: class {
  static var storyboardFileName: String { get }
  static var storyboardID: String { get }
}

extension LoadableViewController {
  static var storyboardID: String {
    return String(describing: self)
  }
}

extension LoadableViewController where Self: UIViewController {
  static func instantiate() -> Self {
    let storyboard = Self.storyboardFileName
    guard let vc = UIStoryboard.instanceofViewController(with: storyboardID, from: storyboardFileName) as? Self else {
      fatalError("The viewController '\(self.storyboardID)' of '\(storyboard)' is not of class '\(self)'")
    }

    return vc
  }
}


extension UIStoryboard {

  class func instanceofViewController(with storyboardID: String, from storyboardFileName: String) -> UIViewController? {
    let storyboard = UIStoryboard(
      name: storyboardFileName,
      bundle: nil
    )

    return storyboard.instantiateViewController(withIdentifier: storyboardID)
  }
}
