//
//  RectangularView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 30.01.2024.
//

import SwiftUI

struct ForecastElementView: View {
    var elementName: String
    var elementInfo: String?
    
    var body: some View {
        let (iconName, elementDescription) = determineIconNameAndElementDescription(elementName.lowercased(), elementInfo ?? "")
        HStack {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .modifier(IconModifier(iconName: iconName))
                
            VStack(alignment: .leading) {
                Text(elementName)
                    .font(.system(size: FontSizes.subtitle, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.8))
                Text(elementDescription)
                    .font(.system(size: FontSizes.forecastDescription, weight: .semibold))
                    .foregroundStyle(.forecastElement)
            }
        }
    }
    
    func determineIconNameAndElementDescription(_ elementName: String, _ elementInfo: String) -> (String, String) {
        var (iconName, elementDescription) = ("", "")
        if elementName == "humidity" {
            (iconName, elementDescription) = (IconName.humidity,(elementInfo + " %"))
        } else if elementName == "pressure" {
            (iconName, elementDescription) = (IconName.pressure,(elementInfo + " hPa"))
        } else if elementName == "wind speed" {
            (iconName, elementDescription) = (IconName.wind,(elementInfo + " m/s"))
        } else if elementName == "visibility" {
            (iconName, elementDescription) = (IconName.visibility,(elementInfo + " m"))
        } else if elementName == "cloudiness" {
            (iconName, elementDescription) = (IconName.cloud,(elementInfo + " %"))
        } else if elementName == "precipitation" {
            (iconName, elementDescription) = (IconName.drop,(elementInfo + " %"))
        }
        return (iconName, elementDescription)
    }
}

struct IconModifier: ViewModifier {
    var iconName: String
    
    @ViewBuilder
    func body(content: Content) -> some View {
        
        if iconName == IconName.humidity {
            content
                .symbolRenderingMode(.palette)
                .foregroundStyle(.night.opacity(0.8), .rain)
            
        } else if iconName == IconName.pressure
                    || iconName == IconName.wind
                    || iconName == IconName.cloud {
            content
                .foregroundColor(.night.opacity(0.8))
        } else if iconName == IconName.visibility {
            content
                .symbolRenderingMode(.palette)
                .foregroundStyle(.night.opacity(0.8), .yellow)
        } else if iconName == IconName.drop {
            content
                .foregroundStyle(.rain)
        }
    }
}

struct IconName {
    static let humidity = "humidity.fill"
    static let pressure = "barometer"
    static let wind = "wind"
    static let visibility = "sun.haze.fill"
    static let cloud = "cloud.fill"
    static let drop = "drop.fill"
}
