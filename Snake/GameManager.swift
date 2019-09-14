//
//  GameManager.swift
//  Snake
//
//  Created by Artem Agaev on 14/09/2019.
//  Copyright © 2019 Artem Agaev. All rights reserved.
//

import SpriteKit

class GameManager {
    
    var scene: GameScene!
    
    var nextTimeToPrint: Double?
    var timeExtensions: Double = 0.15
    var playerDirection: Int = 4 // 1 == left, 2 == up, 3 == right, 4 == down
    
    var currentScore: Int = 0
    
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func initGame() {
        scene.playerPosition.append((10, 10))
        scene.playerPosition.append((10, 11))
        scene.playerPosition.append((10, 12))
        renderChanges()
        
        generateRandomPoint()
    }
    
    func update(time: Double) {
        if nextTimeToPrint == nil {
            nextTimeToPrint = time + timeExtensions
        } else if time >= nextTimeToPrint! {
            nextTimeToPrint = time + timeExtensions
            updatePlayerPosition()
            
            checkForScore()
            checkForDeath()
            finishGame()
        }
    }
    
    func renderChanges() {
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPosition, v: (x, y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
                
                if scene.scorePos != nil {
                    //Pay attention x == y and y == x (not x == x and y == y)
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
    }
    
    func contains(a: [(Int, Int)], v: (Int, Int)) -> Bool {
        let (c1, c2) = v
        for (pX, pY) in a {
            if c1 == pX && c2 == pY {
                return true
            }
        }
        return false
    }
    
    func swipe(ID: Int) {
        if !(playerDirection == 4 && ID == 2) && !(playerDirection == 2 && ID == 2) {
            if !(playerDirection == 1 && ID == 3) && !(playerDirection == 3 && ID == 1) {
                if playerDirection != 0 {
                    playerDirection = ID
                }
            }
        }
    }
    
    //MARK: Private methods
    
    //Collision detection
    private func checkForScore() {
        if scene.scorePos != nil {
            let x = scene.playerPosition[0].0
            let y = scene.playerPosition[0].1
            
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateRandomPoint()
                
                scene.playerPosition.append(scene.playerPosition.last!)
                scene.playerPosition.append(scene.playerPosition.last!)
                scene.playerPosition.append(scene.playerPosition.last!)
            }
        }
    }
    
    private func checkForDeath() {
        if scene.playerPosition.count > 0 {
            var arrayOfPosition = scene.playerPosition
            let headOfSnake = arrayOfPosition[0]
            arrayOfPosition.remove(at: 0)
            if contains(a: arrayOfPosition, v: headOfSnake) {
                playerDirection = 0
            }
            
        }
    }
    
    private func finishGame() {
        if playerDirection == 0 && scene.playerPosition.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPosition[0]
            //If game end than playerPosition would have only 1 element (head of snake)
            for position in scene.playerPosition {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            if hasFinished {
                print("End game")
                playerDirection = 4
                updateScore()
                //animation has completed
                scene.scorePos = nil
                scene.playerPosition.removeAll()
                renderChanges()
                //return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.currentScore.isHidden = true
                }
                scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.gameBG.isHidden = true
                    self.scene.gameLogo.isHidden = false
                    self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                        self.scene.playButton.isHidden = false
                        self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                        self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y  - 50), duration: 0.3))
                    }
                }
            }
        }
    }
    
    private func updatePlayerPosition() {
        var xChange = -1
        var yChange = 0
        
        switch playerDirection {
        case 1:
            //left
            xChange = -1
            yChange = 0
        case 2:
            //up
            xChange = 0
            yChange = -1
        case 3:
            //right
            xChange = 1
            yChange = 0
        case 4:
            //down
            xChange = 0
            yChange = 1
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break;
        default:
            break;
        }
        
        if scene.playerPosition.count > 0 {
            var start = scene.playerPosition.count - 1
            while start > 0 {
                scene.playerPosition[start] = scene.playerPosition[start - 1]
                start -= 1
            }
            scene.playerPosition[0] = (scene.playerPosition[0].0 + yChange, scene.playerPosition[0].1 + xChange)
        }
        
        if scene.playerPosition.count > 0 {
            let x = scene.playerPosition[0].1
            let y = scene.playerPosition[0].0
            if y > 39 {
                scene.playerPosition[0].0 = 0
            } else if y < 0 {
                scene.playerPosition[0].0 = 39
            } else if x > 19 {
                scene.playerPosition[0].1 = 0
            } else if x < 0 {
                scene.playerPosition[0].1 = 19
            }
        }
        renderChanges()
    }
    
    private func generateRandomPoint() {
        var randomX = CGFloat(arc4random_uniform(19))
        var randomY = CGFloat(arc4random_uniform(39))
        
        //Regenerate new point if it generated on player body
        while contains(a: scene.playerPosition, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(19))
            randomY = CGFloat(arc4random_uniform(39))
        }
        //X is actually randomY and Y is randomX, no ideas why
        scene.scorePos = CGPoint(x: randomX, y: randomY)
        ;
    }
    
    private func updateScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(currentScore, forKey: "bestScore")
        }
        currentScore = 0
        scene.currentScore.text = "Score: 0"
        scene.bestScore.text = "Best score \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
}
