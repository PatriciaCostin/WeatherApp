//
//  ActivityIndicator.swift
//  WeatherApp
//
//  Created by Patricia Costin on 07.01.2024.
//

import UIKit

extension UIViewController {
    static var dispatchWorkItem: DispatchWorkItem!
    static var dimView: UIView!
    
    func showSpinner() {
        
        if let dispatchWorkItem = Self.dispatchWorkItem {
            dispatchWorkItem.cancel()
        }
        
        Self.dimView = UIView()
        Self.dimView.alpha = 0
        Self.dimView.backgroundColor = .black.withAlphaComponent(0.5)
        self.view.addSubview(Self.dimView)
        Self.dimView.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        Self.dimView.addSubview(spinner)
        spinner.startAnimating()
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: Self.dimView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: Self.dimView.centerYAnchor),
            Self.dimView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            Self.dimView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            Self.dimView.topAnchor.constraint(equalTo: self.view.topAnchor),
            Self.dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        Self.dispatchWorkItem = DispatchWorkItem {
            UIView.animate(withDuration: 0.2) {
                Self.dimView.alpha = 1
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: Self.dispatchWorkItem)
    }
    
    func hideSpinner() {
        DispatchQueue.main.async {
            if let dispatchWorkItem = Self.dispatchWorkItem {
                dispatchWorkItem.cancel()
                Self.dimView.isHidden = true
            }
        }
    }
}
