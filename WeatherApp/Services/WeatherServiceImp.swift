//
//  WeatherServiceImp.swift
//  WeatherApp
//
//  Created by Patricia Costin on 01.01.2024.
//

import Foundation

final class WeatherServiceImp: WeatherService {
    private let networkManager = NetworkManager()
    private let accessKey = "bc9b74b7ba052835ba0b0246367dc554"
    private let baseURL = "https://api.openweathermap.org"
    
    func fetchCurrentWeatherService(lat: String, lon: String) async throws -> CurrentWeatherModel {
        let urlString = "\(baseURL)/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(accessKey)"
        let url = URL(string: urlString)
        
        guard let url else {
            throw NetworkError.badURL
        }
        
        let currentWeather: CurrentWeatherModel = try await networkManager.fetchWeatherData(endPoint: url)
        return currentWeather
    }
    
    func fetchWeatherForecast(lat: String, lon: String) async throws -> WeatherForecastModel {
        let urlString = "\(baseURL)/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(accessKey)"
        let url = URL(string: urlString)
        
        guard let url else {
            throw NetworkError.badURL
        }
        
        let wheatherData: WeatherForecastModel = try await networkManager.fetchWeatherData(endPoint: url)
        return wheatherData
    }
}
