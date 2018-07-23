//
//  Arek.swift
//  Arek
//
//  Copyright (c) 2016 Ennio Masi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

public typealias ArekPermissionResponse = (ArekPermissionStatus) -> Void

public protocol PermissionProtocol: class {
  var identifier: String { get }
    /**
     This is the key method to know if a permission has been authorized or denied.

     Parameter completion: this closure is invoked with the current permission status (ArekPermissionStatus)
     */
  func status(completion: @escaping ArekPermissionResponse)

    /**
     This is the key method to manage the request for a permission.

     The behaviour is based on the ArekConfiguration set in the permission during the initialization phase.

     Parameter completion: this closure is invoked with the current permission status (ArekPermissionStatus)
     */
  func manage(completion: @escaping ArekPermissionResponse)
  func askForPermission(completion: @escaping ArekPermissionResponse)
}

/**
 ArekBasePermission is a root class and each permission inherit from it.

 Don't instantiate ArekBasePermission directly.
 */
open class BasePermission {
  var configuration: ArekConfiguration = ArekConfiguration(frequency: .OnceADay,
                                                           presentInitialPopup:
                                                             true,
                                                           presentReEnablePopup: true)
  var initialPopupData: PopupAlertData = PopupAlertData()
  var reEnablePopupData: PopupAlertData = PopupAlertData()

  public init(identifier: String) {
    let data = ArekLocalizationManager(permission: identifier)

    self.initialPopupData = PopupAlertData(title: data.initialTitle,
                                          message: data.initialMessage,
                                          allowButtonTitle: data.allowButtonTitle,
                                          denyButtonTitle: data.denyButtonTitle)
    self.reEnablePopupData = PopupAlertData(title: data.reEnableTitle,
                                           message: data.reEnableMessage,
                                           allowButtonTitle: data.allowButtonTitle,
                                           denyButtonTitle: data.denyButtonTitle)
  }

    /**
     Base init shared among each permission provided by Arek

     - Parameters:
         - configuration: ArekConfiguration object used to define the behaviour of the pre-iOS popup and the re-enable permission popup
         - initialPopupData: title and message related to pre-iOS popup
         - reEnablePopupData: title and message related to re-enable permission popup
     */
  public init(configuration: ArekConfiguration? = nil, initialPopupData: PopupAlertData? = nil, reEnablePopupData: PopupAlertData? = nil) {
    self.configuration = configuration ?? self.configuration
    self.initialPopupData = initialPopupData ?? self.initialPopupData
    self.reEnablePopupData = reEnablePopupData ?? self.reEnablePopupData
  }

  private func manageInitialPopup(completion: @escaping ArekPermissionResponse) {
    if self.configuration.presentInitialPopup {
      self.presentInitialPopup(title: self.initialPopupData.title, message: self.initialPopupData.message, allowButtonTitle: self.initialPopupData.allowButtonTitle, denyButtonTitle: self.initialPopupData.denyButtonTitle, completion: completion)
    } else {
      (self as? PermissionProtocol)?.askForPermission(completion: completion)
    }
  }

  private func presentInitialPopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String, completion: @escaping ArekPermissionResponse) {
    self.presentInitialNativePopup(title: title, message: message, allowButtonTitle: allowButtonTitle, denyButtonTitle: denyButtonTitle, completion: completion)
  }

  private func presentInitialNativePopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String, completion: @escaping ArekPermissionResponse) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let allow = UIAlertAction(title: allowButtonTitle, style: .default) { _ in
      (self as? PermissionProtocol)?.askForPermission(completion: completion)
      alert.dismiss(animated: true, completion: nil)
    }

    let deny = UIAlertAction(title: denyButtonTitle, style: .default) { _ in
      completion(.denied)
      alert.dismiss(animated: true, completion: nil)
    }

    alert.addAction(deny)
    alert.addAction(allow)

    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }

      DispatchQueue.main.async {
        topController.present(alert, animated: true, completion: nil)
      }
    }
  }

  private func presentReEnablePopup() {
    guard let permission = self as? PermissionProtocol else { return }

    if self.configuration.canPresentReEnablePopup(permission: permission) {
      self.presentReEnablePopup(title: self.reEnablePopupData.title, message: self.reEnablePopupData.message, allowButtonTitle: self.reEnablePopupData.allowButtonTitle, denyButtonTitle: self.reEnablePopupData.denyButtonTitle)
    } else {
      print("[🚨 Arek 🚨] for \(self) present re-enable not allowed")
    }
  }

  private func presentReEnablePopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String) {
    self.presentReEnableNativePopup(title: title, message: message, allowButtonTitle: allowButtonTitle, denyButtonTitle: denyButtonTitle)
  }

  private func presentReEnableNativePopup(title: String, message: String, allowButtonTitle: String, denyButtonTitle: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

    let allow = UIAlertAction(title: allowButtonTitle, style: .default) { _ in
      alert.dismiss(animated: true, completion: nil)

      guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    let deny = UIAlertAction(title: denyButtonTitle, style: .cancel) { _ in
      alert.dismiss(animated: true, completion: nil)
    }

    alert.addAction(deny)
    alert.addAction(allow)

    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }

      topController.present(alert, animated: true, completion: nil)
    }
  }

  open func manage(completion: @escaping ArekPermissionResponse) {
    (self as? PermissionProtocol)?.status { status in
      self.managePermission(status: status, completion: completion)
    }
  }

  internal func managePermission(status: ArekPermissionStatus, completion: @escaping ArekPermissionResponse) {
    switch status {
    case .notDetermined:
      self.manageInitialPopup(completion: completion)
      break
    case .denied:
      self.presentReEnablePopup()
      return completion(.denied)
    case .authorized:
      return completion(.authorized)
    case .provisional:
      return completion(.provisional)
    case .notAvailable:
      break
    }
  }
}
