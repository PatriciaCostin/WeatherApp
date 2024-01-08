//
//  WeatherServiceMock.swift
//  WeatherApp
//
//  Created by Patricia Costin on 14.01.2024.
//

import Foundation

final class WeatherServiceMock: WeatherService {
    func fetchCurrentWeatherService(lat: String, lon: String) async throws -> CurrentWeatherModel {
        throw NetworkError.badRequest
    }
    
    func fetchWeatherForecast(lat: String, lon: String) async throws -> WeatherForecastModel {
        if let forecastModelURL = Bundle.main.url(forResource: "ModelJSON", withExtension: "json") {
            if let forecastModel = try String(contentsOf: forecastModelURL).data(using: .utf8) {
                let decodedModel = try JSONDecoder().decode(WeatherForecastModel.self, from: forecastModel)
                return decodedModel
            }
        }
        throw NetworkError.badRequest
    }
}
