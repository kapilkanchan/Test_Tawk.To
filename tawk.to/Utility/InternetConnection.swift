//
//  InternetConnection.swift
//  tawk.to
//
//  Created by Kapil Kanchan on 15/10/21.
//

import Foundation
//import SystemConfiguration
//
//public class Reachability {
//    static public func isConnectedToNetwork() -> Bool {
//        var zeroAddress = sockaddr_in()
//        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//
//        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//                SCNetworkReachabilityCreateWithAddress(nil, $0)
//            }
//        }) else {
//            return false
//        }
//
//        var flags: SCNetworkReachabilityFlags = []
//        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
//            return false
//        }
//        if flags.isEmpty {
//            return false
//        }
//
//        let isReachable = flags.contains(.reachable)
//        let needsConnection = flags.contains(.connectionRequired)
//
//        return (isReachable && !needsConnection)
//    }
//}


import Network

protocol NetworkCheckObserver: AnyObject {
    func statusDidChange(status: NWPath.Status)
}

class NetworkCheck {

    struct NetworkChangeObservation {
        weak var observer: NetworkCheckObserver?
    }

    private var monitor = NWPathMonitor()
    private static let _sharedInstance = NetworkCheck()
    private var observations = [ObjectIdentifier: NetworkChangeObservation]()
    var currentStatus: NWPath.Status {
        get {
            return monitor.currentPath.status
        }
    }

    class func sharedInstance() -> NetworkCheck {
        return _sharedInstance
    }

    private init() {
        monitor.pathUpdateHandler = { [unowned self] path in
            for (id, observations) in self.observations {

                //If any observer is nil, remove it from the list of observers
                guard let observer = observations.observer else {
                    self.observations.removeValue(forKey: id)
                    continue
                }

                DispatchQueue.main.async(execute: {
                    observer.statusDidChange(status: path.status)
                })
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    func addObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = NetworkChangeObservation(observer: observer)
    }

    func removeObserver(observer: NetworkCheckObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }

}
