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
    var isGamePaused = false
    var pauseButton: UIButton!
    var score = 0
    var highScore = 0
    var scoreLabel: UILabel!
    var highScoreLabel: UILabel!
    var currentLevel = 1
    var targetScoreForNextLevel = 1 // Example target score to reach the next level
    var obstacles: [CGPoint] = []



    override func viewDidLoad() {
        super.viewDidLoad()
        highScore = UserDefaults.standard.integer(forKey: "highScore")
        setupGameView()
        setupScoreLabels()
        setupControls()
        setupPauseButton()
        startGame()
        adNotificationObservers()
    }
    
    func adNotificationObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGameIfNeeded), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func pauseGame() {
        if !isGamePaused {
            togglePauseGame()
        }
    }

    @objc func resumeGameIfNeeded() {
        // Optional: Check a condition if the game was paused by the user manually and should not be resumed automatically
        if isGamePaused {
            togglePauseGame()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        score = 0
            updateScoreLabels()
        snakeBody = [CGPoint(x: gridSize / 2, y: gridSize / 2)]
        generateFood()
        gameTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
    }
    
    @objc func togglePauseGame() {
        if isGamePaused {
            // Resume game
            gameTimer?.resumeTimer()
            isGamePaused = false
            pauseButton.setTitle("Pause", for: .normal) // Change text to "Pause"
        } else {
            // Pause game
            gameTimer?.pauseTimer()
            isGamePaused = true
            pauseButton.setTitle("Resume", for: .normal) // Change text to "Resume"
        }
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
        checkLevelAdvance()
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
            score += 1 // Increase score
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(highScore, forKey: "highScore")
            }
            generateFood() // Increase the snake length and generate new food
            updateScoreLabels()
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
        let directions = ["Right", "Down", "Left", "Up"]
        let circleRadius: CGFloat = 100 / 2
        let center = view.center

        for (index, direction) in directions.enumerated() {
            let angle: CGFloat = CGFloat(index) * (2.0 * .pi / CGFloat(directions.count))
            
            // Break down the calculation of buttonX and buttonY into smaller steps
            let offsetX: CGFloat = circleRadius * cos(angle)
            let offsetY: CGFloat = circleRadius * sin(angle)
            let buttonX: CGFloat = center.x + offsetX - (buttonSize / 2)
            let buttonY: CGFloat = center.y * 1.7 + offsetY - (buttonSize / 2)
            
            let buttonFrame = CGRect(x: buttonX, y: buttonY, width: buttonSize, height: buttonSize)
            let button = UIButton(frame: buttonFrame)
            button.backgroundColor = .systemBlue
            button.setTitle(direction, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(changeDirection(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    func setupPauseButton() {
        let buttonSize: CGFloat = 50
        pauseButton = UIButton(frame: CGRect(x: view.center.x - buttonSize / 2, y: view.center.y * 1.7 - buttonSize / 2, width: buttonSize, height: buttonSize))
        pauseButton.backgroundColor = .systemRed
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(togglePauseGame), for: .touchUpInside)
        view.addSubview(pauseButton)
    }


    @objc func changeDirection(_ sender: UIButton) {
        switch sender.tag {
        case 3: // Up
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
        case 0: // Right
            if currentDirection != CGPoint(x: -1, y: 0) {
                currentDirection = CGPoint(x: 1, y: 0)
            }
        default: break
        }
    }
}

extension ViewController{
    func setupScoreLabels() {
        scoreLabel = UILabel(frame: CGRect(x: 20, y: 120, width: 200, height: 20))
        scoreLabel.textColor = .white
        view.addSubview(scoreLabel)
        
        highScoreLabel = UILabel(frame: CGRect(x: 20, y: 160, width: 200, height: 20))
        highScoreLabel.textColor = .white
        view.addSubview(highScoreLabel)
        
        updateScoreLabels()
    }

    func updateScoreLabels() {
        scoreLabel.text = "Score: \(score)"
        highScoreLabel.text = "High Score: \(highScore)"
    }
}

extension ViewController {

    func checkLevelAdvance() {
        if score >= targetScoreForNextLevel {
            advanceToNextLevel()
        }
    }

    func advanceToNextLevel() {
        currentLevel += 1
        score = 0 // Optionally reset score or keep accumulating
        targetScoreForNextLevel += 2 // Adjust based on your leveling system
        increaseDifficulty()
        
        // Reset or adjust game state as needed for new level
        // For example, increase speed:
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: calculateNewTimeInterval(), target: self, selector: #selector(gameLoop), userInfo: nil, repeats: true)
    }

    func calculateNewTimeInterval() -> TimeInterval {
        // Example logic to increase speed: reduce the timer interval
        // Adjust the decrement value to suit your game's difficulty curve
        max(0.05, 0.25 - (TimeInterval(currentLevel - 1) * 0.02))
    }

    func generateObstacles() {
        obstacles.removeAll()
        // Generate new obstacles based on current level
        let numberOfObstacles = currentLevel * 2 // Example: increase obstacle count with level
        for _ in 0..<numberOfObstacles {
            var obstaclePoint: CGPoint
            repeat {
                obstaclePoint = CGPoint(x: Int.random(in: 0..<gridSize), y: Int.random(in: 0..<gridSize))
            } while snakeBody.contains(obstaclePoint) || obstaclePoint == foodPoint // Avoid placing on the snake or food
            obstacles.append(obstaclePoint)
        }
    }

    func drawObstacles() {
        for obstacle in obstacles {
            let obstacleView = UIView(frame: CGRect(x: obstacle.x * CGFloat(gridSize), y: obstacle.y * CGFloat(gridSize), width: CGFloat(gridSize), height: CGFloat(gridSize)))
            obstacleView.backgroundColor = .yellow // Choose a color that stands out
            gameView.addSubview(obstacleView)
        }
    }
    
    func increaseDifficulty() {
        generateObstacles()
        drawObstacles()
    }

}

extension Timer {
    func pauseTimer() {
        self.fireDate = Date.distantFuture
    }

    func resumeTimer() {
        self.fireDate = Date()
    }
}
