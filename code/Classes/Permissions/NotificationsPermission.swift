//
//  ArekNotifications.swift
//  arek
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
import UserNotifications

open class NotificationsPermission: BasePermission, PermissionProtocol {
  open var identifier: String = "NotificationsPermission"

  public init() {
    super.init(identifier: self.identifier)
  }

  public override init(configuration: ArekConfiguration? = nil, initialPopupData: PopupAlertData? = nil, reEnablePopupData: PopupAlertData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }

  open func status(completion: @escaping ArekPermissionResponse) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .notDetermined:
        return completion(.notDetermined)
      case .denied:
        return completion(.denied)
      case .authorized:
        return completion(.authorized)
      case .provisional:
        return completion(.provisional)
      }
    }
  }

  open func askForPermission(completion: @escaping ArekPermissionResponse) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print("[🚨 Arek 🚨] Push notifications permission not determined 🤔, error: \(error)")
        return completion(.notDetermined)
      }
      if granted {
        self.registerForRemoteNotifications()

        print("[🚨 Arek 🚨] Push notifications permission authorized by user ✅")
        return completion(.authorized)
      }
      print("[🚨 Arek 🚨] Push notifications permission denied by user ⛔️")
      return completion(.denied)
    }
  }

  fileprivate func registerForRemoteNotifications() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
}
