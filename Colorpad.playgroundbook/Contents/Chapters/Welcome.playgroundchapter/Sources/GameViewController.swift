//
//  GameViewController.swift
//  WWDC2018
//
//  Created by Luca Iaconelli on 23/03/2018.
//  Copyright © 2018 Luca Iaconelli. All rights reserved.
//

import UIKit
import AVFoundation

public class GameViewController : UIViewController {
  let board = Board()
  var point = CGPoint()
  var frame = CGRect()
  var finalView:[UIView] = []
  var originalFinalView:[UIView] = []
  
  public var audioPlayerHard:AVAudioPlayer!
  public var audioPlayerEasy:AVAudioPlayer!
  public var audioPlayerImpossible:AVAudioPlayer!
  public var audioPlayerCongratulation:AVAudioPlayer!
  public var audioPlayerMove:AVAudioPlayer!
  
  public var isFinal = false
  public var playAgainTimer:Timer!
  public var playAgainCounter = 0
  
  var initialDelay = 1.0
  
  public var playAgainLabel:UILabel = UILabel()
  
  override public func viewDidLoad() {
    if let view = self.view {
      view.backgroundColor = UIColor(white: 1.0, alpha: 1)
      view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      view.isMultipleTouchEnabled = false
    }

    startSong()
    self.board.buildBoard(forView: self.view) { (success) in
      if success {
        self.addGestureRecognizer()
        /*if self.isBoardCorrect() {
          print("aoidjfoiajsdoifjasd")
          //Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.fadeOut), userInfo: nil, repeats: false);
          tiles = Tiles()
          self.board.rebuild()
        }*/
      }
    }
  }
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return isFinal ? UIStatusBarStyle.lightContent : .default
  }
  
  func stopSoundTrack() {
    switch config.difficult {
    case .easy:
      audioPlayerEasy.stop()
    case .impossible:
     audioPlayerImpossible.stop()
    case .hard:
      audioPlayerHard.stop()
    }
  }
  
  func startSong() {
    switch config.difficult {
    case .easy:
      let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "easymode", ofType: "mp3")!)
      do {
        audioPlayerEasy = try AVAudioPlayer(contentsOf: sound)
        audioPlayerEasy.numberOfLoops = -1
        audioPlayerEasy.play()
      }
      catch { }
    case .impossible:
      let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "impossiblemode", ofType: "mp3")!)
      do {
        audioPlayerImpossible = try AVAudioPlayer(contentsOf: sound)
        audioPlayerImpossible.numberOfLoops = -1
        audioPlayerImpossible.play()
      }
      catch { }
    case .hard:
      let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "hardmode", ofType: "mp3")!)
      do {
        audioPlayerHard = try AVAudioPlayer(contentsOf: sound)
        audioPlayerHard.numberOfLoops = -1
        audioPlayerHard.play()
      }
      catch { }
    }
  }
  
  public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { context in
      
    }, completion: nil)
  }
  
  @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
    guard let selectedView = gestureRecognizer.view else {
      return
    }
    
    if gestureRecognizer.state == .began {
      frame = selectedView.frame
      board.boardView.bringSubview(toFront: selectedView)
    }
    
    if gestureRecognizer.state == .changed {
      setTranslation(withGestureRecognizer: gestureRecognizer)
    }
    
    if gestureRecognizer.state == .ended {
      let point = selectedView.center
      for tile in tiles.movingTiles {
        if tile.frame.contains(point) && tile != selectedView {
          changeTilesPosition(withPointedTile: tile, andTouchedTile: selectedView)
          break
        } else {
          selectedView.frame = frame
        }
      }
      tiles.movingTiles.sort{$0.tag < $1.tag}
      if isBoardCorrect() {
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.fadeOut), userInfo: nil, repeats: false);
      }
    }
  }
  
  @objc private func addGestureRecognizer() {
    for i in tiles.movingTiles {
      let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
      i.addGestureRecognizer(gestureRecognizer)
    }
  }
  
  private func changeTilesPosition(withPointedTile pointedTile: UIView, andTouchedTile touchedTile: UIView) {
    guard let touchedIndex = tiles.movingTiles.index(of: touchedTile),
      let pointedIndex = tiles.movingTiles.index(of: pointedTile) else {
        return
    }
    tiles.movingTiles[touchedIndex].center = pointedTile.center
    
    let tag = tiles.movingTiles[touchedIndex].tag
    tiles.movingTiles[touchedIndex].tag = pointedTile.tag
    tiles.movingTiles[pointedIndex].tag = tag
    
    moveTile(withIndex: pointedIndex)
  }
  
  private func isBoardCorrect() -> Bool {
    for (index, tile) in tiles.movingTiles.enumerated() {
      switch config.difficult {
      case .easy:
        if tile != tiles.tiles[index + config.rows] {
          return false
        }
      case .hard:
        var rightIndex = index
        if index >= 0 && index < config.columns - 2 {
          rightIndex +=  1
        }
        else if index <= (config.columns * config.rows) - 4 && index > (config.columns * config.rows) - config.rows - 3 {
          rightIndex += 3
        }
        else {
            rightIndex += 2
        }
        
        if tile != tiles.tiles[rightIndex] {
          return false
        }
      case .impossible:
        if tile != tiles.tiles[index] {
          return false
        }
      }
    }
    return true
  }
  
  private func setTranslation(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
    let translation = gestureRecognizer.translation(in: self.view)
    guard let selectedView = gestureRecognizer.view else {
      return
    }
    selectedView.center = CGPoint(x: selectedView.center.x + translation.x, y: selectedView.center.y + translation.y)
    gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
    let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "moveasquare", ofType: "mp3")!)
    do {
      audioPlayerMove = try AVAudioPlayer(contentsOf: sound)
      audioPlayerMove.numberOfLoops = 0
      audioPlayerMove.play()
    }
    catch { }
  }
  
  private func moveTile(withIndex index: Int) {
    UIView.animate(withDuration: 0.45, delay: 0.1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
      tiles.movingTiles[index].frame = self.frame
    })
  }
  
  @objc private func fadeOut() {
    if tiles.tiles == [] {
      onEndGame()
      return
    }
    let tile = tiles.tiles.removeFirst()
    UIView.animate(withDuration: 0.25, animations: {
      tile.alpha = 0.0
      Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(self.fadeOut), userInfo: nil, repeats: false);
    })
  }
  
  private func onEndGame() {
    
    let height = view.bounds.size.height / CGFloat(tiles.colors.count)
   
    stopSoundTrack()
    
    let label = UILabel(frame: CGRect(x: 0, y: height * CGFloat(1), width: view.bounds.width, height: height))
    label.backgroundColor = .clear
    label.text = "Congratulations!"
    label.textColor = .white
    label.numberOfLines = 1
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 45.0)
    label.layer.shadowColor = UIColor.black.cgColor
    label.layer.shadowOffset = .zero
    label.layer.shadowOpacity = 0.5
    label.layer.shadowRadius = 10.0
    label.layer.masksToBounds = false
    label.alpha = 0.0
    
    
    let label1 = UILabel(frame: CGRect(x: 0, y: height * CGFloat(3), width: view.bounds.width, height: height))
    label1.backgroundColor = .clear
    label1.text = "Created by\nLuca Iaconelli"
    label1.textColor = .white
    label1.numberOfLines = 2
    label1.textAlignment = .center
    label1.font = UIFont.systemFont(ofSize: 20.0)
    label1.layer.shadowColor = UIColor.black.cgColor
    label1.layer.shadowOffset = .zero
    label1.layer.shadowOpacity = 0.5
    label1.layer.shadowRadius = 10.0
    label1.layer.masksToBounds = false
    label1.alpha = 0.0
    
    
    playAgainLabel = UILabel(frame: CGRect(x: view.bounds.width / 2.0 - ((view.bounds.width / 2.5) / 2.0), y: height * CGFloat(2) + ((height / 2.0)) - ((height / 3.0) / 2.0), width: view.bounds.width / 2.5, height: height / 3.0))
    playAgainLabel.backgroundColor = .white
    playAgainLabel.text = "Play Again"
    playAgainLabel.textColor = .darkGray
    playAgainLabel.numberOfLines = 2
    playAgainLabel.textAlignment = .center
    playAgainLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
    playAgainLabel.layer.shadowColor = UIColor.black.cgColor
    playAgainLabel.layer.shadowOffset = .zero
    playAgainLabel.layer.shadowOpacity = 0.5
    playAgainLabel.layer.shadowRadius = 10.0
    playAgainLabel.clipsToBounds = true
    playAgainLabel.layer.cornerRadius = 30.0
    playAgainLabel.layer.borderWidth = 3.0
    playAgainLabel.layer.borderColor = UIColor.white.cgColor
    playAgainLabel.alpha = 0.0
    let gesture = UITapGestureRecognizer(target: self, action: #selector(playAgain))
    playAgainLabel.isUserInteractionEnabled = true
    playAgainLabel.removeGestureRecognizer(gesture)
    playAgainLabel.addGestureRecognizer(gesture)
    
    playAgainTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { timer in
      if self.playAgainCounter % 2 == 0 {
        UIView.animate(withDuration: 1.0, animations: {
          let scaleFloat = CGFloat(1.25)
          self.playAgainLabel.transform = CGAffineTransform(scaleX: scaleFloat, y: scaleFloat)
        })
      }
      else {
        UIView.animate(withDuration: 1.0, animations: {
          let scaleFloat = CGFloat(1.0)
          self.playAgainLabel.transform = CGAffineTransform(scaleX: scaleFloat, y: scaleFloat)
        })
      }
      self.playAgainCounter += 1
    })
    playAgainTimer.fire()
    
    for (index,item) in tiles.colors.enumerated() {
      let v = UIView(frame: CGRect(x: 0, y: height * CGFloat(index), width: view.bounds.width, height: height))
      v.backgroundColor = item
      v.alpha = 0.0
      finalView.append(v)
      originalFinalView.append(v)
      view.addSubview(v)
    }
    finalView.append(label)
    view.addSubview(label)
    finalView.append(label1)
    view.addSubview(label1)
    finalView.append(playAgainLabel)
    view.addSubview(playAgainLabel)
    originalFinalView.append(label)
    originalFinalView.append(label1)
    originalFinalView.append(playAgainLabel)
    final()
  }
  
  @objc private func final() {
    if finalView.isEmpty {
      isFinal = true
      setNeedsStatusBarAppearanceUpdate()
      let sound = URL(fileURLWithPath: Bundle.main.path(forResource: "congratulations", ofType: "mp3")!)
      do {
        audioPlayerCongratulation = try AVAudioPlayer(contentsOf: sound)
        audioPlayerCongratulation.numberOfLoops = 2
        audioPlayerCongratulation.volume = 1.0
        audioPlayerCongratulation.play()
      }
      catch { }
      return
    }
    let tile = finalView.removeFirst()
    UIView.animate(withDuration: 0.25, animations: {
      tile.alpha = 1.0
      Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.final), userInfo: nil, repeats: false);
    })
  }
  
  @objc private func playAgain() {
    if originalFinalView.isEmpty {
      tiles = Tiles()
      UIView.animate(withDuration: 1.5, animations: {
        tiles.setBackgroundColor()
        self.startSong()
        self.board.rebuild()
        self.isFinal = false
        self.setNeedsStatusBarAppearanceUpdate()
        self.audioPlayerCongratulation.stop()
        self.playAgainTimer.invalidate()
      })
      return
    }
    let tile = originalFinalView.removeFirst()
    UIView.animate(withDuration: 0.25, animations: {
      tile.alpha = 0.0
      Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.playAgain), userInfo: nil, repeats: false);
    })
  }
  
}
