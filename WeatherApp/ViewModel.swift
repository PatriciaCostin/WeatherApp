//
//  ViewModel.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import CoreLocation
import Foundation

@MainActor
class ViewModel{
    
    private let currentWeather = WeatherService()
    var currentWeatherModel: Observable<CurrentWeatherModel?> = Observable(nil)
    
    func getWeatherForUserLocation() async throws {
        let locationResult = await LocationService.shared.getLocation()
        
        switch locationResult {
        case .authorized(let cLLocation):
            let lat = String(cLLocation.coordinate.latitude)
            let lon = String(cLLocation.coordinate.longitude)
            let model = try await self.currentWeather.fetchCurrentWeatherService(lat: lat, lon: lon)
            currentWeatherModel.value = model
        case .userDenied:
            throw "User denied"
        case .osRestricted:
            throw "Restricted"
        case .failed(let error):
            throw "Failed \(error)"
        }
    }
}

extension String: Error {
}
