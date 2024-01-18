//
//  NetworkManager.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import Foundation

class NetworkManager {
    
    func fetchWeatherData<T: Decodable>(endPoint: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: endPoint)
        
        guard let httpResponse = response as? HTTPURLResponse, 
                httpResponse.statusCode == 200 else {
            throw NetworkError.badRequest
        }
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(T.self, from: data)
        return decodedData
    }
}
