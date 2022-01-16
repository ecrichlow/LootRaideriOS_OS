/*******************************************************************************
* StasisField.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a stasis field
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	07/07/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class StasisField
{
	static var startFrame : Int!
	static var endFrame : Int!

	var activated = false
	var xTile = -1
	var yTile = -1
	var timeReachedFullStrength : Date?
	var guardHeld : Guard?
	var animationFrame = -1
	var imageView : UIImageView?
	var stage = -1

	static func setStartFrame(start: Int)
	{
		startFrame = start
	}

	static func setEndFrame(end: Int)
	{
		endFrame = end
	}

	static func isPositionPlayerBlocked(xPosition: Int, yPosition: Int) -> Bool
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let fieldOne = GameStateManager.sharedManager.getStasisFieldOne()
		let fieldTwo = GameStateManager.sharedManager.getStasisFieldTwo()
		if xPosition < 0 || xPosition >= currentLevel.width
			{
			return true
			}
		else if (fieldOne.activated && fieldOne.animationFrame == endFrame && fieldOne.guardHeld != nil && fieldOne.xTile == xPosition && fieldOne.yTile == yPosition) || (fieldTwo.activated && fieldTwo.animationFrame == endFrame && fieldTwo.guardHeld != nil && fieldTwo.xTile == xPosition && fieldTwo.yTile == yPosition)
			{
			return false
			}
		else if (fieldOne.activated && fieldOne.xTile == xPosition && fieldOne.yTile == yPosition) || (fieldTwo.activated && fieldTwo.xTile == xPosition && fieldTwo.yTile == yPosition)
			{
			return true
			}
		else
			{
			return false
			}
	}

	static func isPositionBlocked(xPosition: Int, yPosition: Int) -> Bool
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let fieldOne = GameStateManager.sharedManager.getStasisFieldOne()
		let fieldTwo = GameStateManager.sharedManager.getStasisFieldTwo()
		if xPosition < 0 || xPosition >= currentLevel.width
			{
			return true
			}
		else if (fieldOne.activated && (fieldOne.stage >= ConfigurationManager.stasisFieldBlockingStage || fieldOne.guardHeld != nil) && fieldOne.xTile == xPosition && fieldOne.yTile == yPosition) || (fieldTwo.activated && (fieldTwo.stage >= ConfigurationManager.stasisFieldBlockingStage || fieldTwo.guardHeld != nil) && fieldTwo.xTile == xPosition && fieldTwo.yTile == yPosition)
			{
			return true
			}
		else
			{
			return false
			}
	}

	func activate(xPosition: Int, yPosition: Int, xAxisMultiplier: CGFloat, yAxisMultiplier: CGFloat)
	{
		SoundManager.sharedManager.playRaiseStasisField()
		animationFrame = StasisField.startFrame
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		let sprite = SpriteManager.sharedManager.getSprite(number: animationFrame)
		let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
		xTile = xPosition
		yTile = yPosition
		activated = true
		timeReachedFullStrength = nil
		if imageView == nil
			{
			imageView = UIImageView(image: image)
			imageView!.alpha = ConfigurationManager.stasisFieldAlpha
			}
		else
			{
			imageView!.image = nil
			imageView!.image = image
			}
		imageView!.frame = CGRect(x: CGFloat(xTile * GameStateManager.sharedManager.getTileWidth()) * xAxisMultiplier, y: CGFloat(yTile * GameStateManager.sharedManager.getTileHeight()) * yAxisMultiplier, width: CGFloat(GameStateManager.sharedManager.getTileWidth()) * xAxisMultiplier, height: CGFloat(GameStateManager.sharedManager.getTileHeight()) * yAxisMultiplier)
		appDelegate.gameScreenViewController!.gameBoardView.addSubview(imageView!)
		appDelegate.gameScreenViewController!.gameBoardView.bringSubview(toFront: imageView!)
		stage = 0
		checkForTrappedGuards()
	}

	func advance(xAxisMultiplier: CGFloat, yAxisMultiplier: CGFloat)
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		let currentImage = imageView!.image
		// Have to set the image property to nil or iPad composits new image, with transparency, over old image
		imageView!.image = nil
		if let startTime = timeReachedFullStrength
			{
			let duration = abs(startTime.timeIntervalSinceNow)
			if duration > ConfigurationManager.stasisFieldDuration
				{
				if animationFrame == StasisField.endFrame
					{
					SoundManager.sharedManager.playLowerStasisField()
					}
				animationFrame -= 1
				stage -= 1
				if animationFrame >= StasisField.startFrame
					{
					let sprite = SpriteManager.sharedManager.getSprite(number: animationFrame)
					let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
					imageView!.image = image
					}
				else
					{
					activated = false
					timeReachedFullStrength = nil
					imageView!.removeFromSuperview()
					xTile = -1
					yTile = -1
					}
				if stage < ConfigurationManager.stasisFieldBlockingStage && guardHeld != nil
					{
					guardHeld!.inStasis = false
					guardHeld = nil
					}
				}
			}
		else
			{
			animationFrame += 1
			stage += 1
			let sprite = SpriteManager.sharedManager.getSprite(number: animationFrame)
			let image = SpriteManager.sharedManager.imageForSprite(sprite: sprite!)
			imageView!.image = image
			checkForTrappedGuards()
			if animationFrame == StasisField.endFrame
				{
				timeReachedFullStrength = Date()
				}
			}
		if imageView!.image == nil
			{
			imageView!.image = currentImage
			}
		imageView!.frame = CGRect(x: CGFloat(xTile * GameStateManager.sharedManager.getTileWidth()) * xAxisMultiplier, y: CGFloat(yTile * GameStateManager.sharedManager.getTileHeight()) * yAxisMultiplier, width: CGFloat(GameStateManager.sharedManager.getTileWidth()) * xAxisMultiplier, height: CGFloat(GameStateManager.sharedManager.getTileHeight()) * yAxisMultiplier)
		appDelegate.gameScreenViewController!.gameBoardView.bringSubview(toFront: imageView!)
	}

	func dissipate()
	{
		activated = false
		timeReachedFullStrength = nil
		imageView!.image = nil
		imageView!.removeFromSuperview()
		xTile = -1
		yTile = -1
		animationFrame = -1
		stage = -1
		if guardHeld != nil
			{
			guardHeld!.inStasis = false
			guardHeld = nil
			}
	}

	func checkForTrappedGuards()
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let guards = GameStateManager.sharedManager.getGuards()
		for nextGuard in guards
			{
			if nextGuard.xTile == xTile && nextGuard.yTile == yTile && !nextGuard.inStasis && guardHeld == nil
				{
				guardHeld = nextGuard
				nextGuard.xPos = xTile * GameStateManager.sharedManager.getTileWidth()
				nextGuard.yPos = yTile * GameStateManager.sharedManager.getTileHeight()
				nextGuard.inStasis = true
				if nextGuard.goldPossessed
					{
					nextGuard.goldPossessed = false
					let bars = GameStateManager.sharedManager.getGoldBars()
					for nextBar in bars
						{
						if let holdingGuard = nextBar.possessedBy
							{
							if holdingGuard === nextGuard
								{
								nextBar.possessedBy = nil
								if xTile == 0
									{
									let rightTile = currentLevel.tileMap[yTile][xTile + 1]
									let tileSprite = SpriteManager.sharedManager.getSprite(number: rightTile)
									let spriteCharacteristic = tileSprite!.headerData[0]
									if spriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable
										{
										nextBar.xTile = xTile + 1
										nextBar.yTile = yTile
										}
									else	// This shouldn't happen - if the gold can't be placed next to the guard, the guard keeps it
										{
										nextGuard.goldPossessed = true
										nextBar.possessedBy = nextGuard
										}
									}
								else if xTile == currentLevel.width - 1
									{
									let leftTile = currentLevel.tileMap[yTile][xTile - 1]
									let tileSprite = SpriteManager.sharedManager.getSprite(number: leftTile)
									let spriteCharacteristic = tileSprite!.headerData[0]
									if spriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable
										{
										nextBar.xTile = xTile - 1
										nextBar.yTile = yTile
										}
									else	// This shouldn't happen - if the gold can't be placed next to the guard, the guard keeps it
										{
										nextGuard.goldPossessed = true
										nextBar.possessedBy = nextGuard
										}
									}
								else
									{
									let player = GameStateManager.sharedManager.getPlayer()
									let leftTile = currentLevel.tileMap[yTile][xTile - 1]
									let leftTileSprite = SpriteManager.sharedManager.getSprite(number: leftTile)
									let leftSpriteCharacteristic = leftTileSprite!.headerData[0]
									let rightTile = currentLevel.tileMap[yTile][xTile + 1]
									let rightTileSprite = SpriteManager.sharedManager.getSprite(number: rightTile)
									let rightSpriteCharacteristic = rightTileSprite!.headerData[0]
									if player.xTile < xTile && leftSpriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable
										{
										nextBar.xTile = xTile - 1
										nextBar.yTile = yTile
										}
									else if rightSpriteCharacteristic & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable
										{
										nextBar.xTile = xTile + 1
										nextBar.yTile = yTile
										}
									else	// This shouldn't happen - if the gold can't be placed next to the guard, the guard keeps it
										{
										nextGuard.goldPossessed = true
										nextBar.possessedBy = nextGuard
										}
									}
								break
								}
							}
						}
					}
				break
				}
			}
	}
}
