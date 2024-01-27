//
//  TemperatureViewSwiftUI.swift
//  WeatherApp
//
//  Created by Patricia Costin on 27.01.2024.
//

import SwiftUI

struct TemperatureViewSwiftUI: View {
    var temperature: Int
    var iconName: String
    var isDayTime: Bool
    var body: some View {
        VStack() {
            Group {
                Text("\(temperature)" + "\u{00B0}")
                    .fontWeight(.semibold)
                    .font(.system(size: FontSizes.subtitle))
                    .foregroundColor(
                        labelColor( isDayTime, iconName)
                    )
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                
                Image(systemName: iconName)
                    .aspectRatio(contentMode: .fit)
                    .modifier(SymbolModifier(iconName: iconName, isDayTime: isDayTime))
            }
        }
    }
    
    func labelColor(_ isDayTime: Bool, _ iconName: String) -> Color {
        let iconsForBlueLables = [WeatherIconsString.dayRain, WeatherIconsString.showerRain, WeatherIconsString.snow, WeatherIconsString.drizzle, WeatherIconsString.nightRain, WeatherIconsString.thunderstorm]
        let iconsForYellowLables = [WeatherIconsString.dayClearSky, WeatherIconsString.dayFewClouds]
        
        if iconsForBlueLables.contains(iconName) {
            return .rain
        } else if iconsForYellowLables.contains(iconName) {
            return .yellow
        } else {
            if isDayTime {
                return .day
            } else {
                return .night
            }
        }
    }
}

#Preview {
    TemperatureViewSwiftUI(
        temperature: 10,
        iconName: "cloud.fill",
        isDayTime: true
    )
}

struct SymbolModifier: ViewModifier {
    var iconName: String
    var isDayTime: Bool
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if isDayTime {
            if iconName == WeatherIconsString.dayFewClouds 
                || iconName == WeatherIconsString.daysmoke {
                content
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.day, .yellow, .rain)
                    
            } else if iconName == WeatherIconsString.dayClearSky {
                content
                    .foregroundColor(.yellow)
            } else if iconName == WeatherIconsString.dayRain
                        || iconName == WeatherIconsString.thunderstorm {
                content
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.day, .yellow, .rain)
            } else if iconName == WeatherIconsString.showerRain
                        || iconName == WeatherIconsString.drizzle {
                content
                .symbolRenderingMode(.palette)
                .foregroundStyle(.day, .rain)
            }
            else if iconName == WeatherIconsString.snow {
                content
                    .foregroundColor(.rain)
            } else {
                content
                    .foregroundColor(.day)
            }
            
        } else if !isDayTime {
            if iconName == WeatherIconsString.showerRain 
                || iconName == WeatherIconsString.drizzle {
                content
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.night, .day, .rain)
            } else if iconName == WeatherIconsString.thunderstorm {
                content
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.night, .yellow)
            } else if iconName == WeatherIconsString.nightRain {
                content
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.night, .day, .rain)
            } else if iconName == WeatherIconsString.snow {
                content
                    .foregroundColor(.rain)
            } else if iconName == WeatherIconsString.nightSmoke
                        || iconName == WeatherIconsString.nightFewClouds
                        || iconName == WeatherIconsString.nightClearSky {
                content
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.night)
            }
            else {
                content
                    .foregroundStyle(.night)
            }
        }
    }
}
