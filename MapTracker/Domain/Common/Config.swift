//
//  Config.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 18/09/2024.
//

import Foundation

struct Config {
  // This is private because the use of 'appConfiguration' is preferred.
  private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  
  // This can be used to add debug statements.
  static var isDebug: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }

  static var appConfiguration: AppConfiguration {
    if isDebug {
      return .debug
    } else if isTestFlight {
      return .testFlight
    } else {
      return .appStore
    }
  }
}
