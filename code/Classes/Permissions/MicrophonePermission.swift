//
//  ArekMicrophone.swift
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

import AVFoundation
import Foundation

open class MicrophonePermission: BasePermission, PermissionProtocol {
  public var identifier: String = "MicrophonePermission"

  public init() {
    super.init(identifier: self.identifier)
  }

  public override init(configuration: ArekConfiguration? = nil, initialPopupData: PopupAlertData? = nil, reEnablePopupData: PopupAlertData? = nil) {
    super.init(configuration: configuration, initialPopupData: initialPopupData, reEnablePopupData: reEnablePopupData)
  }

  open func status(completion: @escaping ArekPermissionResponse) {
    switch AVAudioSession.sharedInstance().recordPermission() {
    case AVAudioSessionRecordPermission.denied:
      return completion(.denied)
    case AVAudioSessionRecordPermission.undetermined:
      return completion(.notDetermined)
    case AVAudioSessionRecordPermission.granted:
      return completion(.authorized)
    }
  }

  open func askForPermission(completion: @escaping ArekPermissionResponse) {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in
      if granted {
        print("[🚨 Arek 🚨] 🎤 permission authorized by user ✅")
        return completion(.authorized)
      }
      print("[🚨 Arek 🚨] 🎤 permission denied by user ⛔️")
      return completion(.denied)
    }
  }
}
