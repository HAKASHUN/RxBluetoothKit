//
//  CBCentralManager+Rx.swift
//  RxBluetoothKit
//
//  Created by Shunsuke Hakamata on 2017/08/31.
//  Copyright © 2017年 Polidea. All rights reserved.
//

import CoreBluetooth
import RxSwift
import RxCocoa

/// Proxy Object for CBCentralManagerDelegate
class RxCBCentralManagerDelegateProxy: DelegateProxy, CBCentralManagerDelegate, DelegateProxyType {

  class func currentDelegateFor(object: AnyObject) -> AnyObject? {
    let locationManager: CBCentralManager = object as! CBCentralManager
    return locationManager.delegate
  }

  class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
    let locationManager: CBCentralManager = object as! CBCentralManager
    locationManager.delegate = delegate as? CBCentralManagerDelegate
  }

  internal func centralManagerDidUpdateState(central: CBCentralManager) {
    interceptedSelector(#selector(CBCentralManagerDelegate.centralManagerDidUpdateState(_:)), withArguments: [central])
  }
}

extension CBCentralManager {

  /**
   Reactive wrapper for `delegate`.

   For more information take a look at `DelegateProxyType` protocol documentation.
   */
  public var rx_delegate: DelegateProxy {
    return proxyForObject(RxCBCentralManagerDelegateProxy.self,self)
  }

  // MARK: Responding to CB Central Manager

  /**
   Reactive wrapper for `delegate` message.
   */
  public var rx_didUpdateState: Observable<BluetoothState> {
    return rx_delegate.observe(#selector(CBCentralManagerDelegate.centralManagerDidUpdateState(_:)))
      .map { a in
        guard let central = a[0] as? CBCentralManager, let bleState = BluetoothState(rawValue: central.state.rawValue) else {
          return BluetoothState.Unknown
        }
        return bleState
    }
  }
}
