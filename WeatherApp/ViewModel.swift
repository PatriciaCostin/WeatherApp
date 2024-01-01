//
//  ViewModel.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

class ViewModel {
    
    private let weatherForecastService = WeatherForecastService()
    
    func fetchWeatherForecast() async throws -> WeatherForecastModel {
        return try await weatherForecastService.fetchWeatherForecast()
    }
}
