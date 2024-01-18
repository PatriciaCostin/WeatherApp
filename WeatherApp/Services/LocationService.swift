import CoreLocation

/// `LocationService` encapsulates CoreLocation's `CLLocationManager` to provide
/// simplified methods for requesting and retrieving a user's location.
/// Uses a singleton pattern and is thus accessible via `LocationService.shared`.
@MainActor
public class LocationService: NSObject {
    public enum LocationResult {
        case authorized(CLLocation)
        case userDenied
        case osRestricted
        case failed(Error)
    }

    public static let shared = LocationService()

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.delegate = self

        return manager
    }()

    private var completionClosures: [(LocationResult) -> Void] = []

    /// Use  to request for location permissions(if previous not requested) and for current user's location.
    /// The passed closure will be invoked when the location is retrieved, the user denies or other error occurs.
    public func getLocation(_ completion: @escaping ((LocationResult) -> Void)) {
        completionClosures.append(completion)

        switch locationManager.authorizationStatus {
        case .notDetermined:
            return locationManager.requestWhenInUseAuthorization()
        case .restricted:
            return complete(with: .osRestricted)
        case .denied:
            return complete(with: .userDenied)
        case .authorized, .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    public func getLocation() async -> LocationResult {
        return await withCheckedContinuation { continuation in
            LocationService.shared.getLocation { location in
                continuation.resume(returning: location)
            }
        }
    }

    private func complete(with result: LocationResult) {
        completionClosures.forEach { $0(result) }
        completionClosures.removeAll()
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        complete(with: .authorized(location))
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError, error.code == .denied  else {
            return complete(with: .failed(error))
        }

        complete(with: .userDenied)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted:
            complete(with: .osRestricted)
        case .denied:
            complete(with: .userDenied)
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
}
