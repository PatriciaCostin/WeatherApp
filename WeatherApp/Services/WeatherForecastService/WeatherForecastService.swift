//
//  WeatherForecastService.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import Foundation

class WeatherForecastService {
    
    func fetchWeatherForecast() async throws -> WeatherForecastModel {
        let networkManager = NetworkManager()
        
        guard let endpointURL = WeatherEndpoint.weatherForecast.endPoint else {
            throw NetworkError.badEndpoint
        }
        
        let wheatherData = try await networkManager.fetchWeatherData(endPoint: endpointURL)
        return wheatherData
    }
}
