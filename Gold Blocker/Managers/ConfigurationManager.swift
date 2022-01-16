/*******************************************************************************
* ConfigurationManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for application
*						configuration
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*     05/05/18             *       EGC *      Adding Easy Mode
********************************************************************************
*/

import Foundation
import UIKit

class ConfigurationManager
{
	// Assets
	static let defaultGameboardFilename = "GameboardSet1"
	static let defaultSpriteFilename = "SpriteSetSmall"
	static let alternateSpriteFilename = "SpriteSetLarge"
	static let defaultIntroFilename = "Intro"
	static let defaultPlayerGetGoldFilename = "PlayerGetGold"
	static let defaultSentryGetGoldFilename = "SentryGetGold"
	static let defaultRaiseStasisFieldFilename = "RaiseStasisField"
	static let defaultLowerStasisFieldFilename = "LowerStasisField"
	static let defaultTeleporterFilename = "Teleporter"
	static let defaultPlayerCaughtFilename = "PlayerCaught"
	static let defaultEscapeLadderFilename = "EscapeLadder"
	static let defaultWinLevelFilename = "WinLevel"
	static let defaultExtraLifeFilename = "ExtraLife"
	static let defaultHighScoreFilename = "HighScore"

	// Spriteset
	static let spriteSetDefaultHeader = [0x45, 0x47, 0x47] as [UInt8]
	static let spriteDelineator = [0x80, 0x81, 0x79, 0x82, 0x78] as [UInt8]
	static let spriteSectionHeaderDelineator = [0x26, 0x48] as [UInt8]
	static let spriteSectionIdentifierDelineator = [0x26, 0x49] as [UInt8]
	static let spriteSectionAnimationDelineator = [0x26, 0x41] as [UInt8]
	static let spriteSectionDimensionsDelineator = [0x26, 0x44] as [UInt8]
	static let spriteSectionBackgroundColorDelineator = [0x26, 0x42] as [UInt8]
	static let spriteSectionPixelMapDelineator = [0x26, 0x50] as [UInt8]
	static let spriteSectionPixelMaskDelineator = [0x26, 0x4D] as [UInt8]

	// GameboadSet
	static let gameboardSetDefaultHeader = [0x45, 0x47, 0x43] as [UInt8]
	static let gameboardDelineator = [0x78, 0x82, 0x79, 0x81, 0x80] as [UInt8]
	static let gameboardSectionHeaderDelineator = [0x26, 0x48] as [UInt8]
	static let gameboardSectionIdentifierDelineator = [0x26, 0x49] as [UInt8]
	static let gameboardSectionDimensionsDelineator = [0x26, 0x44] as [UInt8]
	static let gameboardSectionTileMapDelineator = [0x26, 0x50] as [UInt8]

	// Basic game settings
	static let defaultStartLevel = 1
	static let defaultStartingNumberOfLives = 4
	static let makeBlackPixelsTransparent = true
	static let gameUpdateLoopTimerDelay = 0.03
	static let postDeathDelay = 1
	static let postLevelWinDelay = 3.0
	static let postLastLevelWinDelay = 1.0
	static let pauseOverlayAlpha = 0.70 as CGFloat
	static let pauseLabelFontSize = 17.0 as CGFloat
	static let gameboardImageViewTag = 99
	static let gameboardImageViewLevelNumberTag = 77
	static let gameboardImageViewLevelNameTag = 88

	// Game-specific sprite asset info
	static let playerSpriteIndex = 19
	static let guardSpriteIndex = 25
	static let platformSpriteIndex = 7
	static let teleporterSpriteIndex = 14
	static let goldBarSpriteIndex = 33
	static let stasisFieldSpriteIndex = 54
	static let darkBackgroundTiles = [0, 3, 5]
	static let lightBackgroundTiles = [1, 4, 6]
	static let steelGirderTile = 2
	static let ladderTileDarkBackground = 3
	static let ladderTileLightBackground = 4
	static let tileDarkBackground = 0
	static let tileLightBackground = 1

	// Sprite characteristics
	static let spriteHeaderTraversable = 0x01 as UInt8
	static let spriteHeaderClimable = 0x02 as UInt8
	static let spriteHeaderHangable = 0x04 as UInt8
	static let spriteHeaderFallthroughable = 0x08 as UInt8

	// Sprite attributes
	static let exitLadderBaseTileHeaderValue = 0x80 as UInt8
	static let platformStoppableHeaderValue = 0x01 as UInt8
	static let platformHorizontalHeaderValue = 0x20 as UInt8
	static let platformVerticalHeaderValue = 0x40 as UInt8
	static let platformSlowSpeedHeaderValue = 0x04 as UInt8
	static let platformModerateSpeedHeaderValue = 0x08 as UInt8
	static let platformFastSpeedHeaderValue = 0xf0 as UInt8
	static let platformLongWaitHeaderValue = 0x20 as UInt8
	static let platformModerateWaitHeaderValue = 0x40 as UInt8
	static let platformShortWaitHeaderValue = 0x80 as UInt8
	static let platformInitialDirectionLeft = 0x02 as UInt8
	static let platformInitialDirectionUp = 0x01 as UInt8
	static let teleporterRoundTrippableValue = 0x02 as UInt8
	static let teleporterSendableHeaderValue = 0x04 as UInt8
	static let teleporterReceivableHeaderValue = 0x08 as UInt8
	static let teleporterPairableHeaderValue = 0x10 as UInt8

	// Platforms
	static let platformSpeedAttributeMask = 0x18 as UInt8
	static let platformWaitAttributeMask = 0xe0 as UInt8
	static let platformDefaultWaitTime = 2.0 as TimeInterval
	static let platformSpeedSlowMultiplier = 1
	static let platformSpeedModerateMultiplier = 2
	static let platformSpeedFastMultiplier = 3
	static let platformWaitShortMultiplier = 1.0
	static let platformWaitModerateMultiplier = 2.0
	static let platformWaitLongMultiplier = 3.0

	// Teleporters
	static let cyclesToSkipBetweenTeleporterFrames = 3

	// Character movement
	static let playerXAxisSteps = 2
	static let playerYAxisSteps = 2
	static let playerFallingSteps = 1
	static let guardXAxisSteps = 1
	static let guardYAxisSteps = 1
	static let platformXAxisSteps = 1
	static let platformYAxisSteps = 1

	// Guard behaviors
	static let optionsForGuardSmartBehavior = 20
	static let guardPossibleRandomDirections = 4

	// Character control
	static let defaultControlType = ControlView.ControlType.Tap
	static let defaultMultiControlButtonProximityPercent = 10
	static let defaultControllerCenterDeadRadius = 40.0
	static let defaultControllerSideLength = 293.0

	// Stasis fields
	static let stasisFieldDuration = 4.0 as TimeInterval
	static let stasisFieldBlockingStage = 3
	static let stasisFieldAlpha = 0.75 as CGFloat

	// Player Collision Detection
	static let guardCollisionXAxisOverlap = 4
	static let guardCollisionYAxisOverlap = 4

	// Game stats
	static let pointsPerGoldBar = 100
	static let pointsPerLevelBeaten = 1000
	static let pointsPerAdditionalLife = 5000

	// Persistence Manager
	static let persistencElementValue = "Value"
	static let persistencElementType = "Type"
	static let persistencElementSource = "Source"
	static let persistencElementProtection = "Protection"
	static let persistencElementLifespan = "Lifespan"
	static let persistencElementExpiration = "Expiration"
	static let persistenceManagementExpiringItems = "ExpiringItems"
	static let persistenceExpirationItemName = "ExpiringItemName"
	static let persistenceExpirationItemExpirationDate = "ExpiringItemExpirationDate"
	static let timerPeriodPersistenceExpirationCheck = 60.0

	// High Scores
	static let persistenceItemHighScores = "High Scores"
	static let numberHighScoresDisplayed = 10
	static let highScoreEntryFieldScore = "Score"
	static let highScoreEntryFieldName = "Name"
	static let highScoreEntryWidth = 300.0 as CGFloat
	static let highScoreEntryHeight = 22.0 as CGFloat
	static let highScoreFontHeight = 16.0 as CGFloat
	static let highScoreRankFieldWidth = 42.0 as CGFloat
	static let highScoreScoreFieldWidth = 60.0 as CGFloat
	static let highScoreNameFieldWidth = 178.0 as CGFloat
	static let highScoreFieldBufferWidth = 8.0 as CGFloat
	static let highScoreAnimationFrameUpdateDelay = 0.03 as TimeInterval

	// Title
	static let titleAlphaIncrementValue = 0.03
	static let titleAnimationTimerDelay = 0.06
	static let titleEndTimerDelay = 3.0

	// Reveal Curtain
	static let revealCurtainTimerDelay = 0.03 as TimeInterval
	static let revealImageWidth = 300
	static let revealImageHeight = 200
	static let revealCurtainWidth = 600
	static let revealCurtainHeight = 400
	static let revealSpotlightStartingWidth = 12
	static let revealSpotlightStartingHeight = 8
	static let revealSpotlightXAxisSteps = 6
	static let revealSpotlightYAxisSteps = 4

	// Game Screen Layout
	static let defaultLayoutType = GameScreenViewController.GameScreenLayoutScheme.Horizontal1

	// Settings
	static let persistenceItemControlScheme = "Control Scheme"
	static let persistenceItemLayoutScheme = "Layout Scheme"
	static let persistenceItemPlaySounds = "Play Sounds"
	static let persistenceItemPlayIntro = "Play Intro"
	static let persistenceItemSkipPlayedLevelsIntro = "Skip Played Levels Intro"
    static let persistenceItemEasyMode = "Easy Mode"
	static let persistenceItemStartLevel = "Start Level"
	static let persistenceItemUnlockAll = "Unlock All Levels"
	static let defaultPlaySoundsValue = true
	static let defaultPlayIntroValue = true
	static let defaultSkipPlayedLevelsIntro = false
	static let defaultUnlockAllLevels = false
    static let defaultEasyModeValue = false
	static let defaultSettingsControlLayoutRowHeight = 294.0 as CGFloat
	static let defaultSettingsNumLayoutConfigurations = 6
	static let defaultSettingsStartLevelRowHeight = 250 as CGFloat
	static let defaultSettingsGetExtrasRowHeight = 56 as CGFloat
	static let defaultNumProductsToQuery = 18
	static let defaultGameScreenWidth = 300.0 as CGFloat
	static let defaultGameScreenHeight = 200.0 as CGFloat

	// Tutorial
	static let numberTutorialSegments = 5
	static let spriteAnimationLoopTimerDelay = 0.15

	// Dynamic Game Data
	static let persistenceItemAuthorizedLevels = "Authorized Levels"
	static let persistenceItemPlayedLevels = "Played Levels"
    static let persistenceItemBeatenLevels = "Beaten Levels"
	static let persistenceItemGameboardNumber = "Gameboard Number"
	static let persistenceItemGameboardName = "Gameboard Name"

	// In-App Purchases
	static let persistenceItemPurchasedItems = "Purchased Items"
	static let persistenceItemDownloadItem = "SKDownload"
	static let unlockAllLevelsIdentifier = "LR_0002"
	static let unlockAllLevelsPlusComboIdentifiers = ["LR_0002", "LR_0008", "LR_0015", "LR_0017"]
	static let comboIdentifiers = ["LR_0007", "LR_0008", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]
	static let gameboardSet2ProductIdentifiers = ["LR_0003", "LR_0007", "LR_0008", "LR_0016", "LR_0017"]
	static let gameboardSet3ProductIdentifiers = ["LR_0004", "LR_0007", "LR_0008", "LR_0016", "LR_0017"]
	static let gameboardSet4ProductIdentifiers = ["LR_0005", "LR_0007", "LR_0008", "LR_0016", "LR_0017"]
	static let gameboardSet5ProductIdentifiers = ["LR_0006", "LR_0007", "LR_0008", "LR_0016", "LR_0017"]
	static let gameboardSet6ProductIdentifiers = ["LR_0009", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]
	static let gameboardSet7ProductIdentifiers = ["LR_0010", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]
	static let gameboardSet8ProductIdentifiers = ["LR_0011", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]
	static let gameboardSet9ProductIdentifiers = ["LR_0012", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]
	static let gameboardSet10ProductIdentifiers = ["LR_0013", "LR_0014", "LR_0015", "LR_0016", "LR_0017"]

	// Device-specific settings
	static let iPadTopConstraintOffset = 100.0 as CGFloat
	static let iPadBottomConstraintOffset = 80.0 as CGFloat
	static let iPhoneTopConstraintOffset = 0.0 as CGFloat
	static let iPhoneBottomConstraintOffset = 20.0 as CGFloat
	static let iPadGameScreenXAxisMargins = 20.0 as CGFloat

	// Contact
	static let defaultContactEmail = "lootraider@infusionsofgrandeur.com"

	var currentControlScheme : ControlView.ControlType
	var currentLayoutScheme : GameScreenViewController.GameScreenLayoutScheme
	var playSounds = defaultPlaySoundsValue
	var playIntros = defaultPlayIntroValue
	var skipPlayedLevelIntros = defaultSkipPlayedLevelsIntro
    var easyMode = defaultEasyModeValue
	var currentStartLevel = defaultStartLevel
	var unlockAllLevels = defaultUnlockAllLevels

	static let sharedManager = ConfigurationManager()

	init()
	{
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemControlScheme, from: .UserDefaults)
			{
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemControlScheme, value: NSNumber(value: ConfigurationManager.defaultControlType.rawValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let currentControlSchemeValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemControlScheme, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		currentControlScheme = ControlView.ControlType(rawValue: currentControlSchemeValue.value.intValue)!
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemLayoutScheme, from: .UserDefaults)
			{
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemLayoutScheme, value: NSNumber(value: ConfigurationManager.defaultLayoutType.rawValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let currentLayoutSchemeValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemLayoutScheme, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		currentLayoutScheme = GameScreenViewController.GameScreenLayoutScheme(rawValue: currentLayoutSchemeValue.value.intValue)!
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPlaySounds, from: .UserDefaults)
			{
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlaySounds, value: NSNumber(value: ConfigurationManager.defaultPlaySoundsValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let currentPlaySoundsValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPlaySounds, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		playSounds = currentPlaySoundsValue.value.boolValue
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPlayIntro, from: .UserDefaults)
			{
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlayIntro, value: NSNumber(value: ConfigurationManager.defaultPlayIntroValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let currentPlayIntrosValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPlayIntro, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		playIntros = currentPlayIntrosValue.value.boolValue
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemSkipPlayedLevelsIntro, from: .UserDefaults)
			{
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemSkipPlayedLevelsIntro, value: NSNumber(value: ConfigurationManager.defaultSkipPlayedLevelsIntro), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let currentSkipPlayedIntrosValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemSkipPlayedLevelsIntro, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		skipPlayedLevelIntros = currentSkipPlayedIntrosValue.value.boolValue
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemStartLevel, from: .UserDefaults)
			{
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemStartLevel, value: NSNumber(value: ConfigurationManager.defaultStartLevel), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
        if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemEasyMode, from: .UserDefaults)
            {
                PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemEasyMode, value: NSNumber(value: ConfigurationManager.defaultEasyModeValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
            }
        let currentEasyModeValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemEasyMode, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
        easyMode = currentEasyModeValue.value.boolValue
		let currentStartLevelValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemStartLevel, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		currentStartLevel = currentStartLevelValue.value.intValue
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemUnlockAll, from: .UserDefaults)
			{
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemUnlockAll, value: NSNumber(value: ConfigurationManager.defaultUnlockAllLevels), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let unlockAllLevelsValue = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemUnlockAll, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: NSNumber)
		unlockAllLevels = unlockAllLevelsValue.value.boolValue
	}

	func setControlType(newType: ControlView.ControlType)
	{
		currentControlScheme = newType
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemControlScheme, value: NSNumber(value: newType.rawValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getControlType() -> ControlView.ControlType
	{
		return currentControlScheme
	}

	func setLayoutScheme(newScheme: GameScreenViewController.GameScreenLayoutScheme)
	{
		currentLayoutScheme = newScheme
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemLayoutScheme, value: NSNumber(value: newScheme.rawValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		if appDelegate.viewsConstructed
		{
			appDelegate.resetGameScreenViewController()
		}
	}

	func getLayoutType() -> GameScreenViewController.GameScreenLayoutScheme
	{
		return currentLayoutScheme
	}

	func setPlaySounds(newValue: Bool)
	{
		playSounds = newValue
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlaySounds, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getPlaySounds() -> Bool
	{
		return playSounds
	}

	func setPlayIntros(newValue: Bool)
	{
		playIntros = newValue
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlayIntro, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getPlayIntros() -> Bool
	{
		return playIntros
	}

	func setSkipPlayedLevelIntros(newValue: Bool)
	{
		skipPlayedLevelIntros = newValue
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemSkipPlayedLevelsIntro, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getSkipPlayedLevelIntros() -> Bool
	{
		return skipPlayedLevelIntros
	}

    func setEasyMode(newValue: Bool)
    {
        easyMode = newValue
        PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemEasyMode, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
    }

    func getEasyMode() -> Bool
    {
        return easyMode
    }

	func setStartLevel(newValue: Int)
	{
		currentStartLevel = newValue
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemStartLevel, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getStartLevel() -> Int
	{
		return currentStartLevel
	}

	func setUnlockAllLevels(newValue: Bool)
	{
		unlockAllLevels = newValue
		PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemUnlockAll, value: NSNumber(value: newValue), type: .Number, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
	}

	func getUnlockAllLevels() -> Bool
	{
		return unlockAllLevels
	}

	func addAuthorizedLevel(number : Int, name: String)
	{
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, from: .UserDefaults)
			{
			let authorizedLevel = [ConfigurationManager.persistenceItemGameboardNumber: number, ConfigurationManager.persistenceItemGameboardName: name] as [String : Any]
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, value: [authorizedLevel], type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		else
			{
			let authorizedLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [[String : Any]])
			var authorizedLevels = authorizedLevelsEntry.value
			var addEntry = true
			for nextEntry in authorizedLevels
				{
				let entryNumber = nextEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
				if entryNumber == number
					{
					addEntry = false
					break
					}
				}
			if addEntry
				{
				let authorizedLevel = [ConfigurationManager.persistenceItemGameboardNumber: number, ConfigurationManager.persistenceItemGameboardName: name] as [String : Any]
				authorizedLevels.append(authorizedLevel)
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, value: authorizedLevels, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
				}
			}
	}

	func getLastLevelNumber() -> Int
	{
		let authorizedLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [[String : Any]])
		let authorizedLevels = authorizedLevelsEntry.value
		var sortedAuthorizedLevelsList = [[String: Any]]()
		for nextLevelEntry in authorizedLevels
			{
			let entryLevel = nextLevelEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
			var inserted = false
			var index = 0
			for nextAuthEntry in sortedAuthorizedLevelsList
				{
				let nextAuthEntryLevel = nextAuthEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
				if entryLevel < nextAuthEntryLevel
					{
					sortedAuthorizedLevelsList.insert(nextLevelEntry, at: index)
					inserted = true
					break
					}
				index += 1
				}
			if !inserted
				{
				sortedAuthorizedLevelsList.append(nextLevelEntry)
				}
			}
		return sortedAuthorizedLevelsList.last![ConfigurationManager.persistenceItemGameboardNumber] as! Int
	}

	func addPurchasedItem(identifier: String)
	{
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults)
			{
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPurchasedItems, value: [identifier], type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		else
			{
			let purchasedItemsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			var purchasedItems = purchasedItemsEntry.value
			var addItem = true
			for nextItem in purchasedItems
				{
				if nextItem == identifier
					{
					addItem = false
					break
					}
				}
			if addItem
				{
				purchasedItems.append(identifier)
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPurchasedItems, value: purchasedItems, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
				}
			}
	}

	func getPurchasedItems() -> [String]
	{
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults)
			{
				return []
			}
		else
			{
			let purchasedItemsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			let purchasedItems = purchasedItemsEntry.value
			return purchasedItems
			}
	}

	func checkForLevelOwned(identifier: String) -> Bool
	{
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults)
			{
			return false
			}
		else
			{
			let purchasedItemsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			let purchasedItems = purchasedItemsEntry.value
			for nextItem in purchasedItems
				{
				if nextItem == identifier
					{
					return true
					}
				}
			return false
			}

	}

	func fileExistsForProductIdentifier(identifier: String) -> Bool
	{
		let filename = filenameForProductIdentifier(identifier: identifier)
		let filePath = NSHomeDirectory() + "/Documents/\(filename)"
		if FileManager.default.fileExists(atPath: filePath)
			{
			return true
			}
		else
			{
			return false
			}
	}

	func filenameForProductIdentifier(identifier: String) -> String
	{
		var filename = "GameboardSet"
		if ConfigurationManager.gameboardSet2ProductIdentifiers.contains(identifier)
			{
			filename += "2"
			}
		else if ConfigurationManager.gameboardSet3ProductIdentifiers.contains(identifier)
			{
			filename += "3"
			}
		else if ConfigurationManager.gameboardSet4ProductIdentifiers.contains(identifier)
			{
			filename += "4"
			}
		else if ConfigurationManager.gameboardSet5ProductIdentifiers.contains(identifier)
			{
			filename += "5"
			}
		else if ConfigurationManager.gameboardSet6ProductIdentifiers.contains(identifier)
			{
			filename += "6"
			}
		else if ConfigurationManager.gameboardSet7ProductIdentifiers.contains(identifier)
			{
			filename += "7"
			}
		else if ConfigurationManager.gameboardSet8ProductIdentifiers.contains(identifier)
			{
			filename += "8"
			}
		else if ConfigurationManager.gameboardSet9ProductIdentifiers.contains(identifier)
			{
			filename += "9"
			}
		else if ConfigurationManager.gameboardSet10ProductIdentifiers.contains(identifier)
			{
			filename += "10"
			}
		return filename
	}
}
