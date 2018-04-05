//
//  Tiles.swift
//  WWDC2018
//
//  Created by Luca Iaconelli on 23/03/2018.
//  Copyright © 2018 Luca Iaconelli. All rights reserved.
//

import UIKit


var palettesRGB:[[CGFloat]] = [[202.0,94.0,255.0],[255.0,164.0,94.0],[230.0,89.0,149.0], [230.0,149.0,149.0], [228.0,161.0,51.0], [255.0,94.0,94.0]]

public struct Tiles {
  let backgroundColor = UIColor(white: 1.0, alpha: 0.0)
  var colors:[UIColor] = []
  var tiles: [UIView] = []
  var movingTiles: [UIView] = []
  var properTiles: [UIView] = []
  
  var numberGame = 0
  
  var random:Int = 0
  
  init() {
    random = Int(arc4random_uniform(UInt32(palettesRGB.count)))
    initTiles()
  }
  
  private mutating func initTiles() {
    
    numberGame = 0
    
    for row in 0..<config.rows {
      var randomIndex = Int.randomInt(10)
      if randomIndex == 0 {
        randomIndex = Int.randomInt(10)
      }
      for column in 0..<config.columns {
        
        let red: CGFloat = (palettesRGB[random][0] - 45.0 * CGFloat(column) - CGFloat(row) * 3.0) / 255.0
        let green: CGFloat = (palettesRGB[random][1] - CGFloat(column) * 9.0 + CGFloat(row) * 22.0) / 255.0
        let blue: CGFloat = (palettesRGB[random][2] + CGFloat(column) * 10.0 - CGFloat(row) * 3.0) / 255.0
        if (row == 0 && column == 0) || (row == 0 && column == config.columns - 1) || (row == config.rows - 1 && column == 0) || (row == config.rows - 1 && column == config.columns - 1) {
          colors.append(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        }
        addTile(withRed: red, green: green, blue: blue, row: row, column: column, random: randomIndex)
      }
    }
  }
  
  func setBackgroundColor() {
    for row in 0..<config.rows {
      for column in 0..<config.columns {
        
        let red: CGFloat = (palettesRGB[random][0] - 45.0 * CGFloat(column) - CGFloat(row) * 3.0) / 255.0
        let green: CGFloat = (palettesRGB[random][1] - CGFloat(column) * 9.0 + CGFloat(row) * 22.0) / 255.0
        let blue: CGFloat = (palettesRGB[random][2] + CGFloat(column) * 10.0 - CGFloat(row) * 3.0) / 255.0
        if let label = properTiles[config.columns * row + column] as? UILabel {
          label.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        else {
          properTiles[config.columns * row + column].tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
      }
    }
  }
  
  public func toImage(_ image:BoardType) -> String {
    switch image {
    case .apple: return "appleLogo"
    case .watch: return "watch"
    case .homepod: return "homepod"
    case .iPad: return "ipad"
    case .mac: return "mac"
    case .iPhoneX: return "iphoneX"
    case .iMac: return "iMac"
    case .appleTV: return "appleTV"
    case .iPhone8: return "iphone8"
    default: return ""
    }
  }
  
  private mutating func addTile(withRed red: CGFloat, green: CGFloat, blue: CGFloat, row:Int, column:Int, random:Int) {
    var view = UIView()
    var copyView = UIView()
    view.isExclusiveTouch = true
    copyView.isExclusiveTouch = true
    if config.type == .circle {
      view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      copyView.backgroundColor = view.backgroundColor
      view.layer.cornerRadius = 35.0
      view.layer.masksToBounds = true
      copyView.layer.cornerRadius = 35.0
      copyView.layer.masksToBounds = true
    }
    else if config.type == .square || config.type == .rectangle {
      view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      copyView.backgroundColor = view.backgroundColor
    }
    else if config.type == .number {
      let label0 = UILabel()
      let label1 = UILabel()
      numberGame += 1
      let text = numberGame
      label0.font = UIFont.systemFont(ofSize: 40.0, weight: UIFont.Weight.black)
      label1.font = UIFont.systemFont(ofSize: 40.0, weight: UIFont.Weight.black)
      label0.text = "\(text)"
      label1.text = "\(text)"
      label0.adjustsFontSizeToFitWidth = true
      label0.textAlignment = .center
      label1.textAlignment = .center
      label0.backgroundColor = .clear
      label1.backgroundColor = .clear
      label0.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      label1.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      label0.isUserInteractionEnabled = true
      label1.isUserInteractionEnabled = true
      view = label0
      copyView = label1
    }
    else {
      var image = UIImage(named: toImage(config.type))
      image = image?.withRenderingMode(.alwaysTemplate)
      let imageView0 = UIImageView(image: image)
      let imageView1 = UIImageView(image: image)
      imageView0.backgroundColor = .clear
      imageView1.backgroundColor = .clear
      imageView0.tintColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      imageView1.tintColor = view.backgroundColor
      imageView0.isUserInteractionEnabled = true
      imageView1.isUserInteractionEnabled = true
      imageView0.contentMode = .center
      imageView1.contentMode = .center
      view = imageView0
      copyView = imageView1
    }
    tiles.append(view)
    properTiles.append(copyView)
  }
}
