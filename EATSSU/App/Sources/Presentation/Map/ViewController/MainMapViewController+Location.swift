//
//  MainMapViewController+Location.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import UIKit
import CoreLocation

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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            root.mapView.mapView.positionMode = .direction
            
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

// MARK: - UIGestureRecognizerDelegate

extension MainMapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
