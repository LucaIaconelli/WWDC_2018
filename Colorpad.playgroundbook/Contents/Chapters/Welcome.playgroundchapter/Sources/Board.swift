//
//  Board.swift
//  WWDC2018
//
//  Created by Luca Iaconelli on 23/03/2018.
//  Copyright © 2018 Luca Iaconelli. All rights reserved.
//

import UIKit

public var config = BoardConfig(withRowsCount: 4, columnsCount: 4, type: .number , difficult: .hard)
public var tiles = Tiles()


public class Board {
  let boardView : UIView
  private var shuffledTiles: [UIView] = []
  private var buildDone: ((Bool) -> ())?
  
  var initialDelay = 2.0
  
  init() {
    boardView = UIView(frame: .zero)
    boardView.backgroundColor = tiles.backgroundColor
    boardView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func rebuild() {
    initialBuild()
    initializeShuffeling(initialDelay)
  }
  
  func buildBoard(forView view: UIView, withCompletion completion: ((Bool) -> Void)?) {
    buildDone = completion
    initialBuild()
    initializeShuffeling(initialDelay)
    addTo(view: view)
  }
  
  private func initialBuild() {
    for i in 0..<config.rows {
      for j in 0..<config.columns {
        let view = tiles.properTiles[config.columns * i + j]
        view.frame = CGRect(origin: pointAt(x: j, y: i), size: config.tileSize)
        view.tag = config.columns * i + j
        view.alpha = 1.0
        tiles.setBackgroundColor()
        boardView.addSubview(view)
      }
    }
  }
  
  private func initializeShuffeling(_ timeInterval:Double = 1.0) {
    Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.removeTile), userInfo: nil, repeats: false);
    
  }
  
  @objc private func removeTile() {
    if tiles.properTiles == [] {
      return
    }
    if tiles.properTiles.count == (config.rows * config.columns) - 5 {
      shuffleBuild()
      addTile()
    }
    let tile = tiles.properTiles.removeFirst()
    UIView.animate(withDuration: 0.25, animations: {
      tile.alpha = 0.0
      Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.removeTile), userInfo: nil, repeats: false);
    })
  }
  
  @objc func addTile() {
    if shuffledTiles.isEmpty {
      buildDone?(true)
      return
    }
    let tile = shuffledTiles.removeFirst()
    UIView.animate(withDuration: 0.25, animations: {
      tile.alpha = 1.0
      Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.addTile), userInfo: nil, repeats: false);
    })
    
  }
  
  private func shuffleBuild() {
    if config.difficult == .easy {
      shuffledTiles = shuffleTiles(fromIndex: config.rows, toIndex: (config.rows * config.columns) -  config.rows)
      for i in 0..<config.tileCount {
        if i >= config.rows && i < (config.rows * config.columns) -  config.rows {
          continue
        }
        addLabelToTile(atindex: i)
        shuffledTiles.insert(tiles.tiles[i], at: i)
      }
    }
    else if config.difficult == .hard {
      var tilesToShuffle: [UIView] = []
      for i in 0..<config.tileCount {
        if !(i == 0 || i == config.columns - 1 || i == (config.rows * config.columns) - config.rows || i == (config.rows * config.columns) - 1) {
          tilesToShuffle.append(tiles.tiles[i])
        }
      }
      tilesToShuffle.shuffle()
      tiles.movingTiles = tilesToShuffle
      shuffledTiles = tilesToShuffle
      for i in 0..<config.tileCount {
        if !(i == 0 || i == config.columns - 1 || i == (config.rows * config.columns) - config.rows || i == (config.rows * config.columns) - 1)  {
          continue
        }
        addLabelToTile(atindex: i)
        shuffledTiles.insert(tiles.tiles[i], at: i)
      }
    }
    else {
      shuffledTiles = shuffleTiles(fromIndex: 0, toIndex: config.tileCount)
    }
    
    for (index,item) in tiles.movingTiles.enumerated() {
      item.tag = index
      print(item.tag)
    }
    
    for i in 0..<config.rows {
      for j in 0..<config.columns {
        let view = shuffledTiles[config.columns * i + j]
        view.frame = CGRect(origin: pointAt(x: j, y: i), size: config.tileSize)
        view.tag = config.columns * i + j
        print(view.tag)
        view.alpha = 0.0
        boardView.addSubview(view)
      }
    }
  }
  
  private func shuffleTiles(fromIndex startIndex: Int, toIndex endIndex: Int) -> [UIView] {
    var tilesToShuffle: [UIView] = []
    for i in 0..<config.tileCount {
      if i >= startIndex && i < endIndex {
        tilesToShuffle.append(tiles.tiles[i])
      }
    }
    tilesToShuffle.shuffle()
    tiles.movingTiles = tilesToShuffle
    return tilesToShuffle
  }
  
  private func addLabelToTile(atindex index: Int) {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: config.tileWitdh, height: config.tileHeight))
    imageView.center = CGPoint(x: Double(config.tileWitdh)/2.0, y: Double(config.tileHeight)/2.0)
    imageView.image = #imageLiteral(resourceName: "closelockIcon")
    imageView.backgroundColor = .clear
    imageView.contentMode = .center
    imageView.alpha = 0.8
    if config.type == .number {
      if let label = tiles.tiles[index] as? UILabel {
        label.layer.borderWidth = 0.5
        label.layer.borderColor = label.textColor.cgColor
      }
    }
    else {
      tiles.tiles[index].addSubview(imageView)
    }
  }
  
  private func addTo(view : UIView){
    self.boardView.isMultipleTouchEnabled = false
    self.boardView.isExclusiveTouch = true
    view.isExclusiveTouch = true
    view.addSubview(self.boardView)
    boardView.widthAnchor.constraint(equalToConstant: config.boardSize.width).isActive = true
    boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor).isActive = true
    boardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    boardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
  
  private func pointAt(position: Position) -> CGPoint {
    return pointAt(x: position.x, y: position.y)
  }
  
  private func pointAt(x:Int, y:Int) -> CGPoint {
    let width = config.tileSize.width
    let height = config.tileSize.height
    return CGPoint(x: width * CGFloat(x), y: height * CGFloat(y))
  }
}
