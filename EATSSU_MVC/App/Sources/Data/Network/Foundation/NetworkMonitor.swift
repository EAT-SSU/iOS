//
//  NetworkMonitor.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/18/23.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown

    /// 연결타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor = NWPathMonitor()
    }

    public func startMonitoring() {
        print("startMonitoring 호출")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            print("path :\(path)")

            self?.isConnected = path.status == .satisfied
            self?.getConenctionType(path)

            if self?.isConnected == true {
                print("연결 성공")
            } else {
                print("연결 실패")
            }
        }
    }

    public func stopMonitoring() {
        print("stopMonitoring 호출")
        monitor.cancel()
    }

    private func getConenctionType(_ path: NWPath) {
        print("getConenctionType 호출")
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("wifi에 연결")

        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("cellular에 연결")

        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("wiredEthernet에 연결")

        } else {
            connectionType = .unknown
            print("unknown ..")
        }
    }
}
