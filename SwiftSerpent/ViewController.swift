//
//  ViewController.swift
//  SwiftSerpent
//
//  Created by Dharam Dhurandhar on 04/02/24.
//

import UIKit

class ViewController: UIViewController {
    
    var gameView: UIView!
    let gridSize = 20
    var gameTimer: Timer?
    var snakeBody = [CGPoint]()
    var foodPoint = CGPoint.zero
    var currentDirection: CGPoint = CGPoint(x: 0, y: -1) // Initially moving upwards

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameView()
        setupControls()
        startGame()
    }

    func setupGameView() {
        let gameViewSize = view.bounds.width - 40 // Padding from edges
        gameView = UIView(frame: CGRect(x: 20, y: (view.bounds.height - gameViewSize) / 2, width: gameViewSize, height: gameViewSize))
        gameView.backgroundColor = .lightGray
        view.addSubview(gameView)
    }
}

extension ViewController {
    
    func startGame() {
        snakeBody = [CGPoint(x: gridSize / 2, y: gridSize / 2)]
        generateFood()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
    }

    func generateFood() {
        var foodGenerated = false
        while !foodGenerated {
            let randomX = Int(arc4random_uniform(UInt32(gridSize)))
            let randomY = Int(arc4random_uniform(UInt32(gridSize)))
            let potentialFoodPoint = CGPoint(x: randomX, y: randomY)
            if !snakeBody.contains(potentialFoodPoint) {
                foodPoint = potentialFoodPoint
                foodGenerated = true
            }
        }
    }

    @objc func gameLoop() {
        moveSnake()
        checkForCollision()
        drawGame()
    }

    func moveSnake() {
        var newHead = snakeBody[0]
        newHead.x += currentDirection.x
        newHead.y += currentDirection.y

        // Wrap around logic
        if newHead.x < 0 {
            newHead.x = CGFloat(gridSize - 1)
        } else if newHead.x >= CGFloat(gridSize) {
            newHead.x = 0
        }

        if newHead.y < 0 {
            newHead.y = CGFloat(gridSize - 1)
        } else if newHead.y >= CGFloat(gridSize) {
            newHead.y = 0
        }

        snakeBody.insert(newHead, at: 0)
        
        if newHead == foodPoint {
            generateFood() // Increase the snake length and generate new food
        } else {
            snakeBody.removeLast() // Move the snake by removing the tail
        }
    }

    func checkForCollision() {
        // Implement collision detection with walls and self
    }
}

extension ViewController {
    
    func drawGame() {
        gameView.subviews.forEach { $0.removeFromSuperview() } // Clear previous drawings
        
        drawSnake()
        drawFood()
    }

    func drawSnake() {
        snakeBody.forEach { point in
            let snakePiece = UIView(frame: CGRect(x: point.x * CGFloat(gridSize), y: point.y * CGFloat(gridSize), width: CGFloat(gridSize), height: CGFloat(gridSize)))
            snakePiece.backgroundColor = .green
            gameView.addSubview(snakePiece)
        }
    }

    func drawFood() {
        let foodView = UIView(frame: CGRect(x: foodPoint.x * CGFloat(gridSize), y: foodPoint.y * CGFloat(gridSize), width: CGFloat(gridSize), height: CGFloat(gridSize)))
        foodView.backgroundColor = .red
        gameView.addSubview(foodView)
    }
}

extension ViewController {
    func setupControls() {
        let buttonSize: CGFloat = 50
        let padding: CGFloat = 20
        let yOffset = gameView.frame.maxY + padding

        // Directions: Up, Down, Left, Right
        let directions = ["Up", "Down", "Left", "Right"]
        for (index, direction) in directions.enumerated() {
            let button = UIButton(frame: CGRect(x: CGFloat(index) * (buttonSize + padding) + padding, y: yOffset, width: buttonSize, height: buttonSize))
            button.backgroundColor = .systemBlue
            button.setTitle(direction, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(changeDirection(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }

    @objc func changeDirection(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Up
            if currentDirection != CGPoint(x: 0, y: 1) { // Prevent moving directly opposite
                currentDirection = CGPoint(x: 0, y: -1)
            }
        case 1: // Down
            if currentDirection != CGPoint(x: 0, y: -1) {
                currentDirection = CGPoint(x: 0, y: 1)
            }
        case 2: // Left
            if currentDirection != CGPoint(x: 1, y: 0) {
                currentDirection = CGPoint(x: -1, y: 0)
            }
        case 3: // Right
            if currentDirection != CGPoint(x: -1, y: 0) {
                currentDirection = CGPoint(x: 1, y: 0)
            }
        default: break
        }
    }
}
