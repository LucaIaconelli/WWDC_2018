//
//  Position.swift
//  WWDC2018
//
//  Created by Luca Iaconelli on 23/03/2018.
//  Copyright © 2018 Luca Iaconelli. All rights reserved.
//

import UIKit


public struct Position {
  let x : Int
  let y : Int
}

extension Array {
  mutating func shuffle() {
    for element in (0..<self.count).reversed() {
      let random = Int(arc4random_uniform(UInt32(element + 1)))
      (self[element], self[random]) = (self[random], self[element])
    }
  }
}

extension Int {
  static func randomInt(_ max:Int) -> Int {
    return Int(arc4random_uniform(UInt32(max)))
  }
}

extension UIColor {
  internal func rgbComponents() -> [CGFloat] {
    var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
    getRed(&r, green: &g, blue: &b, alpha: &a)
    return [r, g, b]
  }
}
