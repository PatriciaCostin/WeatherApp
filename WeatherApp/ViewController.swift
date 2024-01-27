//
//  ViewController.swift
//  WheatherApp
//
//  Created by Patricia Costin on 29.12.2023.
//

import UIKit
import SwiftUI

@MainActor
final class ViewController: UIViewController {
    
    //MARK: - UI Components
    
    private let stackView = UIStackView()
    private let hourlyForecastView = HourlyForecastView()
    private let hourlyForecastScrollView: UIScrollView = {
        let hourlyForecastScrollView = UIScrollView()
        hourlyForecastScrollView.isScrollEnabled = true
        hourlyForecastScrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        hourlyForecastScrollView.showsHorizontalScrollIndicator = true
        hourlyForecastScrollView.showsVerticalScrollIndicator = false
        hourlyForecastScrollView.layer.cornerRadius = 20
        hourlyForecastScrollView.layer.borderWidth  = 1
        return hourlyForecastScrollView
    }()
    private let hourlyForecastTitle = HourlyForecastTitleView()
    private let hourlyForecastContainer = UIView()
    private let weeklyForecastViewController = UIHostingController(rootView: WeeklyForecastView())
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    private var heroView: HeroView = {
        let heroView = HeroView()
        heroView.layer.borderWidth = 1
        heroView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        heroView.layer.cornerRadius = 20
        return heroView
    }()
    
    private lazy var linearGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.locations = [0, 0.4, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.cornerRadius = 20
        return gradient
    }()
    
    // MARK: - Private properties
    
    private let viewModel = ViewModel()
    private var isViewLaidOut = false
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewSetup()
        stackViewSetup()
        heroViewSetup()
        hourlyForecastViewSetup()
        loadWeatherForecast()
        setupBindings()
        weeklyForecastViewSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isViewLaidOut {
            linearGradient.frame = view.bounds
            isViewLaidOut = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.linearGradient.colors = [
            UIColor.deepBlue.cgColor,
            UIColor.lightBlue.cgColor,
            UIColor.powderyPurple.cgColor
        ]
        self.hourlyForecastScrollView.layer.borderColor = UIColor.secondaryViewsBorder.cgColor
        self.hourlyForecastScrollView.layer.backgroundColor = UIColor.secondaryViewBackground.cgColor
    }
    
    // MARK: - Helpers
    
    private func setupBindings() {
        viewModel.currentWeatherModel.bind(fire: true, { [weak self] currentWeatherModel in
            guard let currentWeatherModel else { return }
            self?.heroView.update(with: currentWeatherModel)
        })
        
        viewModel.hourlyForecastModel.bind(fire: true) { [weak self] hourlyForecastModel in
            guard let hourlyForecastModel else { return }
            self?.hourlyForecastView.update(with: hourlyForecastModel)
        }
    }
    
    private func scrollViewSetup() {
        linearGradient.frame = view.frame
        view.layer.addSublayer(linearGradient)
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func stackViewSetup() {
        scrollView.addSubview(stackView)
        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.safeAreaInsets.top),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -view.safeAreaInsets.top),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    private func heroViewSetup() {
        stackView.addArrangedSubview(heroView)
        
        heroView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            heroView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    func hourlyForecastViewSetup() {
        stackView.addArrangedSubview(hourlyForecastContainer)
        hourlyForecastContainer.addSubview(hourlyForecastScrollView)
        hourlyForecastScrollView.addSubview(hourlyForecastView)
        hourlyForecastScrollView.addSubview(hourlyForecastTitle)
        
        hourlyForecastScrollView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastView.translatesAutoresizingMaskIntoConstraints = false
        hourlyForecastTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hourlyForecastContainer.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hourlyForecastContainer.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            hourlyForecastContainer.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            hourlyForecastContainer.heightAnchor.constraint(equalToConstant: 210),
            
            hourlyForecastScrollView.leadingAnchor.constraint(equalTo: hourlyForecastContainer.leadingAnchor),
            hourlyForecastScrollView.trailingAnchor.constraint(equalTo: hourlyForecastContainer.trailingAnchor),
            hourlyForecastScrollView.topAnchor.constraint(equalTo: hourlyForecastContainer.topAnchor),
            hourlyForecastScrollView.bottomAnchor.constraint(equalTo: hourlyForecastContainer.bottomAnchor),
            
            hourlyForecastView.leadingAnchor.constraint(equalTo: hourlyForecastScrollView.leadingAnchor),
            hourlyForecastView.trailingAnchor.constraint(equalTo: hourlyForecastScrollView.trailingAnchor),
            hourlyForecastView.topAnchor.constraint(equalTo: hourlyForecastScrollView.topAnchor),
            hourlyForecastView.bottomAnchor.constraint(equalTo: hourlyForecastScrollView.bottomAnchor),
            hourlyForecastView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 3),
            hourlyForecastView.heightAnchor.constraint(equalToConstant: 200),
            
            hourlyForecastTitle.leadingAnchor.constraint(equalTo: hourlyForecastContainer.leadingAnchor, constant: 20),
            hourlyForecastTitle.topAnchor.constraint(equalTo: hourlyForecastContainer.topAnchor, constant: 10),
        ])
    }
    
    func weeklyForecastViewSetup() {
        let view = weeklyForecastViewController.view!
        addChild(weeklyForecastViewController)
        stackView.addArrangedSubview(view)
        weeklyForecastViewController.didMove(toParent: self)
        
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        view.layer.borderWidth = 1

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.heightAnchor.constraint(equalToConstant: 400),
            view.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
        
    }
    
    func loadWeatherForecast() {
        Task {
            do {
                showSpinner()
                try await viewModel.getWeatherForUserLocation()
                try await viewModel.getHourlyForecastForUserLocation()
                hideSpinner()
            } catch {
                print(error)
                hideSpinner()
            }
        }
    }
}
