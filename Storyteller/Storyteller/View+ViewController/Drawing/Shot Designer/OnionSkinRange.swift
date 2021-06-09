//
//  OnionSkinRange.swift
//  Storyteller
//
//  Created by TFang on 18/4/21.
//

class OnionSkinRange {
    var lowerBound = 0
    var upperBound = 0

    func increaseUpperBound() {
        upperBound += 1
    }
    func decreaseUpperBound() {
        upperBound = max(0, upperBound - 1)
    }
    func increaseLowerBound() {
        lowerBound = min(0, lowerBound + 1)
    }
    func decreaseLowerBound() {
        lowerBound -= 1
    }
}

extension OnionSkinRange {
    var redIndicies: StrideTo<Int> {
        stride(from: lowerBound, to: 0, by: 1)
    }
    var greenIndicies: StrideTo<Int> {
        stride(from: upperBound, to: 0, by: -1)
    }
}
