/*******************************************************************************
* GameScreenViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's game screen in portrait view mode
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/03/18		*	EGC	*	File creation date
*	01/05/20		*	EGC	*	Modifications to drawing routines to fix iOS 13 crashes
*     04/23/20             *       EGC *       Adding game controller support
*	11/19/21		*	EGC	*	Adding Easy Mode
********************************************************************************
*/

import UIKit
import FirebaseAnalytics
import GameController

class GameScreenViewController: UIViewController, ControlDelegate
{

	@IBOutlet weak var leftBlockButton: UIButton!
	@IBOutlet weak var rightBlockButton: UIButton!
	@IBOutlet weak var gameBoardView: UIView!
	@IBOutlet weak var controlView: ControlView!
	@IBOutlet weak var controlImageView: UIImageView!
	@IBOutlet weak var scoreDisplay: UILabel!
	@IBOutlet weak var livesDisplay: UILabel!
	@IBOutlet weak var curtainImageView: UIImageView!
	@IBOutlet weak var levelNameLabel: UILabel!
	@IBOutlet weak var levelNumberLabel: UILabel!
	@IBOutlet weak var pauseButton: UIButton!
	@IBOutlet weak var quitButton: UIButton!
	@IBOutlet weak var verticalControlImageView: UIImageView!
	@IBOutlet weak var verticalControlView: ControlView!
	@IBOutlet weak var horizontalControlImageView: UIImageView!
	@IBOutlet weak var horizontalControlView: ControlView!
	@IBOutlet weak var gameBoardViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var gameBoardViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var gameBoardViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var curtainViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var curtainViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var curtainViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var gameBoardViewTrailingConstraint: NSLayoutConstraint!
	@IBOutlet weak var gameBoardViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var curtainCenterConstraint: NSLayoutConstraint!
	
	enum GameScreenLayoutScheme : Int
	{
		case Vertical
		case Horizontal1		// Combined buttons, right
		case Horizontal2		// Combined buttons, left
		case Horizontal3		// Split buttons, horizontal buttons right
		case Horizontal4		// Split buttons, horizontal buttons left
		case Horizontal5		// D-Pad style, directional controls on left, action buttons on right
	}

	private var currentLevel : Gameboard!
	private var gameLoopTimer : Timer!
	private var entityIdentifier = 0
	private var imageViewsForEntities = [Int : UIImageView]()
	private var escapeLadderOriginalTiles = [UIImageView: (x: Int, y: Int, tile: Int, attributes: [UInt8])]()
	private var escapeLadderBackgroundTileViews = [UIImageView]()
	private var escapeLadderRevealed = false
	private var revealCurtainDismissView : UIView?
	private var revealCurtainGestureRecognizer : UITapGestureRecognizer?
	private var revealCurtainProgressTimer : Timer?
	private var revealTitleProgressTimer : Timer?
	private var revealCurtainPullLevel = 0
	private var background : UIImage?
	private var spotlight : UIImage?
	private var curtain : UIImageView?
	private var levelNumberAlpha = 0.0
	private var levelNameAlpha = 0.0
	private var ignoreInput = false
	private var pauseView : UIImageView?
	private var xAxisMultiplicationFactor = 1.0 as CGFloat
	private var yAxisMultiplicationFactor = 1.0 as CGFloat
	private var scaledCurtainImageView : UIImageView?

	// Need to maintain state of inner image behind reveal curtain
	private var gameboardSourceX : Int?
	private var gameboardSourceY : Int?
	private var gameboardDrawX = 0
	private var gameboardDrawY = 0
	private var gameboardSizeX = 0
	private var gameboardSizeY = 0
	private var startX = 0
	private var startY = 0
	private var sizeX = 0
	private var sizeY = 0
	private var scaledRevealCurtainWidth = 0
	private var scaledRevealCurtainHeight = 0
	private var autoWidth = 0.0 as CGFloat

    // For Easy Mode
    private var skipGuardUpdate = false

	// MARK: Lifecycle Methods

	override func viewDidLoad()
    {
        super.viewDidLoad()
		if controlImageView != nil
			{
			controlView.setControlType(type: ControlView.ControlType.Tap)
			controlView.setControlSet(set: ControlView.ControlSet.BothAxes)
			controlView.delegate = self
			controlImageView.image = UIImage(named: "ButtonsNonePressed")
			}
		if horizontalControlImageView != nil && verticalControlImageView != nil
			{
			horizontalControlView.setControlType(type: ControlView.ControlType.Tap)
			horizontalControlView.setControlSet(set: ControlView.ControlSet.Horizontal)
			horizontalControlView.delegate = self
			horizontalControlImageView.image = UIImage(named: "ArrowsLeftRightEmpty")
			verticalControlView.setControlType(type: ControlView.ControlType.Tap)
			verticalControlView.setControlSet(set: ControlView.ControlSet.Vertical)
			verticalControlView.delegate = self
			verticalControlImageView.image = UIImage(named: "ArrowsUpDownEmpty")
			}
		levelNameLabel.isHidden = true
		levelNumberLabel.isHidden = true
		pauseButton.isEnabled = false
		quitButton.isEnabled = false
    }

	override func viewWillAppear(_ animated: Bool)
	{
		for subview in gameBoardView.subviews
			{
			if subview.tag != ConfigurationManager.gameboardImageViewLevelNumberTag && subview.tag != ConfigurationManager.gameboardImageViewLevelNameTag
				{
				subview.removeFromSuperview()
				break
				}
			}
		curtainImageView.image = background
		if scaledCurtainImageView != nil
			{
			scaledCurtainImageView!.image = background
			}
		gameBoardView.isHidden = true
	}

	override func viewDidAppear(_ animated: Bool)
	{
		let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
		let level = GameStateManager.sharedManager.getCurrentLevel() - 1
		currentLevel = GameboardManager.sharedManager.getGameboard(number: level)
		if UIDevice.current.userInterfaceIdiom == .pad
			{
			// This particular case, where control scheme is vertical but tablet is in landscape, is the one we can't seem to control, ignore it and leave the game screen small
			if (layoutScheme == .Vertical && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight))
				{
					let gameboardViewWidth = ConfigurationManager.defaultGameScreenWidth
					let gameboardViewHeight = ConfigurationManager.defaultGameScreenHeight
					gameBoardViewWidthConstraint.constant = gameboardViewWidth
					gameBoardView.frame = CGRect(x: ConfigurationManager.iPadGameScreenXAxisMargins, y: (self.view.frame.size.height - gameboardViewHeight) / 2, width: gameboardViewWidth, height: gameboardViewHeight)
					gameBoardViewHeightConstraint.constant = gameboardViewHeight
					xAxisMultiplicationFactor = gameboardViewWidth / ConfigurationManager.defaultGameScreenWidth
					yAxisMultiplicationFactor = gameboardViewHeight / ConfigurationManager.defaultGameScreenHeight
				}
			else
				{
				if layoutScheme == .Vertical
					{
					// First adjust the gameboard view
					let gameboardViewWidth = ConfigurationManager.defaultGameScreenWidth * 2
					let gameboardViewHeight = ConfigurationManager.defaultGameScreenHeight * 2
					gameBoardViewWidthConstraint.constant = gameboardViewWidth
					gameBoardView.frame = CGRect(x: ConfigurationManager.iPadGameScreenXAxisMargins, y: (self.view.frame.size.height - gameboardViewHeight) / 2, width: gameboardViewWidth, height: gameboardViewHeight)
					gameBoardViewHeightConstraint.constant = gameboardViewHeight
					xAxisMultiplicationFactor = gameboardViewWidth / ConfigurationManager.defaultGameScreenWidth
					yAxisMultiplicationFactor = gameboardViewHeight / ConfigurationManager.defaultGameScreenHeight
					// Then adjust the curtain view
					let curtainWidth = gameboardViewWidth * 2
					let curtainHeight = gameboardViewHeight * 2
					let topConstraint = gameBoardViewTopConstraint.constant - ((curtainHeight - gameboardViewHeight) / 2) + CGFloat(80)
					curtainViewWidthConstraint.constant = curtainWidth
					curtainViewHeightConstraint.constant = curtainHeight
					curtainViewTopConstraint.constant = topConstraint * -1
					scaledRevealCurtainWidth = Int(curtainWidth)
					scaledRevealCurtainHeight = Int(curtainHeight)
					}
				else if layoutScheme == .Horizontal1 || layoutScheme == .Horizontal2
					{
					if autoWidth == 0
					 	{
					 	 autoWidth = gameBoardView.frame.size.width
					 	}
					let gameboardViewWidth = ConfigurationManager.defaultGameScreenWidth * 2
					let gameboardViewHeight = ConfigurationManager.defaultGameScreenHeight * 2
					let xAxisMargin = (autoWidth - gameboardViewWidth) / 2 + 14		// TODO: Figure out a formula that doesn't require magic numbers for adjustment
					gameBoardViewHeightConstraint.constant = gameboardViewHeight
					gameBoardViewTrailingConstraint.constant = xAxisMargin
					gameBoardViewLeadingConstraint.constant = xAxisMargin
					curtainCenterConstraint.constant = CGFloat(80)		// TODO: Figure out a formula that doesn't require magic numbers for adjustment
					xAxisMultiplicationFactor = gameboardViewWidth / ConfigurationManager.defaultGameScreenWidth
					yAxisMultiplicationFactor = gameboardViewHeight / ConfigurationManager.defaultGameScreenHeight
					// Then adjust the curtain view
					let curtainWidth = gameboardViewWidth * 2
					let curtainHeight = gameboardViewHeight * 2
					curtainViewWidthConstraint.constant = curtainWidth
					curtainViewHeightConstraint.constant = curtainHeight
					scaledRevealCurtainWidth = Int(curtainWidth)
					scaledRevealCurtainHeight = Int(curtainHeight)
					}
				else if layoutScheme == .Horizontal3 || layoutScheme == .Horizontal4
					{
					let gameboardViewWidth = self.view.frame.size.width - (horizontalControlView.frame.size.width * 2) - (ConfigurationManager.iPadGameScreenXAxisMargins * 4)
					let gameboardViewHeight = (ConfigurationManager.defaultGameScreenHeight * gameboardViewWidth) / ConfigurationManager.defaultGameScreenWidth
					gameBoardViewWidthConstraint.constant = gameboardViewWidth
					gameBoardView.frame = CGRect(x: ConfigurationManager.iPadGameScreenXAxisMargins, y: (self.view.frame.size.height - gameboardViewHeight) / 2, width: gameboardViewWidth, height: gameboardViewHeight)
					gameBoardViewHeightConstraint.constant = gameboardViewHeight
					xAxisMultiplicationFactor = gameboardViewWidth / ConfigurationManager.defaultGameScreenWidth
					yAxisMultiplicationFactor = gameboardViewHeight / ConfigurationManager.defaultGameScreenHeight
					// Then adjust the curtain view
					let curtainWidth = gameboardViewWidth * 2
					let curtainHeight = gameboardViewHeight * 2
					let topConstraint = gameBoardViewTopConstraint.constant - ((curtainHeight - gameboardViewHeight) / 2) + CGFloat(80)
					curtainViewWidthConstraint.constant = curtainWidth
					curtainViewHeightConstraint.constant = curtainHeight
					curtainViewTopConstraint.constant = topConstraint * -1
					scaledRevealCurtainWidth = Int(curtainWidth)
					scaledRevealCurtainHeight = Int(curtainHeight)
					}
				else if layoutScheme == .Horizontal5
					{
					let gameboardViewWidth = ConfigurationManager.defaultGameScreenWidth * 2
					let gameboardViewHeight = ConfigurationManager.defaultGameScreenHeight * 2
					gameBoardViewWidthConstraint.constant = gameboardViewWidth
					gameBoardView.frame = CGRect(x: ConfigurationManager.iPadGameScreenXAxisMargins, y: (self.view.frame.size.height - gameboardViewHeight) / 2, width: gameboardViewWidth, height: gameboardViewHeight)
					gameBoardViewHeightConstraint.constant = gameboardViewHeight
					xAxisMultiplicationFactor = gameboardViewWidth / ConfigurationManager.defaultGameScreenWidth
					yAxisMultiplicationFactor = gameboardViewHeight / ConfigurationManager.defaultGameScreenHeight
					// Then adjust the curtain view
					let curtainWidth = gameboardViewWidth * 2
					let curtainHeight = gameboardViewHeight * 2
					curtainViewWidthConstraint.constant = curtainWidth
					curtainViewHeightConstraint.constant = curtainHeight
					curtainCenterConstraint.constant = CGFloat(80)		// TODO: Figure out a formula that doesn't require magic numbers for adjustment
					scaledRevealCurtainWidth = Int(curtainWidth)
					scaledRevealCurtainHeight = Int(curtainHeight)
					}
				}
			}
		else
			{
			if layoutScheme == .Horizontal1 || layoutScheme == .Horizontal2 || layoutScheme == .Horizontal5
				{
				// Scale gameboard view if necessary
				let gameboardViewWidth = gameBoardView.frame.size.width
				let gameboardViewHeight = (CGFloat(ConfigurationManager.revealImageHeight) * gameboardViewWidth) / CGFloat(ConfigurationManager.revealImageWidth)
				gameBoardView.frame = CGRect(x: gameBoardView.frame.origin.x, y: (self.view.frame.size.height - gameboardViewHeight) / 2, width: gameboardViewWidth, height: gameboardViewHeight)
				gameBoardViewHeightConstraint.constant = gameboardViewHeight
				xAxisMultiplicationFactor = gameboardViewWidth / CGFloat(ConfigurationManager.revealImageWidth)
				yAxisMultiplicationFactor = gameboardViewHeight / CGFloat(ConfigurationManager.revealImageHeight)
				}
			}
		if UIDevice.current.userInterfaceIdiom == .pad
			{
			xAxisMultiplicationFactor = 1.0
			yAxisMultiplicationFactor = 1.0
			}
		startLevel(skipReveal: false)
	}

	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation
	{
		get
			{
				let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					if layoutScheme == .Vertical
						{
						return .portrait
						}
					else
						{
						return UIInterfaceOrientation.landscapeRight
						}
					}
				else
					{
					if layoutScheme == .Vertical
						{
						return .portrait
						}
					else
						{
						return UIInterfaceOrientation.landscapeRight
						}
					}
			}
	}

	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask
	{
		get
			{
			let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
			if UIDevice.current.userInterfaceIdiom == .pad
				{
				if layoutScheme == .Vertical
					{
					return .portrait
					}
				else
					{
					return UIInterfaceOrientationMask.landscape
					}
				}
			else
				{
				if layoutScheme == .Vertical
					{
					return .portrait
					}
				else
					{
					return UIInterfaceOrientationMask.landscapeRight
					}
				}
			}
	}

	override var shouldAutorotate: Bool
	{
    	return false
	}

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

	// MARK: Game Logic

	@IBAction func fireStasisFieldLeft(_ sender: UIButton)
	{
		if ignoreInput
			{
			return
			}
		let stasisFieldOne = GameStateManager.sharedManager.getStasisFieldOne()
		let stasisFieldTwo = GameStateManager.sharedManager.getStasisFieldTwo()
		let player = GameStateManager.sharedManager.getPlayer()
		let playerX = player.xTile
		let playerY = player.yTile
		var availableStasisField : StasisField?
		if !stasisFieldOne.activated
			{
			if !(stasisFieldTwo.activated && playerX - 1 == stasisFieldTwo.xTile && playerY == stasisFieldTwo.yTile)
				{
				availableStasisField = stasisFieldOne
				}
			}
		else if !stasisFieldTwo.activated
			{
			if !(playerX - 1 == stasisFieldOne.xTile && playerY == stasisFieldOne.yTile)
				{
				availableStasisField = stasisFieldTwo
				}
			}
		if let stasisField = availableStasisField
			{
			if playerX > 0
				{
				let targetTileNumber = currentLevel.tileMap[playerY][playerX - 1]
				let baseTargetTileNumber = currentLevel.tileMap[playerY + 1][playerX - 1]
				let tileSprite = SpriteManager.sharedManager.getSprite(number: targetTileNumber)
				let baseTileSprite = SpriteManager.sharedManager.getSprite(number: baseTargetTileNumber)
				let spriteCharacteristic = tileSprite!.headerData[0]
				let baseSpriteCharacteristic = baseTileSprite!.headerData[0]
				// First, check to see if it's the right kind of tile
				if spriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable && spriteCharacteristic & ConfigurationManager.spriteHeaderHangable == 0 && spriteCharacteristic & ConfigurationManager.spriteHeaderClimable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderHangable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderClimable == 0
					{
					// The check to make sure there's no platform occupying the space
					let platforms = GameStateManager.sharedManager.getPlatforms()
					for nextPlatform in platforms
						{
						if nextPlatform.xTile == playerX - 1 && nextPlatform.yTile == playerY
							{
							return
							}
						}
					// All clear
					stasisField.activate(xPosition: playerX - 1, yPosition: playerY, xAxisMultiplier: xAxisMultiplicationFactor, yAxisMultiplier: yAxisMultiplicationFactor)
					if player.xPos < player.xTile * GameStateManager.sharedManager.getTileWidth()
						{
						player.xPos = player.xTile * GameStateManager.sharedManager.getTileWidth()
						if player.direction == .Left || player.direction == .UpLeft || player.direction == .DownLeft
							{
							player.direction = .Still
							}
						}
					}
				}
			}
	}

	@IBAction func fireStasisFieldRight(_ sender: UIButton)
	{
		if ignoreInput
			{
			return
			}
		let stasisFieldOne = GameStateManager.sharedManager.getStasisFieldOne()
		let stasisFieldTwo = GameStateManager.sharedManager.getStasisFieldTwo()
		let player = GameStateManager.sharedManager.getPlayer()
		let playerX = player.xTile
		let playerY = player.yTile
		var availableStasisField : StasisField?
		if !stasisFieldOne.activated
			{
			if !(stasisFieldTwo.activated && playerX + 1 == stasisFieldTwo.xTile && playerY == stasisFieldTwo.yTile)
				{
				availableStasisField = stasisFieldOne
				}
			}
		else if !stasisFieldTwo.activated
			{
			if !(playerX + 1 == stasisFieldOne.xTile && playerY == stasisFieldOne.yTile)
				{
				availableStasisField = stasisFieldTwo
				}
			}
		if let stasisField = availableStasisField
			{
			if playerX < currentLevel.width - 1
				{
				let targetTileNumber = currentLevel.tileMap[playerY][playerX + 1]
				let baseTargetTileNumber = currentLevel.tileMap[playerY + 1][playerX + 1]
				let tileSprite = SpriteManager.sharedManager.getSprite(number: targetTileNumber)
				let baseTileSprite = SpriteManager.sharedManager.getSprite(number: baseTargetTileNumber)
				let spriteCharacteristic = tileSprite!.headerData[0]
				let baseSpriteCharacteristic = baseTileSprite!.headerData[0]
				// First, check to see if it's the right kind of tile
				if spriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable && spriteCharacteristic & ConfigurationManager.spriteHeaderHangable == 0 && spriteCharacteristic & ConfigurationManager.spriteHeaderClimable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderHangable == 0 && baseSpriteCharacteristic & ConfigurationManager.spriteHeaderClimable == 0
					{
					// The check to make sure there's no platform occupying the space
					let platforms = GameStateManager.sharedManager.getPlatforms()
					for nextPlatform in platforms
						{
						if nextPlatform.xTile == playerX + 1 && nextPlatform.yTile == playerY
							{
							return
							}
						}
					// All clear
					stasisField.activate(xPosition: playerX + 1, yPosition: playerY, xAxisMultiplier: xAxisMultiplicationFactor, yAxisMultiplier: yAxisMultiplicationFactor)
					if player.xPos > player.xTile * GameStateManager.sharedManager.getTileWidth()
						{
						player.xPos = player.xTile * GameStateManager.sharedManager.getTileWidth()
						if player.direction == .Left || player.direction == .UpLeft || player.direction == .DownLeft
							{
							player.direction = .Still
							}
						}
					}
				}
			}
	}

	@IBAction func pauseGame(_ sender: UIButton)
	{
		if gameLoopTimer != nil
			{
			let pause = UILabel()
			pauseView = UIImageView(image: UIImage(named: "Background"))
			pauseView!.frame = gameBoardView.bounds
			pauseView!.alpha = ConfigurationManager.pauseOverlayAlpha
			gameBoardView.addSubview(pauseView!)
			pause.text = "Paused"
			pause.font = UIFont.boldSystemFont(ofSize: ConfigurationManager.pauseLabelFontSize)
			pause.textColor = UIColor.white
			pause.sizeToFit()
			pause.frame = CGRect(x: (pauseView!.frame.size.width - pause.frame.size.width) / 2.0, y: (pauseView!.frame.size.height - pause.frame.size.height) / 2.0, width: pause.frame.size.width, height: pause.frame.size.height)
			pauseView!.addSubview(pause)
			gameLoopTimer.invalidate()
			gameLoopTimer = nil
			Analytics.logEvent("PauseGame", parameters: nil)
			}
		else
			{
			pauseView?.removeFromSuperview()
			pauseView = nil
			gameLoopTimer = Timer(timeInterval: ConfigurationManager.gameUpdateLoopTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.processChanges()})})
			RunLoop.main.add(gameLoopTimer, forMode: RunLoopMode.commonModes)
			Analytics.logEvent("UnpauseGame", parameters: nil)
			}
	}

	@IBAction func quitGame(_ sender: UIButton)
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		Analytics.logEvent("QuitGame", parameters: nil)
		if pauseView != nil
			{
			pauseView!.removeFromSuperview()
			pauseView = nil
			}
		endLevel()
		updateScore(newScore: 0)
		updateLives(livesRemaining: ConfigurationManager.defaultStartingNumberOfLives)
		GameStateManager.sharedManager.resetGameStats()
		appDelegate.gameCenterViewController!.end()
	}

	func startLevel(skipReveal: Bool)
	{
		prepareLevel()
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults)
			{
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlayedLevels, value: [self.currentLevel.identifier!], type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		else
			{
			let playedLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			var playedLevels = playedLevelsEntry.value
			if !playedLevels.contains(self.currentLevel.identifier!)
				{
				playedLevels.append(self.currentLevel.identifier!)
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemPlayedLevels, value: playedLevels, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
				}
			}
		if !skipReveal
			{
			self.revealLevel()
			}
		else
			{
			self.displayLevel()
			DispatchQueue.main.async
				{
				self.leftBlockButton.isEnabled = true
				self.rightBlockButton.isEnabled = true
				self.pauseButton.isEnabled = true
				self.quitButton.isEnabled = true
				self.gameLoopTimer = Timer(timeInterval: ConfigurationManager.gameUpdateLoopTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.processChanges()})})
				RunLoop.main.add(self.gameLoopTimer, forMode: RunLoopMode.commonModes)
				}
			}
// 04-23-20 - EGC - Adding game controller support
		let gameControllers = GCController.controllers()
		if gameControllers.count > 0
			{
			let gameController = gameControllers[0]
			gameController.controllerPausedHandler = {controller in self.pauseGame(self.pauseButton)}
			gameController.extendedGamepad?.valueChangedHandler = {(gamepad, element) in
				if let dpad = element as? GCControllerDirectionPad
					{
					if dpad.up.isPressed && dpad.right.isPressed
						{
						self.directionTapped(direction: .UpRight)
						}
					else if dpad.up.isPressed && dpad.left.isPressed
						{
						self.directionTapped(direction: .UpLeft)
						}
					else if dpad.down.isPressed && dpad.right.isPressed
						{
						self.directionTapped(direction: .DownRight)
						}
					else if dpad.down.isPressed && dpad.left.isPressed
						{
						self.directionTapped(direction: .DownLeft)
						}
					else if dpad.up.isPressed
						{
						self.directionTapped(direction: .Up)
						}
					else if dpad.down.isPressed
						{
						self.directionTapped(direction: .Down)
						}
					else if dpad.left.isPressed
						{
						self.directionTapped(direction: .Left)
						}
					else if dpad.right.isPressed
						{
						self.directionTapped(direction: .Right)
						}
					else if !dpad.up.isPressed && !dpad.down.isPressed && !dpad.left.isPressed && !dpad.right.isPressed
						{
						self.controlReleased()
						}
					}
				else if gamepad.leftTrigger == element
					{
					if gamepad.leftTrigger.isPressed
						{
						self.fireStasisFieldLeft(self.leftBlockButton)
						}
					}
				else if gamepad.buttonX == element
					{
					if gamepad.buttonX.isPressed
						{
						self.fireStasisFieldLeft(self.leftBlockButton)
						}
					}
				else if gamepad.rightTrigger == element
					{
					if gamepad.rightTrigger.isPressed
						{
						self.fireStasisFieldRight(self.rightBlockButton)
						}
					}
				else if gamepad.buttonB == element
					{
					if gamepad.buttonB.isPressed
						{
						self.fireStasisFieldRight(self.leftBlockButton)
						}
					}
				if #available(iOS 13, *)
				{
					if gamepad.buttonOptions == element
						{
						if let buttonOptions = gamepad.buttonOptions
							{
							if buttonOptions.isPressed
								{
								self.pauseGame(self.pauseButton)
								}
							}
						}
					}
				}
			}
	}

	func endLevel()
	{
		let player = GameStateManager.sharedManager.getPlayer()
		let stasis1 = GameStateManager.sharedManager.getStasisFieldOne()
		let stasis2 = GameStateManager.sharedManager.getStasisFieldTwo()
		ignoreInput = true
		if controlImageView != nil
			{
			controlImageView.image = UIImage(named: "ButtonsNonePressed.png")
			}
		else
			{
			horizontalControlImageView.image = UIImage(named: "ArrowsLeftRightEmpty")
			verticalControlImageView.image = UIImage(named: "ArrowsUpDownEmpty")
			}
		leftBlockButton.isEnabled = false
		rightBlockButton.isEnabled = false
		pauseButton.isEnabled = false
		quitButton.isEnabled = false
		player.setDirection(newDirection: .Still)
		if gameLoopTimer != nil
			{
			gameLoopTimer.invalidate()
			}
		gameLoopTimer = nil
		if escapeLadderRevealed
			{
			retractEscapeLadder()
			}
		if stasis1.activated
			{
			stasis1.dissipate()
			}
		if stasis2.activated
			{
			stasis2.dissipate()
			}
	}

	func prepareForNextLevel()
	{
		let level = GameStateManager.sharedManager.getCurrentLevel() - 1
		currentLevel = GameboardManager.sharedManager.getGameboard(number: level)
		gameBoardView.isHidden = true
		for subview in gameBoardView.subviews
			{
			if subview.tag != ConfigurationManager.gameboardImageViewLevelNumberTag && subview.tag != ConfigurationManager.gameboardImageViewLevelNameTag
				{
				subview.removeFromSuperview()
				break
				}
			}
		curtainImageView.image = background
		curtainImageView.isHidden = true
		if scaledCurtainImageView != nil
			{
			scaledCurtainImageView!.image = background
			scaledCurtainImageView!.isHidden = true
			}
	}

	private func resetSprites()
	{
		for (_,imageView) in imageViewsForEntities
			{
			imageView.removeFromSuperview()
			}
		imageViewsForEntities.removeAll()
	}

	private func prepareLevel()
	{
		let tile0 = SpriteManager.sharedManager.getSprite(number: 0)
		GameStateManager.sharedManager.setTileWidth(width: tile0!.width)
		GameStateManager.sharedManager.setTileHeight(height: tile0!.height)
		GameStateManager.sharedManager.resetLevel()
		resetSprites()
		gameboardSourceX = nil
		gameboardSourceY = nil
		gameboardDrawX = 0
		gameboardDrawY = 0
		gameboardSizeX = 0
		gameboardSizeY = 0
		startX = 0
		startY = 0
		sizeX = 0
		sizeY = 0
		for row in 0..<currentLevel.height
			{
			for column in 0..<currentLevel.width
				{
				var attribute = 0 as UInt8
				let spriteNumber = currentLevel.spriteMap[row][column]
				if currentLevel.attributeMap[row][column].count > 0
					{
					attribute = currentLevel.attributeMap[row][column][0]
					}
				if spriteNumber == ConfigurationManager.playerSpriteIndex
					{
					let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
					let imageView = UIImageView(image: image)
					let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
					let newPlayer = Player(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: Entity.Motion.Still, animationFrame: ConfigurationManager.playerSpriteIndex)
					GameStateManager.sharedManager.setPlayer(player: newPlayer)
					imageView.frame = frame
					imageViewsForEntities[newPlayer.entityID] = imageView
					}
				else if spriteNumber == ConfigurationManager.guardSpriteIndex
					{
					let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
					let imageView = UIImageView(image: image)
					let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
					let newGuard = Guard(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: Entity.Motion.Still, animationFrame: ConfigurationManager.guardSpriteIndex)
					GameStateManager.sharedManager.addGuard(defender: newGuard)
					imageView.frame = frame
					imageViewsForEntities[newGuard.entityID] = imageView
					}
				else if spriteNumber == ConfigurationManager.platformSpriteIndex
					{
					let speedAttribute = currentLevel.attributeMap[row][column][1] & ConfigurationManager.platformSpeedAttributeMask
					let waitAttribute = currentLevel.attributeMap[row][column][1] & ConfigurationManager.platformWaitAttributeMask
					var speed = Platform.PlatformSpeed.Slow
					var wait = Platform.PlatformWait.Long
					var direction = Platform.Motion.Still
					if speedAttribute & ConfigurationManager.platformSlowSpeedHeaderValue == ConfigurationManager.platformSlowSpeedHeaderValue
						{
						speed = Platform.PlatformSpeed.Slow
						}
					else if speedAttribute & ConfigurationManager.platformModerateSpeedHeaderValue == ConfigurationManager.platformModerateSpeedHeaderValue
						{
						speed = Platform.PlatformSpeed.Moderate
						}
					else if speedAttribute & ConfigurationManager.platformFastSpeedHeaderValue == ConfigurationManager.platformFastSpeedHeaderValue
						{
						speed = Platform.PlatformSpeed.Fast
						}
					if waitAttribute & ConfigurationManager.platformLongWaitHeaderValue == ConfigurationManager.platformLongWaitHeaderValue
						{
						wait = Platform.PlatformWait.Long
						}
					else if waitAttribute & ConfigurationManager.platformModerateWaitHeaderValue == ConfigurationManager.platformModerateWaitHeaderValue
						{
						wait = Platform.PlatformWait.Moderate
						}
					else if waitAttribute & ConfigurationManager.platformShortWaitHeaderValue == ConfigurationManager.platformShortWaitHeaderValue
						{
						wait = Platform.PlatformWait.Short
						}
					if attribute & ConfigurationManager.platformHorizontalHeaderValue == ConfigurationManager.platformHorizontalHeaderValue
						{
						let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
						let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
						let imageView = UIImageView(image: image)
						let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
						if currentLevel.attributeMap[row][column][1] & ConfigurationManager.platformInitialDirectionLeft == ConfigurationManager.platformInitialDirectionLeft
							{
							direction = Entity.Motion.PlatformLeft
							}
						else
							{
							direction = Entity.Motion.PlatformRight
							}
						let newPlatform = Platform(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: direction, frame: ConfigurationManager.platformSpriteIndex, axis: Platform.TravelAxis.Horizontal, speed: speed, wait: wait)
						GameStateManager.sharedManager.addPlatform(platform: newPlatform)
						imageView.frame = frame
						imageViewsForEntities[newPlatform.entityID] = imageView
						}
					else if attribute & ConfigurationManager.platformVerticalHeaderValue == ConfigurationManager.platformVerticalHeaderValue
						{
						let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
						let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
						let imageView = UIImageView(image: image)
						let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
						if currentLevel.attributeMap[row][column][1] & ConfigurationManager.platformInitialDirectionUp == ConfigurationManager.platformInitialDirectionUp
							{
							direction = Entity.Motion.PlatformUp
							}
						else
							{
							direction = Entity.Motion.PlatformDown
							}
						let newPlatform = Platform(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: direction, frame: ConfigurationManager.platformSpriteIndex, axis: Platform.TravelAxis.Vertical, speed: speed, wait: wait)
						GameStateManager.sharedManager.addPlatform(platform: newPlatform)
						imageView.frame = frame
						imageViewsForEntities[newPlatform.entityID] = imageView
						}
					}
				else if spriteNumber == ConfigurationManager.teleporterSpriteIndex
					{
					let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
					let imageView = UIImageView(image: image)
					let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
					let sendable = attribute & ConfigurationManager.teleporterSendableHeaderValue == ConfigurationManager.teleporterSendableHeaderValue ? true : false
					let receivable = attribute & ConfigurationManager.teleporterReceivableHeaderValue == ConfigurationManager.teleporterReceivableHeaderValue ? true : false
					let roundtrippable = attribute & ConfigurationManager.teleporterRoundTrippableValue == ConfigurationManager.teleporterRoundTrippableValue ? true : false
					let identifier = attribute & ConfigurationManager.teleporterPairableHeaderValue == ConfigurationManager.teleporterPairableHeaderValue ? currentLevel.attributeMap[row][column][1] : nil
					let newTeleporter = Teleporter(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: Entity.Motion.Still, animationFrame: ConfigurationManager.teleporterSpriteIndex, sendable: sendable, receivable: receivable, roundtrippable: roundtrippable, identifier: identifier)
					GameStateManager.sharedManager.addTeleporter(teleporter: newTeleporter)
					imageView.frame = frame
					imageViewsForEntities[newTeleporter.entityID] = imageView
					}
				else if spriteNumber == ConfigurationManager.goldBarSpriteIndex
					{
					let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
					let imageView = UIImageView(image: image)
					let frame = CGRect(x: CGFloat(column * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(row * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * xAxisMultiplicationFactor)
					let newGoldBar = GoldBar(positionX: column * GameStateManager.sharedManager.getTileWidth(), positionY: row * GameStateManager.sharedManager.getTileHeight(), tileX: column, tileY: row, status: Entity.Motion.Still, animationFrame: ConfigurationManager.goldBarSpriteIndex)
					GameStateManager.sharedManager.addGoldBar(gold: newGoldBar)
					imageView.frame = frame
					imageViewsForEntities[newGoldBar.entityID] = imageView
					}
				if attribute & ConfigurationManager.exitLadderBaseTileHeaderValue == ConfigurationManager.exitLadderBaseTileHeaderValue
					{
					GameStateManager.sharedManager.setEscapeLadderBase(x: column, y: row)
					}
				}
			}
        // If in Easy Mode, we need to pull out the last guard
        if ConfigurationManager.sharedManager.getEasyMode()
        {
            let guards = GameStateManager.sharedManager.getGuards()
            if let lastGuard = guards.last
            {
                imageViewsForEntities.removeValue(forKey: lastGuard.entityID)
                GameStateManager.sharedManager.removeLastGuard()
            }
        }
		// Go back through and assign teleporter pairs
		var nextTeleporterEntry = 0
		for row in 0..<currentLevel.height
			{
			for column in 0..<currentLevel.width
				{
				let spriteNumber = currentLevel.spriteMap[row][column]
				if spriteNumber == ConfigurationManager.teleporterSpriteIndex
					{
					let teleporter = GameStateManager.sharedManager.getTeleporters()[nextTeleporterEntry]
					let attribute = currentLevel.attributeMap[row][column][0]
					nextTeleporterEntry = nextTeleporterEntry + 1
					if attribute & ConfigurationManager.teleporterPairableHeaderValue == ConfigurationManager.teleporterPairableHeaderValue
						{
						let pairIdentifier = currentLevel.attributeMap[row][column][2]
						teleporter.pair = GameStateManager.sharedManager.getTeleporterForIdentifier(pair: pairIdentifier)
						}
					}
				}
			}
	}

	private func displayLevel()
	{
		var spriteWidth = 0
		var spriteHeight = 0

		if UIDevice.current.userInterfaceIdiom == .pad
			{
			spriteWidth = GameStateManager.sharedManager.getTileWidth() / 2
			spriteHeight = GameStateManager.sharedManager.getTileHeight() / 2
			}
		else
			{
			spriteWidth = GameStateManager.sharedManager.getTileWidth()
			spriteHeight = GameStateManager.sharedManager.getTileHeight()
			}
		// Clear any previous overlaid images
		for subview in gameBoardView.subviews
			{
			if subview.tag != ConfigurationManager.gameboardImageViewLevelNumberTag && subview.tag != ConfigurationManager.gameboardImageViewLevelNameTag
				{
				subview.removeFromSuperview()
				break
				}
			}
		// Copy tiles to game view
		UIGraphicsBeginImageContext(CGSize(width: currentLevel.width * spriteWidth, height: currentLevel.height * spriteHeight))
		for row in 0..<currentLevel.height
			{
			autoreleasepool
				{
				for column in 0..<self.currentLevel.width
					{
					let tileNumber = self.currentLevel.tileMap[row][column]
					guard tileNumber > -1, let sprite = SpriteManager.sharedManager.getSprite(number: tileNumber)
						else
							{
							continue
							}
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite)
					image.draw(in: CGRect(x: column * spriteWidth, y: row * spriteHeight, width: spriteWidth, height: spriteHeight))
					}
				}
			}
		let levelImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		let imageView = UIImageView(image: levelImage)
		imageView.contentMode = .scaleToFill
		imageView.frame = gameBoardView.bounds
		imageView.tag = ConfigurationManager.gameboardImageViewTag
		gameBoardView.addSubview(imageView)
		// Then overlay the sprites
		let keys = imageViewsForEntities.keys
		for nextKey in keys
			{
			let entityImageView = imageViewsForEntities[nextKey]
			gameBoardView.addSubview(entityImageView!)
			}
	}

	private func revealLevel()
	{
		if shouldBypassReveal()
			{
			levelNameAlpha = 1.0
			levelNumberAlpha = 1.0
			gameBoardView.isHidden = false
			curtainImageView.isHidden = true
			displayLevel()
			DispatchQueue.main.async
				{
				self.dismissRevealCurtain()
				}
			}
		else if !ConfigurationManager.sharedManager.getPlayIntros()
			{
			let title = currentLevel.identifier!
			let pauseDisplayTimer = Timer(timeInterval: ConfigurationManager.titleEndTimerDelay, repeats: false, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.transitionTitleToCurtain()})})
			RunLoop.main.add(pauseDisplayTimer, forMode: RunLoopMode.commonModes)
			levelNameAlpha = 1.0
			levelNumberAlpha = 1.0
			levelNameLabel.alpha = CGFloat(1.0)
			levelNumberLabel.alpha = CGFloat(1.0)
			levelNameLabel.isHidden = false
			levelNumberLabel.isHidden = false
			levelNumberLabel.text = "Level \(GameStateManager.sharedManager.getCurrentLevel())"
			levelNameLabel.text = "\(title)"
			gameBoardView.isHidden = false
			}
		else
			{
			// First, set up the gesture recognizer container view to allow user to dismiss early
			revealCurtainDismissView = UIView(frame: self.view.frame)
			revealCurtainGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissRevealCurtain))
			revealCurtainDismissView!.addGestureRecognizer(revealCurtainGestureRecognizer!)
			self.view.addSubview(revealCurtainDismissView!)
			startTitleReveal()
			}
	}

	private func startTitleReveal()
	{
		let title = currentLevel.identifier!
		levelNumberAlpha = 0.0
		levelNameAlpha = 0.0
		levelNameLabel.alpha = CGFloat(levelNameAlpha)
		levelNumberLabel.alpha = CGFloat(levelNumberAlpha)
		levelNameLabel.isHidden = false
		levelNumberLabel.isHidden = false
		levelNumberLabel.text = "Level \(GameStateManager.sharedManager.getCurrentLevel())"
		levelNameLabel.text = "\(title)"
		gameBoardView.isHidden = false
		revealTitleProgressTimer = Timer(timeInterval: ConfigurationManager.titleAnimationTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.brightenTitle()})})
		RunLoop.main.add(revealTitleProgressTimer!, forMode: RunLoopMode.commonModes)
	}

	private func brightenTitle()
	{
		if levelNumberAlpha >= 1.0
			{
			levelNameAlpha += ConfigurationManager.titleAlphaIncrementValue
			levelNameLabel.alpha = CGFloat(levelNameAlpha)
			}
		else
			{
			levelNumberAlpha += ConfigurationManager.titleAlphaIncrementValue
			levelNumberLabel.alpha = CGFloat(levelNumberAlpha)
			}
		if levelNameAlpha >= 1.0
			{
			revealTitleProgressTimer!.invalidate()
			revealTitleProgressTimer = nil
			let transitionTimer = Timer(timeInterval: ConfigurationManager.titleAnimationTimerDelay, repeats: false, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.transitionTitleToCurtain()})})
			RunLoop.main.add(transitionTimer, forMode: RunLoopMode.commonModes)
			}
	}

	private func transitionTitleToCurtain()
	{
		// Hide title
		levelNameLabel.isHidden = true
		levelNumberLabel.isHidden = true
		// Set up the animation
		background = UIImage(named: "Background.png")
		spotlight = UIImage(named: "Spotlight.png")
		curtainImageView.isHidden = false
		displayLevel()
		DispatchQueue.main.async
			{
			if self.shouldBypassReveal() || !ConfigurationManager.sharedManager.getPlayIntros()
				{
				self.dismissRevealCurtain()
				}
			else
				{
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					self.pullCurtainiPad()
					}
				else
					{
					self.pullCurtainiPhone()
					}
				// Then, start the update timer
				self.revealCurtainPullLevel = 0
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					self.revealCurtainProgressTimer = Timer(timeInterval: ConfigurationManager.revealCurtainTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.pullCurtainiPad()})})
					}
				else
					{
					self.revealCurtainProgressTimer = Timer(timeInterval: ConfigurationManager.revealCurtainTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.pullCurtainiPhone()})})
					}
				RunLoop.main.add(self.revealCurtainProgressTimer!, forMode: RunLoopMode.commonModes)
				}
			}
	}

	private func pullCurtainiPhone()
	{
		let backgroundSize = CGSize(width: CGFloat(ConfigurationManager.revealCurtainWidth), height: CGFloat(ConfigurationManager.revealCurtainHeight))

		if gameboardSourceX == nil || gameboardSourceY == nil
			{
			gameboardDrawX = ConfigurationManager.revealCurtainWidth / 2 - ConfigurationManager.revealSpotlightStartingWidth / 2
			gameboardDrawY = ConfigurationManager.revealCurtainHeight / 2 - ConfigurationManager.revealSpotlightStartingHeight / 2
			gameboardSizeX = ConfigurationManager.revealSpotlightStartingWidth
			gameboardSizeY = ConfigurationManager.revealSpotlightStartingHeight
			gameboardSourceX = (ConfigurationManager.revealImageWidth - gameboardSizeX) / 2
			gameboardSourceY = (ConfigurationManager.revealImageHeight - gameboardSizeY) / 2
			startX = gameboardDrawX
			startY = gameboardDrawY
			sizeX = gameboardSizeX
			sizeY = gameboardSizeY
			}
		else if gameboardSizeX < ConfigurationManager.revealImageWidth || gameboardSizeY < ConfigurationManager.revealImageHeight
			{
			gameboardDrawX -= ConfigurationManager.revealSpotlightXAxisSteps / 2
			gameboardDrawY -= ConfigurationManager.revealSpotlightYAxisSteps / 2
			gameboardSizeX += ConfigurationManager.revealSpotlightXAxisSteps
			gameboardSizeY += ConfigurationManager.revealSpotlightYAxisSteps
			gameboardSourceX! -= ConfigurationManager.revealSpotlightXAxisSteps / 2
			gameboardSourceY! -= ConfigurationManager.revealSpotlightYAxisSteps / 2
			startX -= ConfigurationManager.revealSpotlightXAxisSteps / 2
			startY -= ConfigurationManager.revealSpotlightYAxisSteps / 2
			sizeX += ConfigurationManager.revealSpotlightXAxisSteps
			sizeY += ConfigurationManager.revealSpotlightYAxisSteps
			}
		else
			{
			startX -= ConfigurationManager.revealSpotlightXAxisSteps / 2
			startY -= ConfigurationManager.revealSpotlightYAxisSteps / 2
			sizeX += ConfigurationManager.revealSpotlightXAxisSteps
			sizeY += ConfigurationManager.revealSpotlightYAxisSteps
			}

		UIGraphicsBeginImageContext(backgroundSize)
		// First, draw black background
		background!.draw(in: CGRect(x: 0.0, y: 0.0, width: CGFloat(ConfigurationManager.revealCurtainWidth), height: CGFloat(ConfigurationManager.revealCurtainHeight)))
		// Next, draw just a piece of the gameboard
		var gameboardImageView : UIImageView?
		for subview in gameBoardView.subviews
			{
			if subview.tag == ConfigurationManager.gameboardImageViewTag
				{
				gameboardImageView = subview as? UIImageView
				break
				}
			}
		let gameboardImage = gameboardImageView!.image
		let cgImage = gameboardImage!.cgImage
		let subCGImage = cgImage?.cropping(to: CGRect(x: Int(gameboardSourceX!), y: Int(gameboardSourceY!), width: gameboardSizeX, height: gameboardSizeY))
		let subImage = UIImage(cgImage: subCGImage!)
		subImage.draw(at: CGPoint(x: gameboardDrawX, y: gameboardDrawY))
		// Finally, draw transparent ellipse
		spotlight!.draw(in: CGRect(x: startX, y: startY, width: sizeX, height: sizeY))
		let tempImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		// Now scale the curtain image if need be
		let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
		if layoutScheme == .Horizontal1 || layoutScheme == .Horizontal2 || layoutScheme == .Horizontal5
			{
			let tempCGImage = tempImage!.cgImage
			let croppedImage = tempCGImage!.cropping(to: CGRect(x: startX, y: startY, width: sizeX, height: sizeY))
			let croppedFinalImage = UIImage(cgImage: croppedImage!)
			if scaledCurtainImageView == nil
				{
				scaledCurtainImageView = UIImageView(image: croppedFinalImage)
				scaledCurtainImageView!.contentMode = .scaleToFill
				curtainImageView!.addSubview(scaledCurtainImageView!)
				}
			scaledCurtainImageView!.frame = CGRect(x: (CGFloat(ConfigurationManager.revealCurtainWidth) - (CGFloat(sizeX) * xAxisMultiplicationFactor)) / 2.0, y: (CGFloat(ConfigurationManager.revealCurtainHeight) - (CGFloat(sizeY) * yAxisMultiplicationFactor)) / 2.0, width: CGFloat(sizeX) * xAxisMultiplicationFactor, height: CGFloat(sizeY) * yAxisMultiplicationFactor)
			scaledCurtainImageView!.image = croppedFinalImage
			}
		else
			{
			curtainImageView!.image = tempImage
			}

		revealCurtainPullLevel += 1
		if sizeX >= ConfigurationManager.revealCurtainWidth || sizeY >= ConfigurationManager.revealCurtainHeight
			{
			dismissRevealCurtain()
			}
	}

	private func pullCurtainiPad()
	{
		let backgroundSize = CGSize(width: CGFloat(scaledRevealCurtainWidth), height: CGFloat(scaledRevealCurtainHeight))
		let xAxisScaleFactor = 2.0 as CGFloat
		let yAxisScaleFactor = 2.0 as CGFloat

		if gameboardSourceX == nil || gameboardSourceY == nil
			{
			gameboardDrawX = scaledRevealCurtainWidth / 2 - ConfigurationManager.revealSpotlightStartingWidth / 2
			gameboardDrawY = scaledRevealCurtainHeight / 2 - ConfigurationManager.revealSpotlightStartingHeight / 2
			gameboardSizeX = ConfigurationManager.revealSpotlightStartingWidth
			gameboardSizeY = ConfigurationManager.revealSpotlightStartingHeight
			gameboardSourceX = (ConfigurationManager.revealImageWidth - gameboardSizeX) / 2
			gameboardSourceY = (ConfigurationManager.revealImageHeight - gameboardSizeY) / 2
			startX = gameboardDrawX
			startY = gameboardDrawY
			sizeX = gameboardSizeX
			sizeY = gameboardSizeY
			}
		else if gameboardSizeX < ConfigurationManager.revealImageWidth || gameboardSizeY < ConfigurationManager.revealImageHeight
			{
			gameboardDrawX -= Int((CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor) / 2.0)
			gameboardDrawY -= Int((CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor) / 2.0)
			gameboardSizeX += Int(CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor)
			gameboardSizeY += Int(CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor)
			gameboardSourceX! -= Int((CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor) / 2.0)
			gameboardSourceY! -= Int((CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor) / 2.0)
			startX -= Int((CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor) / 2.0)
			startY -= Int((CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor) / 2.0)
			sizeX += Int(CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor)
			sizeY += Int(CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor)
			}
		else
			{
			startX -= Int((CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor) / 2.0)
			startY -= Int((CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor) / 2.0)
			sizeX += Int(CGFloat(ConfigurationManager.revealSpotlightXAxisSteps) * xAxisScaleFactor)
			sizeY += Int(CGFloat(ConfigurationManager.revealSpotlightYAxisSteps) * yAxisScaleFactor)
			}

		UIGraphicsBeginImageContext(backgroundSize)
		// First, draw black background
		background!.draw(in: CGRect(x: 0.0, y: 0.0, width: CGFloat(scaledRevealCurtainWidth), height: CGFloat(scaledRevealCurtainHeight)))
		// Next, draw just a piece of the gameboard
		var gameboardImageView : UIImageView?
		for subview in gameBoardView.subviews
			{
			if subview.tag == ConfigurationManager.gameboardImageViewTag
				{
				gameboardImageView = subview as? UIImageView
				break
				}
			}
		let gameboardImage = gameboardImageView!.image
		let cgImage = gameboardImage!.cgImage
		let subCGImage = cgImage?.cropping(to: CGRect(x: Int(gameboardSourceX!), y: Int(gameboardSourceY!), width: gameboardSizeX, height: gameboardSizeY))
		let subImage = UIImage(cgImage: subCGImage!)
		subImage.draw(at: CGPoint(x: gameboardDrawX, y: gameboardDrawY))
		// Finally, draw transparent ellipse
		spotlight!.draw(in: CGRect(x: startX, y: startY, width: sizeX, height: sizeY))
		let tempImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		// Now scale the curtain image if need be
		let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
		let tempCGImage = tempImage!.cgImage
		let croppedImage = tempCGImage!.cropping(to: CGRect(x: startX, y: startY, width: sizeX, height: sizeY))
		let croppedFinalImage = UIImage(cgImage: croppedImage!)
		if scaledCurtainImageView == nil
			{
			scaledCurtainImageView = UIImageView(image: croppedFinalImage)
			scaledCurtainImageView!.contentMode = .scaleToFill
			curtainImageView!.addSubview(scaledCurtainImageView!)
			}
		let scaledWidth = CGFloat(CGFloat(sizeX) * xAxisScaleFactor)
		let scaledHeight = CGFloat(CGFloat(sizeY) * yAxisScaleFactor)
		let scaledStartX = CGFloat(scaledRevealCurtainWidth / 2) - CGFloat(scaledWidth) / 2.0
		var scaledStartY = 0.0 as CGFloat
		if layoutScheme == .Vertical
			{
			scaledStartY = CGFloat(scaledRevealCurtainHeight / 2) - CGFloat(scaledHeight) / 2.0 - CGFloat(50)		// TODO: Figure out a formula that doesn't require magic numbers for adjustment
			}
		else
			{
			scaledStartY = CGFloat(scaledRevealCurtainHeight / 2) - CGFloat(scaledHeight) / 2.0 - CGFloat(80)		// TODO: Figure out a formula that doesn't require magic numbers for adjustment
			}
		scaledCurtainImageView!.frame = CGRect(x: scaledStartX, y: scaledStartY, width: scaledWidth, height: scaledHeight)
		scaledCurtainImageView!.image = croppedFinalImage

		revealCurtainPullLevel += 1
		if sizeX >= ConfigurationManager.revealCurtainWidth || sizeY >= ConfigurationManager.revealCurtainHeight
			{
			dismissRevealCurtain()
			}

	}

	@objc private func dismissRevealCurtain()
	{
		if levelNameAlpha < 1.0
			{
			levelNameAlpha = 1.0
			levelNumberAlpha = 1.0
			levelNameLabel.alpha = CGFloat(1.0)
			levelNumberLabel.alpha = CGFloat(1.0)
			revealTitleProgressTimer!.invalidate()
			revealTitleProgressTimer = nil
			transitionTitleToCurtain()
			}
		else
			{
			curtainImageView.isHidden = true
			if revealCurtainProgressTimer != nil
				{
				revealCurtainProgressTimer!.invalidate()
				}
			revealCurtainProgressTimer = nil
			if revealCurtainDismissView != nil
				{
				revealCurtainDismissView!.removeFromSuperview()
				}
			leftBlockButton.isEnabled = true
			rightBlockButton.isEnabled = true
			pauseButton.isEnabled = true
			quitButton.isEnabled = true
			let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
			if layoutScheme == .Horizontal1 || layoutScheme == .Horizontal2 || UIDevice.current.userInterfaceIdiom == .pad
				{
				if scaledCurtainImageView != nil
					{
					scaledCurtainImageView!.image = background
					scaledCurtainImageView!.removeFromSuperview()
					scaledCurtainImageView = nil
					}
				}
			else
				{
				if curtainImageView != nil
					{
					curtainImageView!.image = background
					}
				}
			gameLoopTimer = Timer(timeInterval: ConfigurationManager.gameUpdateLoopTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.processChanges()})})
			RunLoop.main.add(gameLoopTimer, forMode: RunLoopMode.commonModes)
			}
	}

	private func shouldBypassReveal() -> Bool
	{
		if !ConfigurationManager.sharedManager.getSkipPlayedLevelIntros()
			{
			return false
			}
		else
			{
			if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemBeatenLevels, from: .UserDefaults)
				{
				return false
				}
			let beatenLevels = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemBeatenLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			for nextLevel in beatenLevels.value
				{
				if nextLevel == currentLevel!.identifier
					{
					return true
					}
				}
			}
		return false
	}

	private func processChanges()
	{
		let platforms = GameStateManager.sharedManager.getPlatforms()
		let teleporters = GameStateManager.sharedManager.getTeleporters()
		let guards = GameStateManager.sharedManager.getGuards()
		let goldBars = GameStateManager.sharedManager.getGoldBars()
		let player = GameStateManager.sharedManager.getPlayer()
        var processGuards = true    // For Easy Mode

		ignoreInput = false

		for nextTeleporter in teleporters
		{
			let imageView = imageViewsForEntities[nextTeleporter.entityID]!
			nextTeleporter.runCycle(imageView: imageView)
			if xAxisMultiplicationFactor != 1.0 || yAxisMultiplicationFactor != 1.0
				{
				imageView.frame = CGRect(x: CGFloat(nextTeleporter.xPos) * xAxisMultiplicationFactor, y: CGFloat(nextTeleporter.yPos) * yAxisMultiplicationFactor, width: imageView.frame.size.width, height: imageView.frame.size.height)
				}
		}

		for nextPlatform in platforms
		{
			let imageView = imageViewsForEntities[nextPlatform.entityID]!
			nextPlatform.runCycle(imageView: imageView)
			if xAxisMultiplicationFactor != 1.0 || yAxisMultiplicationFactor != 1.0
				{
				imageView.frame = CGRect(x: CGFloat(nextPlatform.xPos) * xAxisMultiplicationFactor, y: CGFloat(nextPlatform.yPos) * yAxisMultiplicationFactor, width: imageView.frame.size.width, height: imageView.frame.size.height)
				}
		}

        if ConfigurationManager.sharedManager.getEasyMode()
        {
            if (skipGuardUpdate)
            {
                processGuards = false
            }
            skipGuardUpdate = !skipGuardUpdate
        }

        if processGuards
        {
            for nextGuard in guards
            {
                let imageView = imageViewsForEntities[nextGuard.entityID]!
                nextGuard.runChasePattern(imageView: imageView)
                nextGuard.detectCollisions(imageView: imageView)
                if xAxisMultiplicationFactor != 1.0 || yAxisMultiplicationFactor != 1.0
                    {
                    imageView.frame = CGRect(x: CGFloat(nextGuard.xPos) * xAxisMultiplicationFactor, y: CGFloat(nextGuard.yPos) * yAxisMultiplicationFactor, width: imageView.frame.size.width, height: imageView.frame.size.height)
                    }
                }
            }

		let playerImageView = imageViewsForEntities[player.entityID]!
		player.updatePosition(imageView: playerImageView)
		player.detectCollisions(imageView: playerImageView)
		if xAxisMultiplicationFactor != 1.0 || yAxisMultiplicationFactor != 1.0
			{
			playerImageView.frame = CGRect(x: CGFloat(player.xPos) * xAxisMultiplicationFactor, y: CGFloat(player.yPos) * yAxisMultiplicationFactor, width: playerImageView.frame.size.width, height: playerImageView.frame.size.height)
			}

		for nextBar in goldBars
			{
			if let imageView = imageViewsForEntities[nextBar.entityID]
				{
				if nextBar.possessedBy != nil
					{
					imageView.isHidden = true
					}
				else
					{
					imageView.isHidden = false
					}
				if xAxisMultiplicationFactor != 1.0 || yAxisMultiplicationFactor != 1.0
					{
						imageView.frame = CGRect(x: CGFloat(nextBar.xPos) * xAxisMultiplicationFactor, y: CGFloat(nextBar.yPos) * yAxisMultiplicationFactor, width: imageView.frame.size.width, height: imageView.frame.size.height)
					}
				}
			}

		if GameStateManager.sharedManager.getStasisFieldOne().activated
			{
			GameStateManager.sharedManager.getStasisFieldOne().advance(xAxisMultiplier: xAxisMultiplicationFactor, yAxisMultiplier: yAxisMultiplicationFactor)
			}
		if GameStateManager.sharedManager.getStasisFieldTwo().activated
			{
			GameStateManager.sharedManager.getStasisFieldTwo().advance(xAxisMultiplier: xAxisMultiplicationFactor, yAxisMultiplier: yAxisMultiplicationFactor)
			}
	}

	func updateScore(newScore: Int)
	{
		scoreDisplay.text = "Score: \(newScore)"
		if newScore >= GameStateManager.sharedManager.getNextAdditonalLifeScore()
			{
			SoundManager.sharedManager.playExtraLife()
			GameStateManager.sharedManager.advanceAdditionalLifeScore()
			}
	}

	func updateLives(livesRemaining: Int)
	{
		livesDisplay.text = "Lives: \(livesRemaining)"
	}

	func revealEscapeLadder()
	{
		let escapeLadderBase = GameStateManager.sharedManager.getEscapeLadderBase()
		let guards = GameStateManager.sharedManager.getGuards()
		let player = GameStateManager.sharedManager.getPlayer()
		for nextTile in stride(from: escapeLadderBase.yPos, through: 0, by: -1)
			{
			let tileNumber = currentLevel.tileMap[nextTile][escapeLadderBase.xPos]
			let attributes = currentLevel.attributeMap[nextTile][escapeLadderBase.xPos]
			var spriteNumber = 0
			var upperLeftTile = -1
			var upperMiddleTile = -1
			var upperRightTile = -1
			var leftTile = -1
			var rightTile = -1
			var lowerLeftTile = -1
			var lowerMiddleTile = -1
			var lowerRightTile = -1
			if ConfigurationManager.darkBackgroundTiles.contains(tileNumber)
				{
				spriteNumber = ConfigurationManager.ladderTileDarkBackground
				}
			else if ConfigurationManager.lightBackgroundTiles.contains(tileNumber)
				{
				spriteNumber = ConfigurationManager.ladderTileLightBackground
				}
			else if tileNumber == ConfigurationManager.steelGirderTile
				{
				if escapeLadderBase.xPos == 0
					{
					upperMiddleTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos]
					upperRightTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos + 1]
					rightTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos + 1]
					lowerMiddleTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos]
					lowerRightTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos + 1]
					}
				else if escapeLadderBase.xPos == currentLevel.width - 1
					{
					upperLeftTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos - 1]
					upperMiddleTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos]
					leftTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos - 1]
					lowerLeftTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos - 1]
					lowerMiddleTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos]
					}
				else
					{
					if nextTile > 0
						{
						upperLeftTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos - 1]
						upperMiddleTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos]
						upperRightTile = currentLevel.tileMap[nextTile - 1][escapeLadderBase.xPos + 1]
						leftTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos - 1]
						rightTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos + 1]
						lowerLeftTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos - 1]
						lowerMiddleTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos]
						lowerRightTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos + 1]
						}
					else
						{
						leftTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos - 1]
						rightTile = currentLevel.tileMap[nextTile][escapeLadderBase.xPos + 1]
						lowerLeftTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos - 1]
						lowerMiddleTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos]
						lowerRightTile = currentLevel.tileMap[nextTile + 1][escapeLadderBase.xPos + 1]
						}
					}
				if ConfigurationManager.lightBackgroundTiles.contains(lowerLeftTile) || ConfigurationManager.lightBackgroundTiles.contains(lowerMiddleTile) || ConfigurationManager.lightBackgroundTiles.contains(lowerRightTile)
					{
					spriteNumber = ConfigurationManager.ladderTileLightBackground
					}
				else if (ConfigurationManager.lightBackgroundTiles.contains(leftTile) && !ConfigurationManager.darkBackgroundTiles.contains(rightTile)) || (ConfigurationManager.lightBackgroundTiles.contains(rightTile) && !ConfigurationManager.darkBackgroundTiles.contains(leftTile))
					{
					spriteNumber = ConfigurationManager.ladderTileLightBackground
					}
				else if (ConfigurationManager.lightBackgroundTiles.contains(upperLeftTile) || ConfigurationManager.lightBackgroundTiles.contains(upperMiddleTile) || ConfigurationManager.lightBackgroundTiles.contains(upperRightTile)) && !(ConfigurationManager.darkBackgroundTiles.contains(leftTile) || ConfigurationManager.darkBackgroundTiles.contains(rightTile))
					{
					spriteNumber = ConfigurationManager.ladderTileLightBackground
					}
				else
					{
					spriteNumber = ConfigurationManager.ladderTileDarkBackground
					}
				}
			let sprite = SpriteManager.sharedManager.getSprite(number: spriteNumber)
			let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
			let imageView = UIImageView(image: image)
			let frame = CGRect(x: CGFloat(escapeLadderBase.xPos * sprite!.width) * xAxisMultiplicationFactor, y: CGFloat(nextTile * sprite!.height) * yAxisMultiplicationFactor, width: CGFloat(sprite!.width) * xAxisMultiplicationFactor, height: CGFloat(sprite!.height) * yAxisMultiplicationFactor)
			currentLevel.setTile(xTile: escapeLadderBase.xPos, yTile: nextTile, tileNumber: spriteNumber, attributes: [0])
			imageView.frame = frame
			if spriteNumber == ConfigurationManager.ladderTileDarkBackground
				{
				let coverImage = UIImage(named: "Background.png")
				let coverImageView = UIImageView(image: coverImage)
				coverImageView.frame = frame
				gameBoardView.addSubview(coverImageView)
				escapeLadderBackgroundTileViews.append(coverImageView)
				}
			gameBoardView.addSubview(imageView)
			escapeLadderOriginalTiles[imageView] = (escapeLadderBase.xPos, nextTile, tileNumber, attributes)
			}
		// Now put the player and sentry imageViews in front of the new ladder imageViews
		for nextGuard in guards
		{
			let imageView = imageViewsForEntities[nextGuard.entityID]!
			gameBoardView.bringSubview(toFront: imageView)
		}
		let playerImageView = imageViewsForEntities[player.entityID]!
		gameBoardView.bringSubview(toFront: playerImageView)
		escapeLadderRevealed = true
		GameStateManager.sharedManager.setLevelEscapable(true)
	}

	func retractEscapeLadder()
	{
		for (imageView, (x: xTile, y: yTile, tile: tileNumber, attributes: attributes)) in escapeLadderOriginalTiles
			{
			imageView.removeFromSuperview()
			currentLevel.setTile(xTile: xTile, yTile: yTile, tileNumber: tileNumber, attributes: attributes)
			}
		for coverImageView in escapeLadderBackgroundTileViews
			{
			coverImageView.removeFromSuperview()
			}
		escapeLadderBackgroundTileViews.removeAll()
		escapeLadderOriginalTiles.removeAll()
		escapeLadderRevealed = false
		GameStateManager.sharedManager.setLevelEscapable(false)
	}

	// MARK: Control Delegate Methods

	func directionTapped(direction : ControlView.ControllerDirection)
	{
		let player = GameStateManager.sharedManager.getPlayer()
		if player.direction == .Still || direction == .Center
			{
			switch direction
				{
				case .Center:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsNonePressed.png")
						}
					player.setDirection(newDirection: .Still)
				case .Up:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsTopPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
						}
					player.setDirection(newDirection: .Up)
				case .Down:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsBottomPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
						}
					player.setDirection(newDirection: .Down)
				case .Left:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsLeftPressed.png")
						}
					else
						{
						horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
						}
					player.setDirection(newDirection: .Left)
				case .Right:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsRightPressed.png")
						}
					else
						{
						horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
						}
					player.setDirection(newDirection: .Right)
				case .UpLeft:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsTopAndLeftPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
						horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
						}
					player.setDirection(newDirection: .UpLeft)
				case .UpRight:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsTopAndRightPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
						horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
						}
					player.setDirection(newDirection: .UpRight)
				case .DownLeft:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsBottomAndLeftPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
						horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
						}
					player.setDirection(newDirection: .DownLeft)
				case .DownRight:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsBottomAndRightPressed.png")
						}
					else
						{
						verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
						horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
						}
					player.setDirection(newDirection: .DownRight)
				}
			}
		else
			{
			switch player.direction
				{
				case .Still:
					if controlImageView != nil
						{
						controlImageView.image = UIImage(named: "ButtonsNonePressed.png")
						}
					else
						{
						horizontalControlImageView.image = UIImage(named: "ArrowsLeftRightEmpty")
						verticalControlImageView.image = UIImage(named: "ArrowsUpDownEmpty")
						}
					player.setDirection(newDirection: .Still)
				case .Up:
					if direction == .Left
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsTopAndLeftPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
							}
						player.setDirection(newDirection: .UpLeft)
						}
					else if direction == .Right
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsTopAndRightPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
							}
						player.setDirection(newDirection: .UpRight)
						}
					else if direction == .Down
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsBottomPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
							}
						player.setDirection(newDirection: .Down)
						}
				case .Down:
					if direction == .Left
						{
						if !player.falling
							{
							if controlImageView != nil
								{
								controlImageView.image = UIImage(named: "ButtonsBottomAndLeftPressed.png")
								}
							else
								{
								verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
								horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
								}
							player.setDirection(newDirection: .DownLeft)
							}
						else
							{
							if controlImageView != nil
								{
								controlImageView.image = UIImage(named: "ButtonsLeftPressed.png")
								}
							else
								{
								horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
								}
							player.setDirection(newDirection: .Left)
							}
						}
					else if direction == .Right
						{
						if !player.falling
							{
							if controlImageView != nil
								{
								controlImageView.image = UIImage(named: "ButtonsBottomAndRightPressed.png")
								}
							else
								{
								verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
								horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
								}
							player.setDirection(newDirection: .DownRight)
							}
						else
							{
							if controlImageView != nil
								{
								controlImageView.image = UIImage(named: "ButtonsRightPressed.png")
								}
							else
								{
								horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
								}
							player.setDirection(newDirection: .Right)
							}
						}
					else if direction == .Up
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsTopPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
							}
						player.setDirection(newDirection: .Up)
						}
				case .Left:
					if direction == .Up
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsTopAndLeftPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
							}
						player.setDirection(newDirection: .UpLeft)
						}
					else if direction == .Down
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsBottomAndLeftPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
							}
						player.setDirection(newDirection: .DownLeft)
						}
					else if direction == .Right
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsRightPressed.png")
							}
						else
							{
							horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
							}
						player.setDirection(newDirection: .Right)
						}
				case .Right:
					if direction == .Up
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsTopAndRightPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsUpSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
							}
						player.setDirection(newDirection: .UpRight)
						}
					else if direction == .Down
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsBottomAndRightPressed.png")
							}
						else
							{
							verticalControlImageView.image = UIImage(named: "ArrowsDownSelected")
							horizontalControlImageView.image = UIImage(named: "ArrowsRightSelected")
							}
						player.setDirection(newDirection: .DownRight)
						}
					else if direction == .Left
						{
						if controlImageView != nil
							{
							controlImageView.image = UIImage(named: "ButtonsLeftPressed.png")
							}
						else
							{
							horizontalControlImageView.image = UIImage(named: "ArrowsLeftSelected")
							}
						player.setDirection(newDirection: .Left)
						}
				case .UpLeft:
					player.setDirection(newDirection: .Still)
					directionTapped(direction: direction)
				case .UpRight:
					player.setDirection(newDirection: .Still)
					directionTapped(direction: direction)
				case .DownLeft:
					player.setDirection(newDirection: .Still)
					directionTapped(direction: direction)
				case .DownRight:
					player.setDirection(newDirection: .Still)
					directionTapped(direction: direction)
				}
			}
	}

	func directionUpdated(direction : ControlView.ControllerDirection)
	{
		let player = GameStateManager.sharedManager.getPlayer()
		let currentDirection = player.direction
		if !((currentDirection == .Still && direction == .Center) || (currentDirection == .Up && direction == .Up) || (currentDirection == .Down && direction == .Down) || (currentDirection == .Left && direction == .Left) || (currentDirection == .Right && direction == .Right) || (currentDirection == .UpLeft && direction == .UpLeft) || (currentDirection == .UpRight && direction == .UpRight) || (currentDirection == .DownLeft && direction == .DownLeft) || (currentDirection == .DownRight && direction == .DownRight))
			{
			directionTapped(direction: direction)
			}
	}

	func directionSwiped(direction : ControlView.ControllerDirection)
	{
	
	}

	func controlReleased()
	{
		let player = GameStateManager.sharedManager.getPlayer()
		if controlImageView != nil
			{
			controlImageView.image = UIImage(named: "ButtonsNonePressed")
			}
		else
			{
			horizontalControlImageView.image = UIImage(named: "ArrowsLeftRightEmpty")
			verticalControlImageView.image = UIImage(named: "ArrowsUpDownEmpty")
			}
		player.setDirection(newDirection: .Still)
	}
}
