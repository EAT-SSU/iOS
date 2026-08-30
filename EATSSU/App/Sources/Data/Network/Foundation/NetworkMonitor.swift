//
//  NetworkMonitor.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 11/18/23.
//

import Foundation
import Network

/// 네트워크 상태를 모니터링하는 싱글턴 클래스입니다.
///
/// 이 클래스는 현재 네트워크 연결 상태 및 연결 유형(Wi-Fi, 셀룰러, 유선 이더넷 등)을 감지하고 추적할 수 있도록 합니다.
final class NetworkMonitor {
    /// `NetworkMonitor`의 공유 인스턴스
    ///
    /// 싱글턴 패턴을 적용하여 전역적으로 접근할 수 있습니다.
    static let shared = NetworkMonitor()

    /// 네트워크 상태 감지를 위한 글로벌 디스패치 큐
    private let queue = DispatchQueue.global()

    /// 네트워크 경로 감지 객체
    private let monitor: NWPathMonitor

    /// 현재 네트워크 연결 상태 (`true`: 연결됨, `false`: 연결되지 않음)
    public private(set) var isConnected: Bool = false

    /// 현재 네트워크 연결 유형
    public private(set) var connectionType: ConnectionType = .unknown

    /// 네트워크 연결 유형을 정의하는 열거형
    ///
    /// - `wifi`: Wi-Fi 네트워크에 연결된 경우
    /// - `cellular`: 셀룰러 네트워크에 연결된 경우
    /// - `ethernet`: 유선 이더넷 네트워크에 연결된 경우
    /// - `unknown`: 연결 유형을 판별할 수 없는 경우
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    /// `NetworkMonitor`의 인스턴스를 초기화합니다.
    ///
    /// 싱글턴 패턴을 사용하여 `private` 생성자로 외부에서 인스턴스를 생성할 수 없도록 설정합니다.
    private init() {
        monitor = NWPathMonitor()
    }

    /// 네트워크 모니터링을 시작합니다.
    ///
    /// 네트워크 상태가 변경될 때마다 `pathUpdateHandler`를 통해 연결 상태 및 유형을 업데이트합니다.
    public func startMonitoring() {
        print("startMonitoring 호출")
        // NWPathMonitor는 start() 시점에 현재 경로를 한 번 알려주고 이후엔 변화가 있을 때만 알려준다.
        // 핸들러를 start() 뒤에 달면 그 첫 콜백을 놓쳐 isConnected가 false에 갇힐 수 있으므로 반드시 먼저 설정한다.
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
        monitor.start(queue: queue)
    }

    /// 네트워크 모니터링을 중지합니다.
    ///
    /// 네트워크 감지를 중단하고, 추가적인 리소스 사용을 방지합니다.
    public func stopMonitoring() {
        print("stopMonitoring 호출")
        monitor.cancel()
    }

    /// 주어진 네트워크 경로(`NWPath`)를 분석하여 연결 유형을 설정합니다.
    ///
    /// - Parameter path: 네트워크 경로 객체
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
