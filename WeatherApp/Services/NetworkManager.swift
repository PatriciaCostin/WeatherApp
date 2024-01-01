//
//  NetworkManager.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import Foundation

class NetworkManager {
    
    func fetchWeatherData(endPoint: URL) async throws -> WeatherForecastModel {
        let (data, response) = try await URLSession.shared.data(from: endPoint)
        
        guard let httpResponse = response as? HTTPURLResponse, 
                httpResponse.statusCode == 200 else {
            throw NetworkError.badRequest
        }
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(WeatherForecastModel.self, from: data)
        return decodedData
    }
}