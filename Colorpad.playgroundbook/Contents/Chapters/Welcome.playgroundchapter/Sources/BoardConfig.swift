//
//  BoardConfig.swift
//  WWDC2018
//
//  Created by Luca Iaconelli on 23/03/2018.
//  Copyright © 2018 Luca Iaconelli. All rights reserved.
//

import UIKit

public enum Difficult: Int {
  case easy = 0
  case hard
  case impossible
}

public enum BoardType: Int {
  case square
  case rectangle
  case circle
  case number
  case apple
  case watch
  case homepod
  case iPad
  case mac
  case iPhoneX
  case iMac
  case appleTV
  case iPhone8
}

public struct BoardConfig {
  var tileWitdh:CGFloat = 75.0
  var tileHeight:CGFloat = 75.0
  let rows: Int
  let columns: Int
  let tileCount: Int
  let boardSize: CGSize
  let tileSize: CGSize
  let type:BoardType
  let difficult:Difficult
  
  public init(withRowsCount rows: Int, columnsCount columns: Int, type:BoardType, difficult:Difficult = .easy) {
    self.type = type
    self.rows = rows
    self.columns = columns
    self.tileCount = rows * columns
    self.difficult = difficult
    
    switch type {
    case .number:
      tileWitdh = 70.0
      tileHeight = 70.0
      self.boardSize = CGSize(width: rows * Int(tileWitdh), height: columns * Int(tileHeight))
      self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    case .square:
      tileWitdh = 75.0
      tileHeight = 75.0
      self.boardSize = CGSize(width: rows * Int(tileWitdh), height: columns * Int(tileHeight))
      self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    case .rectangle:
      tileWitdh = 70.0
      tileHeight = 85.0
      self.boardSize = CGSize(width: rows * Int(tileWitdh), height: columns * Int(tileHeight))
      self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    case .circle:
      tileWitdh = 70.0
      tileHeight = 70.0
      self.boardSize = CGSize(width: rows * Int(tileWitdh), height: columns * Int(tileHeight))
      self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    default:
      tileWitdh = 70.0
      tileHeight = 70.0
      self.boardSize = CGSize(width: rows * Int(tileWitdh), height: columns * Int(tileHeight))
      self.tileSize = CGSize(width: tileWitdh, height: tileHeight)
    }
  }
}
