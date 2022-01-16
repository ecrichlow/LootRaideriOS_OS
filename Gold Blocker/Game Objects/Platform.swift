/*******************************************************************************
* Platform.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a platform
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/09/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class Platform : Entity
{
	enum TravelAxis
	{
		case Horizontal
		case Vertical
	}

	enum PlatformSpeed
	{
		case Slow
		case Moderate
		case Fast
	}

	enum PlatformWait
	{
		case Short
		case Moderate
		case Long
	}

	static var startFrame : Int!
	static var endFrame : Int!

	var axis : TravelAxis
	var timeDocked : Date?
	var speedMultiplier = 0
	var waitMultiplier = 0.0
	var inLandingAndTakeoffZone = false
	var takeoffDirection : Motion!

	static func setStartFrame(start: Int)
	{
		startFrame = start
	}

	static func setEndFrame(end: Int)
	{
		endFrame = end
	}

	init(positionX: Int, positionY: Int, tileX: Int, tileY: Int, status: Motion, frame: Int, axis: TravelAxis, speed: PlatformSpeed, wait: PlatformWait)
	{
		self.axis = axis
		self.timeDocked = Date()
		self.takeoffDirection = status
		switch speed
			{
			case .Slow:
				speedMultiplier = ConfigurationManager.platformSpeedSlowMultiplier
			case .Moderate:
				speedMultiplier = ConfigurationManager.platformSpeedModerateMultiplier
			case .Fast:
				speedMultiplier = ConfigurationManager.platformSpeedFastMultiplier
			}
		switch wait
			{
			case .Short:
				waitMultiplier = ConfigurationManager.platformWaitShortMultiplier
			case .Moderate:
				waitMultiplier = ConfigurationManager.platformWaitModerateMultiplier
			case .Long:
				waitMultiplier = ConfigurationManager.platformWaitLongMultiplier
			}
		super.init(positionX: positionX, positionY: positionY, tileX: tileX, tileY: tileY, status: Motion.Still, animationFrame: frame)
	}

	func runCycle(imageView: UIImageView)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let surroundingAttributes = getSurroundingAttributes()
		let surroundingTiles = getSurroundingTiles()
		let currentTileAttribute = currentLevel.attributeMap[yTile][xTile].count > 0 ? currentLevel.attributeMap[yTile][xTile][0] : 0
		let xOffset = xPos - (xTile * GameStateManager.sharedManager.getTileWidth())
		let yOffset = yPos - (yTile * GameStateManager.sharedManager.getTileHeight())
		let isLeftBlocked = StasisField.isPositionBlocked(xPosition: xTile - 1, yPosition: yTile)
		let isRightBlocked = StasisField.isPositionBlocked(xPosition: xTile + 1, yPosition: yTile)
		let isDownBlocked = StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile + 1)
		let currentImage = imageView.image
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		var viewFrame = imageView.frame
		// Have to set the image property to nil or iPad composits new image, with transparency, over old image
		imageView.image = nil
		if timeDocked != nil
			{
			if abs(timeDocked!.timeIntervalSinceNow) >= ConfigurationManager.platformDefaultWaitTime * waitMultiplier
				{
				let guards = GameStateManager.sharedManager.getGuards()
				let player = GameStateManager.sharedManager.getPlayer()
				timeDocked = nil
				status = takeoffDirection
				takeoffDirection = Motion.Still
				if let playerPlatform = player.platformRiding
					{
					if playerPlatform === self
						{
						if player.xPos != xPos
							{
							player.xPos = xPos
							}
						}
					}
				for nextGuard in guards
					{
					if let guardPlatform = nextGuard.platformRiding
						{
						if guardPlatform === self
							{
							if nextGuard.xPos != xPos
								{
								nextGuard.xPos = xPos
								}
							}
						}
					}
				}
			else
				{
				if imageView.image == nil
					{
					imageView.image = currentImage
					}
				return
				}
			}
		switch status
			{
			case .PlatformLeft:
				if xOffset == 0 && (!isPlatformTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked)
					{
					status = .Still
					takeoffDirection = Motion.PlatformRight
					timeDocked = Date()
					}
				else if xPos - ConfigurationManager.platformXAxisSteps * deviceMultiplier * speedMultiplier < xTile * GameStateManager.sharedManager.getTileWidth() && (!isPlatformTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked)
					{
					xPos = xTile * GameStateManager.sharedManager.getTileWidth()
					status = .Still
					takeoffDirection = Motion.PlatformRight
					timeDocked = Date()
					}
				else
					{
					xPos -= ConfigurationManager.platformXAxisSteps * deviceMultiplier * speedMultiplier
					}
				viewFrame.origin.x = CGFloat(xPos)
				// Determine new tile position
				if xTile > 0 && xPos <= ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + GameStateManager.sharedManager.getTileWidth() / 2)
					{
					xTile -= 1
					}
			case .PlatformRight:
				if xOffset == 0 && (!isPlatformTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked)
					{
					status = .Still
					takeoffDirection = Motion.PlatformLeft
					timeDocked = Date()
					}
				else if xPos + ConfigurationManager.platformXAxisSteps * deviceMultiplier * speedMultiplier > xTile * GameStateManager.sharedManager.getTileWidth() && (!isPlatformTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked)
					{
					xPos = xTile * GameStateManager.sharedManager.getTileWidth()
					status = .Still
					takeoffDirection = Motion.PlatformLeft
					timeDocked = Date()
					}
				else
					{
					xPos += ConfigurationManager.platformXAxisSteps * deviceMultiplier * speedMultiplier
					}
				viewFrame.origin.x = CGFloat(xPos)
				// Determine new tile position
				if xTile < currentLevel.width - 1 && xPos >= (xTile * GameStateManager.sharedManager.getTileWidth() + GameStateManager.sharedManager.getTileWidth() / 2)
					{
					xTile += 1
					}
			case .PlatformUp:
				if inLandingAndTakeoffZone && animationFrame == Platform.endFrame
					{
					animationFrame -= ConfigurationManager.platformYAxisSteps * speedMultiplier
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				else if inLandingAndTakeoffZone && animationFrame > Platform.startFrame
					{
					animationFrame -= ConfigurationManager.platformYAxisSteps * speedMultiplier
					if animationFrame < Platform.startFrame
						{
						let diff = Platform.startFrame - animationFrame
						animationFrame = Platform.startFrame
						yPos -= diff
						inLandingAndTakeoffZone = false
						}
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				else if inLandingAndTakeoffZone && animationFrame == Platform.startFrame
					{
					inLandingAndTakeoffZone = false
					yPos -= ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier
					}
				else if yOffset == 0 && isPlatformEndpoint(tileAttribute: currentTileAttribute)
					{
					status = .Still
					takeoffDirection = Motion.PlatformDown
					timeDocked = Date()
					}
				else if yOffset == 0 && !isPlatformTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up)
					{
					status = .Still
					takeoffDirection = Motion.PlatformDown
					timeDocked = Date()
					}
				else if yPos - ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier < yTile * GameStateManager.sharedManager.getTileHeight() && !isPlatformTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up)
					{
					yPos = yTile * GameStateManager.sharedManager.getTileHeight()
					status = .Still
					takeoffDirection = Motion.PlatformDown
					timeDocked = Date()
					}
				else if yPos - ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier < yTile * GameStateManager.sharedManager.getTileHeight() && isPlatformEndpoint(tileAttribute: currentTileAttribute)
					{
					yPos = yTile * GameStateManager.sharedManager.getTileHeight()
					status = .Still
					takeoffDirection = Motion.PlatformDown
					timeDocked = Date()
					}
				else
					{
					yPos -= ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier
					}
				viewFrame.origin.y = CGFloat(yPos)
				// Determine new tile position
				if yTile > 0 && yPos <= ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + GameStateManager.sharedManager.getTileHeight() / 2)
					{
					yTile -= 1
					}
			case .PlatformDown:
				if inLandingAndTakeoffZone && animationFrame + (ConfigurationManager.platformYAxisSteps * speedMultiplier) >= Platform.endFrame
					{
					status = .Still
					takeoffDirection = Motion.PlatformUp
					timeDocked = Date()
					animationFrame = Platform.endFrame
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				else if inLandingAndTakeoffZone
					{
					animationFrame += ConfigurationManager.platformYAxisSteps * speedMultiplier
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				else if yOffset == 0 && (!isPlatformTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked)
					{
					inLandingAndTakeoffZone = true
					animationFrame = Platform.startFrame + 1
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				// TODO: See if we ever enter this case
				else if yPos + ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier > yTile * GameStateManager.sharedManager.getTileHeight() && (!isPlatformTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked)
					{
					yPos = yTile * GameStateManager.sharedManager.getTileHeight()
					inLandingAndTakeoffZone = true
					animationFrame = Platform.startFrame + 1
					let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
					imageView.image = image
					}
				else
					{
					yPos += ConfigurationManager.platformYAxisSteps * deviceMultiplier * speedMultiplier
					}
				viewFrame.origin.y = CGFloat(yPos)
				// Determine new tile position
				if yTile < currentLevel.width - 1 && yPos >= (yTile * GameStateManager.sharedManager.getTileHeight() + GameStateManager.sharedManager.getTileHeight() / 2)
					{
					yTile += 1
					}
			default:
				break
			}
		if imageView.image == nil
			{
			imageView.image = currentImage
			}
		imageView.frame = viewFrame
	}

	func isPlatformTraversable(tileNumber: Int, tileAttribute: UInt8) -> Bool
	{
		guard tileNumber > -1
			else
				{
				return false
				}
		let tileSprite = SpriteManager.sharedManager.getSprite(number: tileNumber)
		let spriteAttribute = tileSprite!.headerData[0]
		var traversable = false
		// First, check the tile sprite's attributes
		if spriteAttribute & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable && spriteAttribute & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable
			{
			traversable = true
			}
		else if (spriteAttribute & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable) || (spriteAttribute & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable)
			{
			return false
			}
		else if spriteAttribute == 0
			{
			return false
			}
		// Then, check the attributes of the tiles position
		if (tileAttribute & ConfigurationManager.platformStoppableHeaderValue == ConfigurationManager.platformStoppableHeaderValue)
			{
			return true
			}
		else if tileAttribute == 0
			{
			traversable = true
			}
		return traversable
	}

	func isPlatformEndpoint(tileAttribute: UInt8) -> Bool
	{
		if (tileAttribute & ConfigurationManager.platformStoppableHeaderValue == ConfigurationManager.platformStoppableHeaderValue)
			{
			return true
			}
		else
			{
			return false
			}
	}

	func getPlatformTopOffset() -> Int
	{
		if axis == TravelAxis.Horizontal
			{
			return 0
			}
		else
			{
			if UIDevice.current.userInterfaceIdiom == .pad
				{
				return (animationFrame - Platform.startFrame) * 2
				}
			else
				{
				return animationFrame - Platform.startFrame
				}
			}
	}
}
