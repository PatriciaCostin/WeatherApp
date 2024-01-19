//
//  Zip3Sequence.swift
//  WeatherApp
//
//  Created by Patricia Costin on 18.01.2024.
//

import Foundation

struct Zip3Sequence<E1, E2, E3, E4>: Sequence, IteratorProtocol {
    private let _next: () -> (E1, E2, E3, E4)?

    init<S1: Sequence, S2: Sequence, S3: Sequence, S4: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) where S1.Element == E1, S2.Element == E2, S3.Element == E3, S4.Element == E4 {
        var it1 = s1.makeIterator()
        var it2 = s2.makeIterator()
        var it3 = s3.makeIterator()
        var it4 = s4.makeIterator()
        _next = {
            guard let e1 = it1.next(), let e2 = it2.next(), let e3 = it3.next(), let e4 = it4.next() else { return nil }
            return (e1, e2, e3, e4)
        }
    }

    mutating func next() -> (E1, E2, E3, E4)? {
        return _next()
    }
}

func zip3<S1: Sequence, S2: Sequence, S3: Sequence, S4: Sequence>(_ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4) -> Zip3Sequence<S1.Element, S2.Element, S3.Element, S4.Element> {
    return Zip3Sequence(s1, s2, s3, s4)
}
