//
//  Extensions.swift
//  ShowsSearcher
//
//  Created by Abraham Barcenas Morales on 7/26/19.
//  Copyright © 2019 Abraham Barcenas Morales. All rights reserved.
//

import Foundation
import UIKit

// MARK: UINavigationController
extension UINavigationController {

  public func setup(title: String) {
    self.navigationBar.barStyle = .black
    self.navigationBar.tintColor = .white
    self.navigationBar.backgroundColor = .black
    self.navigationBar.isTranslucent = false
    self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    self.navigationBar.topItem?.title = title
  }
}

// MARK: UICollectionViewCell
extension UICollectionViewCell {

  class func nib() -> UINib {
    return UINib(nibName: String(describing: self), bundle: Bundle(for: classForCoder()))
  }

  class func reuseIdentifier() -> String {
    return String(describing: self)
  }
}

extension UITableViewCell {

  class func nib() -> UINib {
    return UINib(nibName: String(describing: self), bundle: Bundle(for: classForCoder()))
  }

  class func reuseIdentifier() -> String {
    return String(describing: self)
  }
}


extension UIViewController {

  class func nibInstatiate() -> UIViewController {
    return UIViewController(nibName: String(describing: self), bundle: nil)
  }

  class func reuseIdentifier() -> String {
    return String(describing: self)
  }
}

// MARK: URLComponents
extension URLComponents {

  init(service: ServiceProtocol) {
    let url = service.baseURL.appendingPathComponent(service.path)
    self.init(url: url, resolvingAgainstBaseURL: false)!

    guard case let .requestParameters(parameters) = service.task, service.parametersEncoding == .url else { return }

    queryItems = parameters.map { key, value in
      return URLQueryItem(name: key, value: String(describing: value))
    }
  }
}

// MARK: URLRequest
extension URLRequest {

  init(service: ServiceProtocol) {
    let urlComponents = URLComponents(service: service)

    self.init(url: urlComponents.url!)

    httpMethod = service.method.rawValue
    service.headers?.forEach { key, value in
      addValue(value, forHTTPHeaderField: key)
    }

    guard case let .requestParameters(parameters) = service.task, service.parametersEncoding == .json else { return }
    httpBody = try? JSONSerialization.data(withJSONObject: parameters)
  }
}

// MARK: URLRequest
extension String {
  func dateStringFormatt(format: String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    guard let date = formatter.date(from: self) else { return self }

    formatter.dateFormat = format
    return formatter.string(from: date)
  }

  func removeHTMLTags() -> String {
    return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
  }
}

/*extension UITabBar {
  override open func sizeThatFits(_ size: CGSize) -> CGSize {
    super.sizeThatFits(size)
    var sizeThatFits = super.sizeThatFits(size)
    sizeThatFits.height = 70
    return sizeThatFits
  }
}*/
