/*******************************************************************************
* GameStateManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for game state values
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/07/18		*	EGC	*	File creation date
*     05/07/18             *       EGC *       Adding Easy Mode
********************************************************************************
*/

import Foundation
import UIKit
import FirebaseAnalytics

class GameStateManager
{
	private let stasisFieldOne = StasisField()
	private let stasisFieldTwo = StasisField()
	private var tileWidth : Int!
	private var tileHeight : Int!
	private var currentLevel = ConfigurationManager.sharedManager.getStartLevel()
	private var escapeLadderBase = (xPos: 0, yPos : 0)
	private var escapeLadderTop = (xPos: 0, yPos : 0)
	private var playerPosition = (cPos: 0, yPos: 0)
	private var guards = [Guard]()
	private var player : Player!
	private var goldBars = [GoldBar]()
	private var platforms = [Platform]()
	private var teleporters = [Teleporter]()
	private var currentScore = 0
	private var numberOfLives = ConfigurationManager.defaultStartingNumberOfLives
	private var levelEscapable = false
	private var nextExtraLifeBoundary = ConfigurationManager.pointsPerAdditionalLife

	var totalLevelGold = 0

	static let sharedManager = GameStateManager()

	func getTileWidth() -> Int
	{
		return tileWidth
	}

	func setTileWidth(width: Int)
	{
		self.tileWidth = width
	}

	func getTileHeight() -> Int
	{
		return tileHeight
	}

	func setTileHeight(height: Int)
	{
		self.tileHeight = height
	}

	func getCurrentLevel() -> Int
	{
		return currentLevel
	}

	func setCurrentLevel(startLevel: Int)
	{
		currentLevel = startLevel
	}

	func getLevelEscapable() -> Bool
	{
		return levelEscapable
	}

	func setLevelEscapable(_ flag: Bool)
	{
		levelEscapable = flag
	}

	func advanceLevel()
	{
		currentLevel = currentLevel + 1
	}

	func getEscapeLadderBase() -> (xPos: Int, yPos : Int)
	{
		return escapeLadderBase
	}

	func getEscapeLadderTop() -> (xPos: Int, yPos : Int)
	{
		return escapeLadderTop
	}

	func setEscapeLadderBase(x: Int, y: Int)
	{
		escapeLadderBase.xPos = x
		escapeLadderBase.yPos = y
		escapeLadderTop.xPos = x
		escapeLadderTop.yPos = 0
	}

	func getPlayer() -> Player
	{
		return player
	}

	func setPlayer(player: Player)
	{
		self.player = player
	}

	func getPlayerPosition() -> (x: Int, y: Int)
	{
		return (x: player.xTile, y: player.yTile)
	}

	func getPlayerFalling() -> Bool
	{
		return self.player.falling
	}

	func getGuards() -> [Guard]
	{
		return guards
	}

	func addGuard(defender: Guard)
	{
		self.guards.append(defender)
	}

    func removeLastGuard()
    {
        self.guards.removeLast()
    }

	func getGoldBars() -> [GoldBar]
	{
		return goldBars
	}

	func addGoldBar(gold: GoldBar)
	{
		self.goldBars.append(gold)
		totalLevelGold += 1
	}

	func getPlatforms() -> [Platform]
	{
		return platforms
	}

	func addPlatform(platform: Platform)
	{
		self.platforms.append(platform)
	}

	func getTeleporters() -> [Teleporter]
	{
		return teleporters
	}

	func getTeleporterForIdentifier(pair: UInt8) -> Teleporter?
	{
		for teleporter in teleporters
			{
			if teleporter.identifier == pair
				{
				return teleporter
				}
			}
		return nil
	}

	func addTeleporter(teleporter: Teleporter)
	{
		self.teleporters.append(teleporter)
	}

	func getStasisFieldOne() -> StasisField
	{
		return stasisFieldOne
	}

	func getStasisFieldTwo() -> StasisField
	{
		return stasisFieldTwo
	}

	func getNextAdditonalLifeScore() -> Int
	{
		return nextExtraLifeBoundary
	}

	func advanceAdditionalLifeScore()
	{
		nextExtraLifeBoundary += ConfigurationManager.pointsPerAdditionalLife
		grantBonusLife()
	}

	func arrangeAnimations()
	{
		if let sprites = SpriteManager.sharedManager.sprites
			{
			var index = 0
			for _ in sprites
				{
				if index == ConfigurationManager.platformSpriteIndex
					{
					for endIndex in index..<sprites.count
						{
						let checkSprite = sprites[endIndex]
						if checkSprite.isLastAnimationFrame
							{
							Platform.setStartFrame(start: index)
							Platform.setEndFrame(end: endIndex)
							break
							}
						}
					}
				else if index == ConfigurationManager.teleporterSpriteIndex
					{
					for endIndex in index..<sprites.count
						{
						let checkSprite = sprites[endIndex]
						if checkSprite.isLastAnimationFrame
							{
							Teleporter.setStartFrame(start: index)
							Teleporter.setEndFrame(end: endIndex)
							break
							}
						}
					}
				else if index == ConfigurationManager.stasisFieldSpriteIndex
					{
					for endIndex in index..<sprites.count
						{
						let checkSprite = sprites[endIndex]
						if checkSprite.isLastAnimationFrame
							{
							StasisField.setStartFrame(start: index)
							StasisField.setEndFrame(end: endIndex)
							break
							}
						}
					}
				index += 1
				}
			}
	}

	func resetLevel()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		player = nil
		totalLevelGold = 0
		guards.removeAll()
		goldBars.removeAll()
		platforms.removeAll()
		teleporters.removeAll()
		appDelegate.gameScreenViewController!.updateScore(newScore: currentScore)
		appDelegate.gameScreenViewController!.updateLives(livesRemaining: numberOfLives)
	}

	func resetGameStats()
	{
		currentScore = 0
		numberOfLives = ConfigurationManager.defaultStartingNumberOfLives
	}

	func addGoldBarToScore()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		currentScore += ConfigurationManager.pointsPerGoldBar
		appDelegate.gameScreenViewController!.updateScore(newScore: currentScore)
	}

	func addBeatenLevelToScore()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		currentScore += ConfigurationManager.pointsPerLevelBeaten
		appDelegate.gameScreenViewController!.updateScore(newScore: currentScore)
	}

	func playerDeath()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		numberOfLives -= 1
		sleep(UInt32(ConfigurationManager.postDeathDelay))
		if numberOfLives > 0
			{
			appDelegate.gameScreenViewController!.updateLives(livesRemaining: numberOfLives)
			appDelegate.gameScreenViewController!.endLevel()
			appDelegate.gameScreenViewController!.startLevel(skipReveal: true)
			}
		else
			{
			let highScore = checkForHighScore()
			Analytics.logEvent("GameEndLostLastLife", parameters: [AnalyticsParameterLevel: currentLevel])
			appDelegate.gameScreenViewController!.endLevel()
			numberOfLives = ConfigurationManager.defaultStartingNumberOfLives
			appDelegate.gameScreenViewController!.updateScore(newScore: currentScore)
			appDelegate.gameScreenViewController!.updateLives(livesRemaining: numberOfLives)
			appDelegate.gameCenterViewController!.end()
			if highScore
				{
				appDelegate.gameCenterViewController!.promptNewHighScore(score: currentScore)
				}
			currentScore = 0
			}
	}

	func winLevel()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		Analytics.logEvent("BeatLevel", parameters: [AnalyticsParameterLevel: currentLevel])
        if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemBeatenLevels, from: .UserDefaults)
            {
            PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemBeatenLevels, value: [GameboardManager.sharedManager.getGameboard(number: (currentLevel - 1)).identifier], type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
            }
        else
            {
            let beatenLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemBeatenLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
            var beatenLevels = beatenLevelsEntry.value
            if !beatenLevels.contains(GameboardManager.sharedManager.getGameboard(number:  (currentLevel - 1)).identifier!)
                {
                beatenLevels.append(GameboardManager.sharedManager.getGameboard(number:  (currentLevel - 1)).identifier!)
                PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemBeatenLevels, value: beatenLevels, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
                }
            }
		appDelegate.gameScreenViewController!.endLevel()
		addBeatenLevelToScore()
		SoundManager.sharedManager.playWinLevel()
		if ConfigurationManager.sharedManager.getLastLevelNumber() > currentLevel
			{
			advanceLevel()
			ConfigurationManager.sharedManager.setStartLevel(newValue: currentLevel)
			appDelegate.gameScreenViewController!.prepareForNextLevel()
			RunLoop.main.add(Timer(timeInterval: ConfigurationManager.postLevelWinDelay, repeats: false, block: {_ in DispatchQueue.main.async(execute: { () -> Void in appDelegate.gameScreenViewController!.startLevel(skipReveal: false)})}), forMode: RunLoopMode.commonModes)
			}
		else
			{
			let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
			let extrasController = (mainStoryboard.instantiateViewController(withIdentifier: "GetExtras") as! ExtrasViewController)
			extrasController.modalPresentationStyle = .fullScreen
			appDelegate.gameCenterViewController!.end()
			RunLoop.main.add(Timer(timeInterval: ConfigurationManager.postLastLevelWinDelay, repeats: false, block: {_ in DispatchQueue.main.async(execute: { () -> Void in
					appDelegate.gameCenterViewController!.stopHighScoreAnimation()
					appDelegate.gameCenterViewController!.present(extrasController, animated: true, completion: nil)
				})}), forMode: RunLoopMode.commonModes)
			}
	}

	func grantBonusLife()
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		numberOfLives += 1
		appDelegate.gameScreenViewController!.updateLives(livesRemaining: numberOfLives)
		Analytics.logEvent("AwardedBonusLife", parameters: [AnalyticsParameterValue: numberOfLives])
	}

	func checkForHighScore() -> Bool
	{
		if currentScore == 0
			{
			return false
			}
		let highScoresEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemHighScores, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [Dictionary<String, Any>])
		let highScores = highScoresEntry.value
		let lowestHighScore = highScores.last
		let lowestHighScoreValue = lowestHighScore![ConfigurationManager.highScoreEntryFieldScore] as! NSNumber
		if lowestHighScoreValue.intValue > currentScore
			{
			return false
			}
		else
			{
			return true
			}
	}
}
