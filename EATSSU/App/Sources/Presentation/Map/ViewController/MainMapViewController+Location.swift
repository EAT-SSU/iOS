//
//  MainMapViewController+Location.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import CoreLocation

import NMapsMap

// MARK: - Location Management

extension MainMapViewController: CLLocationManagerDelegate {
    
    func setupLocationButtonObserver() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let locationButton = self.findLocationButton(in: self.root.mapView) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.locationButtonTapped))
                tapGesture.delegate = self
                locationButton.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    @objc func locationButtonTapped() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            hasRequestedLocationPermission = true
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            showLocationPermissionAlert()
            
        case .authorizedWhenInUse, .authorizedAlways:
            break
            
        @unknown default:
            break
        }
    }
    
    func findLocationButton(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if String(describing: type(of: subview)).contains("LocationButton") {
                return subview
            }
            if let found = findLocationButton(in: subview) {
                return found
            }
        }
        return nil
    }
    
    /// 착한가격 지도에서 현위치로 카메라 이동 (진입·탭 전환 공통)
    /// 권한 미결정이면 요청하고, 거부 상태면 숭실대 상권으로 이동한다 (설정 유도 알럿은 띄우지 않음)
    func moveToCurrentLocationIfAvailable(animated: Bool = false) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            root.mapView.mapView.positionMode = .direction
            if let location = locationManager.location {
                moveCamera(to: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), animated: animated)
            } else {
                wantsInitialCurrentLocation = true
                locationManager.requestLocation()
            }
        case .notDetermined:
            wantsInitialCurrentLocation = true
            locationManager.requestWhenInUseAuthorization()
        default:
            setInitialCameraPosition(animated: animated)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 착한가격 지도를 보고 있을 때만 이동 (다른 탭으로 간 뒤 늦게 온 응답이 카메라를 덮지 않게)
        guard wantsInitialCurrentLocation, currentTab == .goodPrice, let location = locations.last else { return }
        wantsInitialCurrentLocation = false
        moveCamera(to: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), animated: true)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            root.mapView.mapView.positionMode = .direction
            if wantsInitialCurrentLocation {
                locationManager.requestLocation()
            }
            
        case .denied, .restricted:
            if hasRequestedLocationPermission {
                showLocationPermissionAlert()
                hasRequestedLocationPermission = false
            }
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
    func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: TextLiteral.Map.needLocationAuth,
            message: TextLiteral.Map.locationAuthDescription,
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: TextLiteral.Common.moveToSetting, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: TextLiteral.Common.cancel, style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 진입 시 현위치 조회 실패는 조용히 포기하고 기본 위치(숭실대)를 유지한다
        wantsInitialCurrentLocation = false
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                if hasRequestedLocationPermission {
                    showLocationPermissionAlert()
                    hasRequestedLocationPermission = false
                }
            default:
                break
            }
        }
    }
}

// MARK: - NMFMapViewCameraDelegate

extension MainMapViewController: NMFMapViewCameraDelegate {
    /// 사용자가 지도를 직접 움직이면 진입 시 걸어둔 현위치 이동을 취소한다 (늦은 응답이 조작을 덮지 않게)
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            wantsInitialCurrentLocation = false
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MainMapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
