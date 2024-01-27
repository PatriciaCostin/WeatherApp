//
//  WeeklyForecastTitleView.swift
//  WeatherApp
//
//  Created by Patricia Costin on 29.01.2024.
//

import SwiftUI

struct WeeklyForecastTitleView: View {
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.subtitle)
                .frame(width: 25, height: 25)
            Text("DAILY FORECAST")
                .foregroundColor(.subtitle)
                .fontWeight(.semibold)
                .font(.system(size: FontSizes.subtitle))
        }
    }
}

#Preview {
    WeeklyForecastTitleView()
}
