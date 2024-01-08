//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Patricia Costin on 14.01.2024.
//

import Foundation

protocol WeatherService {
    func fetchCurrentWeatherService(lat: String, lon: String) async throws -> CurrentWeatherModel
    func fetchWeatherForecast(lat: String, lon: String) async throws -> WeatherForecastModel
}
