//
//  Observable.swift
//  WeatherApp
//
//  Created by Patricia Costin on 02.01.2024.
//

final class Observable<T> {
    
    init(_ value: T) {
        self.value = value
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    func bind(fire: Bool, _ closure: @escaping (T) -> Void) {
        if fire {
            closure(value)
        }
        listener = closure
    }
}
