/*******************************************************************************
* Player.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of the player
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/09/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class Player : Entity
{
	enum ControlDirection
	{
		case Still
		case Up
		case UpRight
		case Right
		case DownRight
		case Down
		case DownLeft
		case Left
		case UpLeft
	}

	var direction = ControlDirection.Still
	var desiredDirection = ControlDirection.Still
	var lastPrimaryDirection = ControlDirection.Still
	var goldPossessed = 0
	var autoPilot = false
	var autoPilotDirection : ControlDirection?
	var autoPilotDestinationDirection : ControlDirection?
	var currentAnimationName = "Runner Right"
	var onPlatform = false
	var platformRiding : Platform?
	var falling = false

	func setDirection(newDirection : ControlDirection)
	{
		direction = newDirection
		desiredDirection = newDirection
		if newDirection == .Left || newDirection == .Right || newDirection == .Up || newDirection == .Down
			{
			lastPrimaryDirection = newDirection
			}
	}

	func updatePosition(imageView: UIImageView)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let currentTileCharacteristics = getCurrentTileCharacteristics()
		let tileDownCharacteristics = getTileDownCharacteristics()
		let tileUpCharacteristics = getTileUpCharacteristics()
		let tileLeftCharacteristics = getTileLeftCharacteristics()
		let tileRightCharacteristics = getTileRightCharacteristics()
		let tileDownLeftCharacteristics = getTileDownLeftCharacteristics()
		let tileDownRightCharacteristics = getTileDownRightCharacteristics()
		let borderingAttributes = getBorderingAttributes()
		let borderingTiles = getBorderingTiles()
		let xOffset = xPos - (xTile * GameStateManager.sharedManager.getTileWidth())
		let yOffset = yPos - (yTile * GameStateManager.sharedManager.getTileHeight())
		let tileClimbable = currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileDownClimbable = tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileLeftClimbable = tileLeftCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileRightClimbable = tileRightCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileDownLeftClimbable = tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileDownRightClimbable = tileDownRightCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileHangable = currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable
		let isLeftBlocked = StasisField.isPositionPlayerBlocked(xPosition: xTile - 1, yPosition: yTile)
		let isRightBlocked = StasisField.isPositionPlayerBlocked(xPosition: xTile + 1, yPosition: yTile)
		let isDownBlocked = StasisField.isPositionPlayerBlocked(xPosition: xTile, yPosition: yTile + 1)
		let currentImage = imageView.image
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		var viewFrame = imageView.frame
		// Have to set the image property to nil or iPad composits new image, with transparency, over old image
		imageView.image = nil
		// First, check if we're falling
		if xOffset == 0 && !onPlatform && ((tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable && (yOffset != 0 || currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == 0)) || (yOffset != 0 && tileUpCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable)) && !(currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || (yOffset != 0 && tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable))
			{
			direction = .Down
			falling = true
			}
		else if !onPlatform && xOffset > 0 && (((tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable) && (yOffset != 0 || currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == 0)) || (yOffset != 0 && tileUpCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable)) && !(currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || (yOffset != 0 && tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)) && !(currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileRightCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileDownRightCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)
			{
			direction = .Down
			falling = true
			}
		else if !onPlatform && xOffset < 0 && (((tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable) && (yOffset != 0 || currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == 0)) || (yOffset != 0 && tileUpCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable)) && !(currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || (yOffset != 0 && tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)) && !(currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileDownCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileLeftCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable || tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)
			{
			direction = .Down
			falling = true
			}
		// Then, check if we need to stop falling
		if falling && yOffset == 0
			{
			if xOffset == 0 && (tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0)
				{
				falling = false
				direction = desiredDirection
				}
			else if xOffset < 0 && (tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0 || tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)
				{
				falling = false
				direction = desiredDirection
				}
			else if xOffset > 0 && (tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0 || tileDownRightCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable)
				{
				falling = false
				direction = desiredDirection
				}
			else if xOffset == 0 && currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable
				{
				falling = false
				direction = .Still
				}
			else if xOffset < 0 && (currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable || tileLeftCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable)
				{
				falling = false
				direction = .Still
				}
			else if xOffset > 0 && (currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable || tileRightCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable)
				{
				falling = false
				direction = .Still
				}
			}
		// Next, check if we're on a platform
		if onPlatform
			{
			if platformRiding!.axis == Platform.TravelAxis.Horizontal
				{
				if platformRiding!.status == .Still && direction == .Still
					{
					if imageView.image == nil
						{
						imageView.image = currentImage
						}
					return
					}
				else if platformRiding!.status == Platform.Motion.PlatformRight
					{
					xPos += ConfigurationManager.platformXAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if xPos > (xTile * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
						{
						xTile += 1
						}
					}
				else if platformRiding!.status == Platform.Motion.PlatformLeft
					{
					xPos -= ConfigurationManager.platformXAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
						{
						xTile -= 1
						}
					}
				viewFrame.origin.x = CGFloat(xPos)
				viewFrame.origin.y = CGFloat(yPos)
				imageView.frame = viewFrame
				if  direction == .Still
					{
					if imageView.image == nil
						{
						imageView.image = currentImage
						}
					return
					}
				}
			else
				{
				if platformRiding!.status == .Still && direction == .Still
					{
					let platformOffset = platformRiding!.getPlatformTopOffset()
					yPos = platformRiding!.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
					}
				else if platformRiding!.status == Platform.Motion.PlatformDown
					{
					yPos += ConfigurationManager.platformYAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile += 1
						}
					}
				else if platformRiding!.status == Platform.Motion.PlatformUp
					{
					yPos -= ConfigurationManager.platformYAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile -= 1
						}
					}
				viewFrame.origin.x = CGFloat(xPos)
				viewFrame.origin.y = CGFloat(yPos)
				imageView.frame = viewFrame
				if  direction == .Still
					{
					if imageView.image == nil
						{
						imageView.image = currentImage
						}
					return
					}
				}
			}
		// If none of the above, move normally
		switch direction
			{
			case .Still:
				if xOffset == 0 && yOffset == 0 && !onPlatform
					{
					let platforms = GameStateManager.sharedManager.getPlatforms()
					for nextPlatform in platforms
						{
						let platformOffset = nextPlatform.getPlatformTopOffset()
						if xTile == nextPlatform.xTile && yTile == nextPlatform.yTile && nextPlatform.status == .Still
							{
							onPlatform = true
							falling = false
							platformRiding = nextPlatform
							yPos = nextPlatform.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
							}
						}
					}
				break
			case .Up:
				if xOffset == 0 && yOffset == 0
					{
					if tileClimbable
						{
						let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Climb")
						currentAnimationName = "Runner Climb"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						yPos -= ConfigurationManager.playerYAxisSteps * deviceMultiplier
						}
					}
				else if xOffset == 0 && yOffset != 0 && !onPlatform
					{
					yPos -= ConfigurationManager.playerYAxisSteps * deviceMultiplier
					let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
					currentAnimationName = "Runner Climb"
					imageView.image = nextSprite.image
					animationFrame = nextSprite.frame
					}
				else if xOffset != 0
					{
					if tileClimbable
						{
						if xPos < xTile * GameStateManager.sharedManager.getTileWidth()
							{
							if xPos + ConfigurationManager.playerXAxisSteps * deviceMultiplier >= xTile * GameStateManager.sharedManager.getTileWidth()
								{
								xPos = xTile * GameStateManager.sharedManager.getTileWidth()
								}
							else
								{
								xPos += xTile * GameStateManager.sharedManager.getTileWidth()
								}
							let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
							currentAnimationName = "Runner Right"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							if xPos - ConfigurationManager.playerXAxisSteps * deviceMultiplier >= xTile * GameStateManager.sharedManager.getTileWidth()
								{
								xPos = xTile * GameStateManager.sharedManager.getTileWidth()
								}
							else
								{
								xPos -= xTile * GameStateManager.sharedManager.getTileWidth()
								}
							let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
							currentAnimationName = "Runner Left"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else if xPos > (xTile * GameStateManager.sharedManager.getTileWidth()) && tileRightClimbable
						{
						let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
						currentAnimationName = "Runner Right"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
						if xPos + GameStateManager.sharedManager.getTileWidth() >= currentLevel.width * GameStateManager.sharedManager.getTileWidth()
							{
							xPos = currentLevel.width * GameStateManager.sharedManager.getTileWidth() - GameStateManager.sharedManager.getTileWidth()
							}
						if xPos > (xTile * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
							{
							xTile += 1
							}
						}
					else if xPos < (xTile * GameStateManager.sharedManager.getTileWidth()) && tileLeftClimbable
						{
						let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
						currentAnimationName = "Runner Left"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
						if xPos < 0
							{
							xPos = 0
							}
						if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
							{
							xTile -= 1
							}
						}
					}
				if yPos < 0
					{
					yPos = 0
					}
				if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
					{
					yTile -= 1
					onPlatform = false
					platformRiding = nil
					}
			case .UpRight:
				if xOffset == 0 && yOffset == 0
					{
					if lastPrimaryDirection == .Right && tileClimbable
						{
						direction = .Up
						lastPrimaryDirection = .Up
						}
					else if lastPrimaryDirection == .Up && isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderTraversable == 0
						{
						direction = .Right
						lastPrimaryDirection = .Right
						}
					else if tileClimbable
						{
						direction = .Up
						lastPrimaryDirection = .Up
						}
					else
						{
						direction = .Right
						lastPrimaryDirection = .Right
						}
					}
				else
					{
					if lastPrimaryDirection == .Up
						{
						direction = .Up
						}
					else if lastPrimaryDirection == .Right
						{
						direction = .Right
						}
					else if tileClimbable || (yOffset != 0 && tileDownClimbable)
						{
						direction = .Up
						}
					else
						{
						direction = .Right
						}
					}
				updatePosition(imageView: imageView)
				direction = desiredDirection
			case .Right:
				if falling
					{
					if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier < (yTile * GameStateManager.sharedManager.getTileHeight())
						{
						yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
						}
					else
						{
						if isCharacterTraversable(tileNumber: borderingTiles.bottomCenter, tileAttribute: borderingAttributes.bottomCenter)
							{
							if !falling
								{
								yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
								}
							else
								{
								yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
								}
							}
						else
							{
							yPos = yTile * GameStateManager.sharedManager.getTileHeight()
							falling = true
							}
						}
					let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
					currentAnimationName = "Runner Climb"
					imageView.image = nextSprite.image
					animationFrame = nextSprite.frame
					}
				else if xPos + ConfigurationManager.playerXAxisSteps * deviceMultiplier < (xTile * GameStateManager.sharedManager.getTileWidth())
					{
					xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
					if tileHangable
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Shimmy"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Shimmy", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Shimmy")
							}
						currentAnimationName = "Runner Shimmy"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Right"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Right", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
							}
						currentAnimationName = "Runner Right"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
				else
					{
					var pathClear = true
					if !isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) || (xOffset == 0 && isRightBlocked)
						{
						pathClear = false
						}
					else if yPos < (yTile * GameStateManager.sharedManager.getTileHeight()) && !isCharacterTraversable(tileNumber: borderingTiles.topRight, tileAttribute: borderingAttributes.topRight)
						{
						pathClear = false
						}
					else if yPos > (yTile * GameStateManager.sharedManager.getTileHeight()) && !isCharacterTraversable(tileNumber: borderingTiles.bottomRight, tileAttribute: borderingAttributes.bottomRight)
						{
						pathClear = false
						}
					if !pathClear
						{
						if xOffset == 0
							{
							if ((tileClimbable && yOffset < 0 && !isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && isCharacterTraversable(tileNumber: borderingTiles.topRight, tileAttribute: borderingAttributes.topRight)) || (tileDownClimbable && yOffset > 0 && isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && !isCharacterTraversable(tileNumber: borderingTiles.bottomRight, tileAttribute: borderingAttributes.bottomRight)))
								{
								let nextYBoundary = yOffset < 0 ? (yTile - 1) * GameStateManager.sharedManager.getTileHeight() : yTile * GameStateManager.sharedManager.getTileHeight()
								if yPos - ConfigurationManager.playerYAxisSteps * deviceMultiplier < nextYBoundary
									{
									yPos = nextYBoundary
									}
								else
									{
									yPos -= ConfigurationManager.playerYAxisSteps * deviceMultiplier
									}
								if yPos < 0
									{
									yPos = 0
									}
								if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
									{
									yTile -= 1
									}
								break
								}
							else if tileClimbable && ((yOffset > 0 && !isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && isCharacterTraversable(tileNumber: borderingTiles.bottomRight, tileAttribute: borderingAttributes.bottomRight)) || (yOffset < 0 && isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && !isCharacterTraversable(tileNumber: borderingTiles.topRight, tileAttribute: borderingAttributes.topRight)))
								{
								let nextYBoundary = yOffset > 0 ? (yTile + 1) * GameStateManager.sharedManager.getTileHeight() : yTile * GameStateManager.sharedManager.getTileHeight()
								if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier > nextYBoundary
									{
									yPos = nextYBoundary
									}
								else
									{
									yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
									}
								if yPos + GameStateManager.sharedManager.getTileHeight() >= currentLevel.height * GameStateManager.sharedManager.getTileHeight()
									{
									yPos = currentLevel.height * GameStateManager.sharedManager.getTileHeight() - GameStateManager.sharedManager.getTileHeight()
									}
								if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
									{
									yTile += 1
									}
								break
								}
							}
						xPos = xTile * GameStateManager.sharedManager.getTileWidth()
						}
					else
						{
						xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
						}
					if tileHangable
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Shimmy"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Shimmy", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Shimmy")
							}
						currentAnimationName = "Runner Shimmy"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Right"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Right", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
							}
						currentAnimationName = "Runner Right"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
				if xOffset == 0 && yOffset == 0 && !onPlatform
					{
					let platforms = GameStateManager.sharedManager.getPlatforms()
					for nextPlatform in platforms
						{
						let platformOffset = nextPlatform.getPlatformTopOffset()
						if xTile == nextPlatform.xTile && yTile == nextPlatform.yTile && nextPlatform.status == .Still
							{
							onPlatform = true
							falling = false
							platformRiding = nextPlatform
							yPos = nextPlatform.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
							}
						}
					}
				if xPos + GameStateManager.sharedManager.getTileWidth() >= currentLevel.width * GameStateManager.sharedManager.getTileWidth()
					{
					xPos = currentLevel.width * GameStateManager.sharedManager.getTileWidth() - GameStateManager.sharedManager.getTileWidth()
					}
				if xPos > (xTile * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
					{
					xTile += 1
					onPlatform = false
					platformRiding = nil
					}
				if onPlatform
					{
					let platformXpos = platformRiding!.xPos
					if xPos > (platformXpos + GameStateManager.sharedManager.getTileWidth())
						{
						onPlatform = false
						platformRiding = nil
						direction = .Down
						falling = true
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
						currentAnimationName = "Runner Climb"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
			case .DownRight:
				if xOffset == 0 && yOffset == 0
					{
					if lastPrimaryDirection == .Right && tileDownClimbable
						{
						direction = .Down
						lastPrimaryDirection = .Down
						}
					else if lastPrimaryDirection == .Down && isCharacterTraversable(tileNumber: borderingTiles.middleRight, tileAttribute: borderingAttributes.middleRight) && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderTraversable == 0
						{
						direction = .Right
						lastPrimaryDirection = .Right
						}
					else if tileDownClimbable
						{
						direction = .Down
						lastPrimaryDirection = .Down
						}
					else
						{
						direction = .Right
						lastPrimaryDirection = .Right
						}
					}
				else
					{
					if lastPrimaryDirection == .Down
						{
						direction = .Down
						}
					else if lastPrimaryDirection == .Right
						{
						direction = .Right
						}
					else if tileClimbable || (yOffset != 0 && tileDownClimbable)
						{
						direction = .Down
						}
					else
						{
						direction = .Right
						}
					}
				updatePosition(imageView: imageView)
				direction = desiredDirection
			case .Down:
				if xOffset == 0 && yOffset == 0
					{
					if falling && (tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0 || isDownBlocked)
						{
						falling = false
						direction = desiredDirection
						}
					else if isCharacterTraversable(tileNumber: borderingTiles.bottomCenter, tileAttribute: borderingAttributes.bottomCenter) && !isDownBlocked
						{
						yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
						currentAnimationName = "Runner Climb"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						if desiredDirection == .Right
							{
							direction = .Right
							}
						else if desiredDirection == .Left
							{
							direction = .Left
							}
						else if direction != desiredDirection
							{
							direction = desiredDirection
							}
						falling = false
						}
					}
				else if xOffset == 0 && yOffset != 0
					{
					if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier < (yTile * GameStateManager.sharedManager.getTileHeight())
						{
						if !falling
							{
							yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
							}
						else
							{
							yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
							}
						}
					else
						{
						if isCharacterTraversable(tileNumber: borderingTiles.bottomCenter, tileAttribute: borderingAttributes.bottomCenter)
							{
							if !falling
								{
								yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
								}
							else
								{
								yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
								}
							}
						else
							{
							yPos = yTile * GameStateManager.sharedManager.getTileHeight()
							falling = true
							}
						}
					let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
					currentAnimationName = "Runner Climb"
					imageView.image = nextSprite.image
					animationFrame = nextSprite.frame
					}
				else			// xOffset != 0
					{
					if falling && yOffset == 0 && (tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0 || (xOffset < 0 && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0) || (xOffset > 0 && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0))
						{
						falling = false
						direction = desiredDirection
						}
					else if falling && yOffset < 0
						{
						if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier >= yTile * GameStateManager.sharedManager.getTileHeight()
							{
							falling = false
							direction = desiredDirection
							yPos = yTile * GameStateManager.sharedManager.getTileHeight()
							}
						else
							{
							yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
							currentAnimationName = "Runner Climb"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else if tileDownClimbable
						{
						if xPos < xTile * GameStateManager.sharedManager.getTileWidth()
							{
							if xPos + ConfigurationManager.playerXAxisSteps * deviceMultiplier >= xTile * GameStateManager.sharedManager.getTileWidth()
								{
								xPos = xTile * GameStateManager.sharedManager.getTileWidth()
								}
							else
								{
								xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
								}
							let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
							currentAnimationName = "Runner Right"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							if xPos - ConfigurationManager.playerXAxisSteps * deviceMultiplier <= xTile * GameStateManager.sharedManager.getTileWidth()
								{
								xPos = xTile * GameStateManager.sharedManager.getTileWidth()
								}
							else
								{
								xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
								}
							let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
							currentAnimationName = "Runner Left"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else if tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable
						{
						if tileDownLeftClimbable
							{
							if xPos < xTile * GameStateManager.sharedManager.getTileWidth()
								{
								if xPos + ConfigurationManager.playerXAxisSteps * deviceMultiplier >= xTile * GameStateManager.sharedManager.getTileWidth()
									{
									xPos = xTile * GameStateManager.sharedManager.getTileWidth()
									}
								else
									{
									xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
									}
								let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
								currentAnimationName = "Runner Right"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								if xPos - ConfigurationManager.playerXAxisSteps * deviceMultiplier <= xTile * GameStateManager.sharedManager.getTileWidth()
									{
									xPos = xTile * GameStateManager.sharedManager.getTileWidth()
									}
								else
									{
									xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
									}
								let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
								currentAnimationName = "Runner Left"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if !falling
								{
								yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
								}
							else
								{
								yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
								currentAnimationName = "Runner Climb"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						}
					else if tileDownCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable
						{
						if tileDownRightClimbable
							{
							if xPos < xTile * GameStateManager.sharedManager.getTileWidth()
								{
								if xPos + ConfigurationManager.playerXAxisSteps * deviceMultiplier >= xTile * GameStateManager.sharedManager.getTileWidth()
									{
									xPos = xTile * GameStateManager.sharedManager.getTileWidth()
									}
								else
									{
									xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
									}
								let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
								currentAnimationName = "Runner Right"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								if xPos - ConfigurationManager.playerXAxisSteps * deviceMultiplier <= xTile * GameStateManager.sharedManager.getTileWidth()
									{
									xPos = xTile * GameStateManager.sharedManager.getTileWidth()
									}
								else
									{
									xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
									}
								let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
								currentAnimationName = "Runner Left"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if !falling
								{
								yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
								}
							else
								{
								yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
								currentAnimationName = "Runner Climb"
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						}
					else if xPos > (xTile * GameStateManager.sharedManager.getTileWidth()) && tileDownRightClimbable
						{
						let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Right")
						currentAnimationName = "Runner Right"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						xPos += ConfigurationManager.playerXAxisSteps * deviceMultiplier
						if xPos + GameStateManager.sharedManager.getTileWidth() >= currentLevel.width * GameStateManager.sharedManager.getTileWidth()
							{
							xPos = currentLevel.width * GameStateManager.sharedManager.getTileWidth() - GameStateManager.sharedManager.getTileWidth()
							}
						if xPos > (xTile * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
							{
							xTile += 1
							}
						}
					else if xPos < (xTile * GameStateManager.sharedManager.getTileWidth()) && tileDownLeftClimbable
						{
						let nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
						currentAnimationName = "Runner Left"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
						if xPos < 0
							{
							xPos = 0
							}
						if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
							{
							xTile -= 1
							}
						}
					else if yOffset < 0 && yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier <= (yTile * GameStateManager.sharedManager.getTileHeight())
						{
						if !falling
							{
							yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
							}
						else
							{
							yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
							currentAnimationName = "Runner Climb"
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else if yOffset < 0 && yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier > (yTile * GameStateManager.sharedManager.getTileHeight())
						{
						yPos = yTile * GameStateManager.sharedManager.getTileHeight()
						falling = true
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
						currentAnimationName = "Runner Climb"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						if desiredDirection == .Right
							{
							direction = .Right
							}
						else if desiredDirection == .Left
							{
							direction = .Left
							}
						else if direction != desiredDirection
							{
							direction = desiredDirection
							}
						falling = true
						}
					}
				if yPos + GameStateManager.sharedManager.getTileHeight() >= currentLevel.height * GameStateManager.sharedManager.getTileHeight()
					{
					yPos = currentLevel.height * GameStateManager.sharedManager.getTileHeight() - GameStateManager.sharedManager.getTileHeight()
					}
				if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
					{
					yTile += 1
					onPlatform = false
					platformRiding = nil
					}
			case .DownLeft:
				if xOffset == 0 && yOffset == 0
					{
					if lastPrimaryDirection == .Left && tileDownClimbable
						{
						direction = .Down
						lastPrimaryDirection = .Down
						}
					else if lastPrimaryDirection == .Down && isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderTraversable == 0
						{
						direction = .Left
						lastPrimaryDirection = .Left
						}
					else if tileDownClimbable
						{
						direction = .Down
						lastPrimaryDirection = .Down
						}
					else
						{
						direction = .Left
						lastPrimaryDirection = .Left
						}
					}
				else
					{
					if lastPrimaryDirection == .Down
						{
						direction = .Down
						}
					else if lastPrimaryDirection == .Left
						{
						direction = .Left
						}
					else if tileClimbable || (yOffset != 0 && tileDownClimbable)
						{
						direction = .Down
						}
					else
						{
						direction = .Left
						}
					}
				updatePosition(imageView: imageView)
				direction = desiredDirection
			case .Left:
				if falling
					{
					if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier < (yTile * GameStateManager.sharedManager.getTileHeight())
						{
						yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
						}
					else
						{
						if isCharacterTraversable(tileNumber: borderingTiles.bottomCenter, tileAttribute: borderingAttributes.bottomCenter)
							{
							if !falling
								{
								yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
								}
							else
								{
								yPos += ConfigurationManager.playerFallingSteps * deviceMultiplier
								}
							}
						else
							{
							yPos = yTile * GameStateManager.sharedManager.getTileHeight()
							falling = true
							}
						}
					let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
					currentAnimationName = "Runner Climb"
					imageView.image = nextSprite.image
					animationFrame = nextSprite.frame
					}
				if xPos - ConfigurationManager.playerXAxisSteps * deviceMultiplier >= (xTile * GameStateManager.sharedManager.getTileWidth())
					{
					xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
					if tileHangable
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Shimmy"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Shimmy", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Shimmy")
							}
						currentAnimationName = "Runner Shimmy"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Left"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Left", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
							}
						currentAnimationName = "Runner Left"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
				else
					{
					var pathClear = true
					if !isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) || (xOffset == 0 && isLeftBlocked)
						{
						pathClear = false
						}
					else if yPos < (yTile * GameStateManager.sharedManager.getTileHeight()) && !isCharacterTraversable(tileNumber: borderingTiles.topLeft, tileAttribute: borderingAttributes.topLeft)
						{
						pathClear = false
						}
					else if yPos > (yTile * GameStateManager.sharedManager.getTileHeight()) && !isCharacterTraversable(tileNumber: borderingTiles.bottomLeft, tileAttribute: borderingAttributes.bottomLeft)
						{
						pathClear = false
						}
					if !pathClear
						{
						if xOffset == 0
							{
							if ((tileClimbable && yOffset < 0 && !isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && isCharacterTraversable(tileNumber: borderingTiles.topLeft, tileAttribute: borderingAttributes.topLeft)) || (tileDownClimbable && yOffset > 0 && isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && !isCharacterTraversable(tileNumber: borderingTiles.bottomLeft, tileAttribute: borderingAttributes.bottomLeft)))
								{
								let nextYBoundary = yOffset < 0 ? (yTile - 1) * GameStateManager.sharedManager.getTileHeight() : yTile * GameStateManager.sharedManager.getTileHeight()
								if yPos - ConfigurationManager.playerYAxisSteps * deviceMultiplier < nextYBoundary
									{
									yPos = nextYBoundary
									}
								else
									{
									yPos -= ConfigurationManager.playerYAxisSteps * deviceMultiplier
									}
								if yPos < 0
									{
									yPos = 0
									}
								if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
									{
									yTile -= 1
									}
								break
								}
							else if tileClimbable && ((yOffset > 0 && !isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && isCharacterTraversable(tileNumber: borderingTiles.bottomLeft, tileAttribute: borderingAttributes.bottomLeft)) || (yOffset < 0 && isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && !isCharacterTraversable(tileNumber: borderingTiles.topLeft, tileAttribute: borderingAttributes.topLeft)))
								{
								let nextYBoundary = yOffset > 0 ? (yTile + 1) * GameStateManager.sharedManager.getTileHeight() : yTile * GameStateManager.sharedManager.getTileHeight()
								if yPos + ConfigurationManager.playerYAxisSteps * deviceMultiplier > nextYBoundary
									{
									yPos = nextYBoundary
									}
								else
									{
									yPos += ConfigurationManager.playerYAxisSteps * deviceMultiplier
									}
								if yPos + GameStateManager.sharedManager.getTileHeight() >= currentLevel.height * GameStateManager.sharedManager.getTileHeight()
									{
									yPos = currentLevel.height * GameStateManager.sharedManager.getTileHeight() - GameStateManager.sharedManager.getTileHeight()
									}
								if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
									{
									yTile += 1
									}
								break
								}
							}
						xPos = xTile * GameStateManager.sharedManager.getTileWidth()
						}
					else
						{
						xPos -= ConfigurationManager.playerXAxisSteps * deviceMultiplier
						}
					if tileHangable
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Shimmy"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Shimmy", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Shimmy")
							}
						currentAnimationName = "Runner Shimmy"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					else
						{
						var nextSprite : (image: UIImage, frame: Int)
						if currentAnimationName == "Runner Left"
							{
							nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Left", currentFrame: animationFrame)
							}
						else
							{
							nextSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Runner Left")
							}
						currentAnimationName = "Runner Left"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
				if xOffset == 0 && yOffset == 0 && !onPlatform
					{
					let platforms = GameStateManager.sharedManager.getPlatforms()
					for nextPlatform in platforms
						{
						let platformOffset = nextPlatform.getPlatformTopOffset()
						if xTile == nextPlatform.xTile && yTile == nextPlatform.yTile && nextPlatform.status == .Still
							{
							onPlatform = true
							falling = false
							platformRiding = nextPlatform
							yPos = nextPlatform.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
							}
						}
					}
				if xPos < 0
					{
					xPos = 0
					}
				if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
					{
					xTile -= 1
					onPlatform = false
					platformRiding = nil
					}
				if onPlatform
					{
					let platformXpos = platformRiding!.xPos
					if xPos + GameStateManager.sharedManager.getTileWidth() < platformXpos
						{
						onPlatform = false
						platformRiding = nil
						direction = .Down
						falling = true
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Runner Climb", currentFrame: animationFrame)
						currentAnimationName = "Runner Climb"
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						}
					}
			case .UpLeft:
				if xOffset == 0 && yOffset == 0
					{
					if lastPrimaryDirection == .Left && tileClimbable
						{
						direction = .Up
						lastPrimaryDirection = .Up
						}
					else if lastPrimaryDirection == .Up && isCharacterTraversable(tileNumber: borderingTiles.middleLeft, tileAttribute: borderingAttributes.middleLeft) && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderTraversable == 0
						{
						direction = .Left
						lastPrimaryDirection = .Left
						}
					else if tileClimbable
						{
						direction = .Up
						lastPrimaryDirection = .Up
						}
					else
						{
						direction = .Left
						lastPrimaryDirection = .Left
						}
					}
				else
					{
					if lastPrimaryDirection == .Up
						{
						direction = .Up
						}
					else if lastPrimaryDirection == .Left
						{
						direction = .Left
						}
					else if tileClimbable || (yOffset != 0 && tileDownClimbable)
						{
						direction = .Up
						}
					else
						{
						direction = .Left
						}
					}
				updatePosition(imageView: imageView)
				direction = desiredDirection
			}
		if onPlatform
			{
			if xPos < platformRiding!.xPos - (GameStateManager.sharedManager.getTileWidth() / 2) && xPos + GameStateManager.sharedManager.getTileWidth() <= platformRiding!.xPos + GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2)
				{
				onPlatform = false
				platformRiding = nil
				}
			}
		if imageView.image == nil
			{
			imageView.image = currentImage
			}
		viewFrame.origin.x = CGFloat(xPos)
		viewFrame.origin.y = CGFloat(yPos)
		imageView.frame = viewFrame
		imageView.superview?.bringSubview(toFront: imageView)
	}

	func getBorderingTiles() -> (topLeft: Int, topCenter: Int, topRight: Int, middleRight: Int, bottomRight: Int, bottomCenter: Int, bottomLeft: Int, middleLeft: Int)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		var topLeft = -1
		var topCenter = -1
		var topRight = -1
		var middleRight = -1
		var bottomRight = -1
		var bottomCenter = -1
		var bottomLeft = -1
		var middleLeft = -1

		if xTile > 0
			{
			middleLeft = currentLevel.tileMap[yTile][xTile - 1]
			if yTile > 0
				{
				topLeft = currentLevel.tileMap[yTile - 1][xTile - 1]
				}
			if yTile < (currentLevel.height - 1)
				{
				bottomLeft = currentLevel.tileMap[yTile + 1][xTile - 1]
				}
			}
		if xTile < (currentLevel.width - 1)
			{
			middleRight = currentLevel.tileMap[yTile][xTile + 1]
			if yTile > 0
				{
				topRight = currentLevel.tileMap[yTile - 1][xTile + 1]
				}
			if yTile < (currentLevel.height - 1)
				{
				bottomRight = currentLevel.tileMap[yTile + 1][xTile + 1]
				}
			}
		if yTile > 0
			{
			topCenter = currentLevel.tileMap[yTile - 1][xTile]
			}
		if yTile < (currentLevel.height - 1)
			{
			bottomCenter = currentLevel.tileMap[yTile + 1][xTile]
			}

		return (topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft, middleLeft)
	}

	func getBorderingAttributes() -> (topLeft: UInt8, topCenter: UInt8, topRight: UInt8, middleRight: UInt8, bottomRight: UInt8, bottomCenter: UInt8, bottomLeft: UInt8, middleLeft: UInt8)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		var topLeft = 0 as UInt8
		var topCenter = 0 as UInt8
		var topRight = 0 as UInt8
		var middleRight = 0 as UInt8
		var bottomRight = 0 as UInt8
		var bottomCenter = 0 as UInt8
		var bottomLeft = 0 as UInt8
		var middleLeft = 0 as UInt8

		if xTile > 0
			{
			if currentLevel.attributeMap[yTile][xTile - 1].count > 0
				{
				middleLeft = currentLevel.attributeMap[yTile][xTile - 1][0]
				}
			if yTile > 0
				{
				if currentLevel.attributeMap[yTile - 1][xTile - 1].count > 0
					{
					topLeft = currentLevel.attributeMap[yTile - 1][xTile - 1][0]
					}
				}
			if yTile < (currentLevel.height - 1)
				{
				if currentLevel.attributeMap[yTile + 1][xTile - 1].count > 0
					{
					bottomLeft = currentLevel.attributeMap[yTile + 1][xTile - 1][0]
					}
				}
			}
		if xTile < (currentLevel.width - 1)
			{
			if currentLevel.attributeMap[yTile][xTile + 1].count > 0
				{
				middleRight = currentLevel.attributeMap[yTile][xTile + 1][0]
				}
			if yTile > 0
				{
				if currentLevel.attributeMap[yTile - 1][xTile + 1].count > 0
					{
					topRight = currentLevel.attributeMap[yTile - 1][xTile + 1][0]
					}
				}
			if yTile < (currentLevel.height - 1)
				{
				if currentLevel.attributeMap[yTile + 1][xTile + 1].count > 0
					{
					bottomRight = currentLevel.attributeMap[yTile + 1][xTile + 1][0]
					}
				}
			}
		if yTile > 0
			{
			if currentLevel.attributeMap[yTile - 1][xTile].count > 0
				{
				topCenter = currentLevel.attributeMap[yTile - 1][xTile][0]
				}
			}
		if yTile < (currentLevel.height - 1)
			{
			if currentLevel.attributeMap[yTile + 1][xTile].count > 0
				{
				bottomCenter = currentLevel.attributeMap[yTile + 1][xTile][0]
				}
			}
		return (topLeft, topCenter, topRight, middleRight, bottomRight, bottomCenter, bottomLeft, middleLeft)
	}

	func detectCollisions(imageView: UIImageView)
	{
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		// First, check for beating the level
		let escapeLadderTop = GameStateManager.sharedManager.getEscapeLadderTop()
		if xTile == escapeLadderTop.xPos && yTile == escapeLadderTop.yPos && GameStateManager.sharedManager.getLevelEscapable()
			{
			GameStateManager.sharedManager.winLevel()
			return
			}
		// Second, check for hitting a transporter, which will take precedence over a guard catching you at the same moment
		let teleporters = GameStateManager.sharedManager.getTeleporters()
		var numReceivableTeleporters = 0
		for nextTeleporter in teleporters
			{
			if nextTeleporter.receivable || nextTeleporter.roundtrippable
				{
				numReceivableTeleporters += 1
				}
			}
		for nextTeleporter in teleporters
			{
			if nextTeleporter.xTile == xTile && nextTeleporter.yTile == yTile
				{
				if nextTeleporter.pair != nil
					{
					SoundManager.sharedManager.playTeleporter()
					sendToTeleporter(destination: nextTeleporter.pair!, imageView: imageView)
					}
				else if nextTeleporter.sendable || nextTeleporter.roundtrippable
					{
					let destination = arc4random_uniform(UInt32(numReceivableTeleporters))
					var teleporterIndex = -1
					for teleporterOption in teleporters
						{
						if teleporterOption.receivable || nextTeleporter.roundtrippable
							{
							teleporterIndex += 1
							if teleporterIndex == destination
								{
								SoundManager.sharedManager.playTeleporter()
								sendToTeleporter(destination: teleporterOption, imageView: imageView)
								}
							}
						}
					}
				}
			}
		// Next, check for moving onto a platform
		let platforms = GameStateManager.sharedManager.getPlatforms()
		for nextPlatform in platforms
			{
			let platformOffset = nextPlatform.getPlatformTopOffset()
			if yPos + GameStateManager.sharedManager.getTileHeight() >= nextPlatform.yPos + platformOffset && yPos + GameStateManager.sharedManager.getTileHeight() <= nextPlatform.yPos + platformOffset + ConfigurationManager.playerYAxisSteps * deviceMultiplier
				{
				if xPos >= nextPlatform.xPos - (GameStateManager.sharedManager.getTileWidth() / 2) && xPos + GameStateManager.sharedManager.getTileWidth() <= nextPlatform.xPos + GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2)
					{
					onPlatform = true
					falling = false
					platformRiding = nextPlatform
					yPos = nextPlatform.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
					if direction == .Down
						{
						direction = .Still
						}
					}
				}
			}
		// Then, check for picking up a gold bar
		let bars = GameStateManager.sharedManager.getGoldBars()
		for nextBar in bars
			{
			if yTile == nextBar.yTile && xTile == nextBar.xTile
				{
				goldPossessed += 1
				nextBar.possessedBy = self
				nextBar.xTile = -1
				nextBar.yTile = -1
				GameStateManager.sharedManager.addGoldBarToScore()
				SoundManager.sharedManager.playPlayerGetGold()
				if goldPossessed == GameStateManager.sharedManager.totalLevelGold
					{
					let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
					SoundManager.sharedManager.playEscapeLadderRevealed()
					appDelegate.gameScreenViewController!.revealEscapeLadder()
					}
				}
			}
		// Finally, check for getting caught by a guard
		let guards = GameStateManager.sharedManager.getGuards()
		for nextGuard in guards
			{
			if nextGuard.inStasis
				{
				continue
				}
			if nextGuard.yPos == yPos && ((nextGuard.xPos >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && nextGuard.xPos <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier)) || ((nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && (nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier)))
				{
				caught()
				break
				}
			else if nextGuard.xPos == xPos && ((nextGuard.yPos >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && nextGuard.yPos <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier)) || ((nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && (nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier)))
				{
				caught()
				break
				}
			else if nextGuard.xPos >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && nextGuard.xPos <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && ((nextGuard.yPos >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && nextGuard.yPos <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier)) || (((nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && (nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier))))
				{
				caught()
				break
				}
			else if (nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && (nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && ((nextGuard.yPos >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && nextGuard.yPos <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier)) || (((nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && (nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier))))
				{
				caught()
				break
				}
			else if nextGuard.yPos >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && nextGuard.yPos <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && ((nextGuard.xPos >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && nextGuard.xPos <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier)) || (((nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && (nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier))))
				{
				caught()
				break
				}
			else if (nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) >= (yPos + ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && (nextGuard.yPos + GameStateManager.sharedManager.getTileHeight()) <= (yPos + GameStateManager.sharedManager.getTileHeight() - ConfigurationManager.guardCollisionYAxisOverlap * deviceMultiplier) && ((nextGuard.xPos >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && nextGuard.xPos <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier)) || (((nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) >= (xPos + ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier) && (nextGuard.xPos + GameStateManager.sharedManager.getTileWidth()) <= (xPos + GameStateManager.sharedManager.getTileWidth() - ConfigurationManager.guardCollisionXAxisOverlap * deviceMultiplier))))
				{
				caught()
				break
				}
			else if nextGuard.xTile == xTile && nextGuard.yTile == yTile
				{
				caught()
				break
				}
			}
	}

	func sendToTeleporter(destination: Teleporter, imageView: UIImageView)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let destinationX = destination.xTile
		let destinationY = destination.yTile
		var viewFrame = imageView.frame
		let xOffset = xPos - (xTile * GameStateManager.sharedManager.getTileWidth())
		let entryFromLeft = xOffset < 0 ? true : false
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		let xSteps = GameStateManager.sharedManager.getTileWidth() / (ConfigurationManager.playerXAxisSteps * deviceMultiplier)
		let newOffset = Int(xSteps / 2) * (ConfigurationManager.playerXAxisSteps * deviceMultiplier) + ConfigurationManager.playerXAxisSteps * deviceMultiplier
		xTile = destinationX
		yTile = destinationY
		xPos = xTile * GameStateManager.sharedManager.getTileWidth()
		yPos = yTile * GameStateManager.sharedManager.getTileHeight()
		if entryFromLeft
			{
			if xTile < currentLevel.width - 1
				{
				xPos += newOffset
				xTile += 1
				}
			else
				{
				xPos -= newOffset
				xTile -= 1
				}
			}
		else if !entryFromLeft
			{
			if xTile > 0
				{
				xPos -= newOffset
				xTile -= 1
				}
			else
				{
				xPos += newOffset
				xTile += 1
				}
			}
		viewFrame.origin.x = CGFloat(xPos)
		viewFrame.origin.y = CGFloat(yPos)
		imageView.frame = viewFrame
		imageView.superview?.bringSubview(toFront: imageView)
	}

	func caught()
	{
		SoundManager.sharedManager.playPlayerCaught()
		GameStateManager.sharedManager.playerDeath()
	}
}

