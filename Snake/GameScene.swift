//
//  GameScene.swift
//  Snake
//
//  Created by Artem Agaev on 14/09/2019.
//  Copyright © 2019 Artem Agaev. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: Main menu properties
    
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    
    //MARK: Game properties
    
    var currentScore: SKLabelNode!
    var playerPosition: [(Int, Int)] = []
    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
    
    var scorePos:CGPoint?
    
    var game: GameManager!
    
    
    override func didMove(to view: SKView) {
        initMenu()
        game = GameManager.init(scene: self)
        initGameView()
        
        //Register touch listeners
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        game.update(time: currentTime)
    }
    
    //MARK: Event listeners
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    
    //MARK: Swipe methods
    
    @objc func swipeR() {
        game.swipe(ID: 3)
    }
    
    @objc func swipeL() {
        game.swipe(ID: 1)
    }
    
    @objc func swipeU() {
        game.swipe(ID: 2)
    }
    
    @objc func swipeD() {
        game.swipe(ID: 4)
    }
    
    
    //MARK: Private methods
    
    private func initMenu() {
        //Create game title
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "Snake"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        
        //Create best score label
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        
        //Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        
        let topCorner = CGPoint(x: -50, y: 50)
        let bottonCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottonCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    }
    
    private func startGame() {
        print("Game started")
        
        gameLogo.run(SKAction.move(by: CGVector(dx: 0, dy: 600), duration: 0.7)) {
            self.gameLogo.isHidden = true
        }
        
        playButton.run(SKAction.scale(to: CGFloat(0), duration: TimeInterval(0.7))) {
            self.playButton.isHidden = true
        }
        
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.7)) {
            self.gameBG.setScale(0)
            self.currentScore.setScale(0)
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            
            self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
            
            self.game.initGame()
        }
    }
    
    private func initGameView() {
        //Add currentScore label
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.fontColor = SKColor.white
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        self.addChild(currentScore)
        
        //Add game board
        let width = 550
        let heigth = 1100
        let rect = CGRect(x: -width / 2, y: -heigth / 2, width: width, height: heigth)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)
        
        createGameBoard(width: Int(width), heigth: Int(heigth))
    }
    
    private func createGameBoard(width: Int, heigth: Int) {
        let cellWidth: CGFloat = 27.5
        let numRows = 40
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(heigth / 2) - (cellWidth / 2)
        
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                gameArray.append((node: cellNode, x: i, y: j))
                gameBG.addChild(cellNode)
                
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
        ;
    }
    
}
