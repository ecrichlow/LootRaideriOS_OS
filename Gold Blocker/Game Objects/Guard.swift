/*******************************************************************************
* Guard.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a guard
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/08/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class Guard : Entity
{
	var goldPossessed = false
	var onPlatform = false
	var platformRiding : Platform?
	var readyToDisembark = false
	var inStasis = false

	func runChasePattern(imageView: UIImageView)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let currentTileCharacteristics = getCurrentTileCharacteristics()
		let surroundingAttributes = getSurroundingAttributes()
		let surroundingTiles = getSurroundingTiles()
		let xOffset = xPos - (xTile * GameStateManager.sharedManager.getTileWidth())
		let yOffset = yPos - (yTile * GameStateManager.sharedManager.getTileHeight())
		let playerPosition = GameStateManager.sharedManager.getPlayerPosition()
		let playerFalling = GameStateManager.sharedManager.getPlayerFalling()
		let guardSmartDecision = arc4random_uniform(UInt32(ConfigurationManager.optionsForGuardSmartBehavior)) > 0 ? true : false
		let tileClimbable = currentTileCharacteristics & ConfigurationManager.spriteHeaderClimable == ConfigurationManager.spriteHeaderClimable
		let tileHangable = currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable
		let isCurrentBlocked = StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile)
		let isLeftBlocked = StasisField.isPositionBlocked(xPosition: xTile - 1, yPosition: yTile)
		let isRightBlocked = StasisField.isPositionBlocked(xPosition: xTile + 1, yPosition: yTile)
		let isDownBlocked = StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile + 1)
		let tileDownLeftCharacteristics = getTileDownLeftCharacteristics()
		let tileDownRightCharacteristics = getTileDownRightCharacteristics()
		let currentImage = imageView.image
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		var viewFrame = imageView.frame

		// Have to set the image property to nil or iPad composits new image, with transparency, over old image
		imageView.image = nil
		// First, check if guard is in stasis field
		if inStasis
			{
			viewFrame.origin.x = CGFloat(xPos)
			viewFrame.origin.y = CGFloat(yPos)
			imageView.frame = viewFrame
			if imageView.image == nil
				{
				imageView.image = currentImage
				}
			return
			}
		// Then, check if guard is on a platform
		else if onPlatform && !readyToDisembark
			{
			if platformRiding!.axis == Platform.TravelAxis.Horizontal
				{
				if platformRiding!.status == .Still
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
					readyToDisembark = true
					}
				else if platformRiding!.status == Platform.Motion.PlatformLeft
					{
					xPos -= ConfigurationManager.platformXAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
						{
						xTile -= 1
						}
					readyToDisembark = true
					}
				viewFrame.origin.x = CGFloat(xPos)
				viewFrame.origin.y = CGFloat(yPos)
				imageView.frame = viewFrame
				if imageView.image == nil
					{
					imageView.image = currentImage
					}
				return
				}
			else
				{
				if platformRiding!.status == .Still
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
					readyToDisembark = true
					}
				else if platformRiding!.status == Platform.Motion.PlatformUp
					{
					yPos -= ConfigurationManager.platformYAxisSteps * deviceMultiplier * platformRiding!.speedMultiplier
					if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile -= 1
						}
					readyToDisembark = true
					}
				viewFrame.origin.x = CGFloat(xPos)
				viewFrame.origin.y = CGFloat(yPos)
				imageView.frame = viewFrame
				if imageView.image == nil
					{
					imageView.image = currentImage
					}
				return
				}
			}
		switch status
			{
			case .Still:
				if onPlatform && platformRiding!.status != .Still
					{
					if platformRiding!.status == Platform.Motion.PlatformRight
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
					}
				else if playerPosition.y < yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable && !onPlatform
					{
					status = .ClimbingUp
					yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
					var image : UIImage!
					if goldPossessed
						{
						let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
						image = firstSprite.image
						animationFrame = firstSprite.frame
						}
					else
						{
						let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
						image = firstSprite.image
						animationFrame = firstSprite.frame
						}
					imageView.image = image
					}
				else if playerPosition.y > yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
					{
					status = .ClimbingDown
					yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
					var image : UIImage!
					if goldPossessed
						{
						let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
						image = firstSprite.image
						animationFrame = firstSprite.frame
						}
					else
						{
						let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
						image = firstSprite.image
						animationFrame = firstSprite.frame
						}
					imageView.image = image
					}
				else if playerPosition.x < xTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
					{
					status = .Left
					xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
					var image : UIImage!
					if goldPossessed
						{
						if tileHangable
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						}
					else
						{
						if tileHangable
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						}
					imageView.image = image
					}
				else if playerPosition.x > xTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
					{
					status = .Right
					xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
					var image : UIImage!
					if goldPossessed
						{
						if tileHangable
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						}
					else
						{
						if tileHangable
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						}
					imageView.image = image
					}
				else	// If the guard can't make the smart move, make a random one
					{
					var directionChosen = false
					// Character is stuck in an unmovable position. Stay there until something changes
					if (!isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked || onPlatform) && !tileClimbable
						{
						status = .Still
						directionChosen = true
						}
					while directionChosen == false
						{
						let randomDirection = arc4random_uniform(UInt32(ConfigurationManager.guardPossibleRandomDirections))
						switch randomDirection
							{
							case 0:				// Left
								if xTile == 0
									{
									continue
									}
								else
									{
									if isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
										{
										status = .Left
										xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
										var image : UIImage!
										if goldPossessed
											{
											if tileHangable
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											}
										else
											{
											if tileHangable
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											}
										imageView.image = image
										directionChosen = true
										}
									}
							case 1:				// Right
								if xTile == currentLevel.width - 1
									{
									continue
									}
								else
									{
									if isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
										{
										status = .Right
										xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
										var image : UIImage!
										if goldPossessed
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										else
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										imageView.image = image
										directionChosen = true
										}
									}
							case 2:				// Up
								if yTile == 0
									{
									continue
									}
								else
									{
									if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
										{
										status = .ClimbingUp
										yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
										var image : UIImage!
										if goldPossessed
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										else
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										imageView.image = image
										directionChosen = true
										}
									}
							case 3:				// Down
								if yTile == currentLevel.height - 1
									{
									continue
									}
								else
									{
									if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
										{
										status = .ClimbingDown
										yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
										var image : UIImage!
										if goldPossessed
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										else
											{
											let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
											image = firstSprite.image
											animationFrame = firstSprite.frame
											}
										imageView.image = image
										directionChosen = true
										}
									}
							default:
								break;
							}
						}
					}
			case .Left:
				if isCurrentBlocked || (isLeftBlocked && xOffset == 0 && xTile > 0)
					{
					status = .Right
					if isCurrentBlocked && xTile < currentLevel.width - 1
						{
						xTile += 1
						xPos = xTile * GameStateManager.sharedManager.getTileWidth()
						}
					}
				else if xOffset != 0
					{
					if xPos - ConfigurationManager.guardXAxisSteps * deviceMultiplier >= ((xTile - 1) * GameStateManager.sharedManager.getTileWidth())
						{
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						}
					else
						{
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						xPos = xTile * GameStateManager.sharedManager.getTileWidth()
						}
					if xPos < ((xTile - 1) * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
						{
						xTile -= 1
						onPlatform = false
						platformRiding = nil
						if yOffset != 0
							{
							status = .Falling
							}
						}
					}
				else
					{
					// See if there's a platform occupying the same space
					let platforms = GameStateManager.sharedManager.getPlatforms()
					var currentPlatform : Platform?
					var platformOffset : Int?
					for nextPlatform in platforms
						{
						if nextPlatform.xTile == xTile && nextPlatform.yTile == yTile
							{
							currentPlatform = nextPlatform
							platformOffset = nextPlatform.getPlatformTopOffset()
							break
							}
						}
					if isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == 0 && !onPlatform && !isDownBlocked
						{
						status = .Falling
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y > yTile && guardSmartDecision && isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
						{
						status = .Falling
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y < yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
						{
						status = .ClimbingUp
						yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y < yTile && guardSmartDecision && currentPlatform != nil
						{
						onPlatform = true
						readyToDisembark = false
						platformRiding = currentPlatform
						yPos = currentPlatform!.yPos + platformOffset! - GameStateManager.sharedManager.getTileHeight()
						status = .Still
						}
					else if playerPosition.y > yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
						{
						status = .ClimbingDown
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y > yTile && guardSmartDecision && currentPlatform != nil
						{
						onPlatform = true
						readyToDisembark = false
						platformRiding = currentPlatform
						yPos = currentPlatform!.yPos + platformOffset! - GameStateManager.sharedManager.getTileHeight()
						status = .Still
						}
					else if playerPosition.x < xTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
						{
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						imageView.image = image
						}
					else if guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
						{
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Left", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						imageView.image = image
						}
					else if !guardSmartDecision		// Pick a random direction
						{
						var directionChosen = false
						// Character is stuck in an unmovable position. Stay there until something changes
						if (!isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked || onPlatform) && !tileClimbable
							{
							status = .Still
							directionChosen = true
							}
						while directionChosen == false
							{
							let randomDirection = arc4random_uniform(UInt32(ConfigurationManager.guardPossibleRandomDirections))
							switch randomDirection
								{
								case 0:				// Left
									if xTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
											{
											xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 1:				// Right
									if xTile == currentLevel.width - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
											{
											status = .Right
											xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 2:				// Up
									if yTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
											{
											status = .ClimbingUp
											yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 3:				// Down
									if yTile == currentLevel.height - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
											{
											if isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down)
												{
												status = .Falling
												}
											else
												{
												status = .ClimbingDown
												}
											yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								default:
									break;
								}
							}
						}
					else
						{
						status = .Still
						}
					}
			case .Right:
				if isCurrentBlocked || (isRightBlocked && xOffset == 0 && xTile < currentLevel.width - 1)
					{
					status = .Left
					if isCurrentBlocked && xTile > 0
						{
						xTile -= 1
						xPos = xTile * GameStateManager.sharedManager.getTileWidth()
						}
					}
				else if xOffset != 0
					{
					if xPos + ConfigurationManager.guardXAxisSteps * deviceMultiplier < ((xTile + 1) * GameStateManager.sharedManager.getTileWidth())
						{
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						}
					else
						{
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right With Gold", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right", currentFrame: animationFrame)
								imageView.image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						xPos = (xTile + 1) * GameStateManager.sharedManager.getTileWidth()
						}
					if xPos > (xTile * GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2))
						{
						xTile += 1
						onPlatform = false
						platformRiding = nil
						if yOffset != 0
							{
							status = .Falling
							}
						}
					}
				else
					{
					// See if there's a platform occupying the same space
					let platforms = GameStateManager.sharedManager.getPlatforms()
					var currentPlatform : Platform?
					var platformOffset : Int?
					for nextPlatform in platforms
						{
						if nextPlatform.xTile == xTile && nextPlatform.yTile == yTile
							{
							currentPlatform = nextPlatform
							platformOffset = nextPlatform.getPlatformTopOffset()
							break
							}
						}
					if (isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || yOffset < 0 && isCharacterFallthroughable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up)) && currentTileCharacteristics & ConfigurationManager.spriteHeaderHangable == 0 && !onPlatform && !isDownBlocked
						{
						status = .Falling
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y > yTile && guardSmartDecision && isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
						{
						status = .Falling
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y < yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
						{
						status = .ClimbingUp
						yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y < yTile && guardSmartDecision && currentPlatform != nil
						{
						onPlatform = true
						readyToDisembark = false
						platformRiding = currentPlatform
						yPos = currentPlatform!.yPos + platformOffset! - GameStateManager.sharedManager.getTileHeight()
						status = .Still
						}
					else if playerPosition.y > yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
						{
						status = .ClimbingDown
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						else
							{
							let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
							image = firstSprite.image
							animationFrame = firstSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.y > yTile && guardSmartDecision && currentPlatform != nil
						{
						onPlatform = true
						readyToDisembark = false
						platformRiding = currentPlatform
						yPos = currentPlatform!.yPos + platformOffset! - GameStateManager.sharedManager.getTileHeight()
						status = .Still
						}
					else if playerPosition.x > xTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
						{
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						imageView.image = image
						}
					else if guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
						{
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right With Gold", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Shimmy", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							else
								{
								let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right", currentFrame: animationFrame)
								image = nextSprite.image
								animationFrame = nextSprite.frame
								}
							}
						imageView.image = image
						}
					else if !guardSmartDecision		// Pick a random direction
						{
						var directionChosen = false
						// Character is stuck in an unmovable position. Stay there until something changes
						if (!isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked || onPlatform) && !tileClimbable
							{
							status = .Still
							directionChosen = true
							}
						while directionChosen == false
							{
							let randomDirection = arc4random_uniform(UInt32(ConfigurationManager.guardPossibleRandomDirections))
							switch randomDirection
								{
								case 0:				// Left
									if xTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
											{
											status = .Left
											xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 1:				// Right
									if xTile == currentLevel.width - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
											{
											xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 2:				// Up
									if yTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
											{
											status = .ClimbingUp
											yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 3:				// Down
									if yTile == currentLevel.height - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !onPlatform && !isDownBlocked
											{
											if isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down)
												{
												status = .Falling
												}
											else
												{
												status = .ClimbingDown
												}
											yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								default:
									break;
								}
							}
						}
					else
						{
						status = .Still
						}
					}
			case .ClimbingUp:
				onPlatform = false
				platformRiding = nil
				if yOffset != 0
					{
					if yPos - ConfigurationManager.guardYAxisSteps * deviceMultiplier >= ((yTile - 1) * GameStateManager.sharedManager.getTileHeight())
						{
						yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else
						{
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						yPos = yTile * GameStateManager.sharedManager.getTileHeight()
						}
					if yPos < ((yTile - 1) * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile -= 1
						}
					}
				else
					{
					// Player is likely hanging off ladder adjacent to guard, leave ladder to catch him
					if playerPosition.y == yTile && playerPosition.x == xTile - 1 && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked && !playerFalling
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					// Player is likely hanging off ladder adjacent to guard, leave ladder to catch him
					else if playerPosition.y == yTile && playerPosition.x == xTile + 1 && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked && !playerFalling
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if playerPosition.y < yTile && guardSmartDecision && tileClimbable && isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up)
						{
						yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						imageView.image = image
						}
					else if playerPosition.x < xTile && playerPosition.y >= yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					// Only let guard fall off ladder in the rare occasion of NOT making the smart decision
					else if playerPosition.x < xTile && playerPosition.y > yTile && !guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if playerPosition.x > xTile && playerPosition.y >= yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					// Only let guard fall off ladder in the rare occasion of NOT making the smart decision
					else if playerPosition.x > xTile && playerPosition.y > yTile && !guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
						{
						yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						imageView.image = image
						}
					else if !guardSmartDecision		// Pick a random direction
						{
						var directionChosen = false
						// Character is stuck in an unmovable position. Stay there until something changes
						if (!isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked || onPlatform) && !tileClimbable
							{
							status = .Still
							directionChosen = true
							}
						while directionChosen == false
							{
							let randomDirection = arc4random_uniform(UInt32(ConfigurationManager.guardPossibleRandomDirections))
							switch randomDirection
								{
								case 0:				// Left
									if xTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
											{
											status = .Left
											xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 1:				// Right
									if xTile == currentLevel.width - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
											{
											status = .Right
											xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 2:				// Up
									if yTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
											{
											yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 3:				// Down
									if yTile == currentLevel.height - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
											{
											status = .ClimbingDown
											yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								default:
									break;
								}
							}
						}
					else
						{
						status = .Still
						}
					}
			case .ClimbingDown:
				onPlatform = false
				platformRiding = nil
				if yOffset != 0
					{
					if yPos + ConfigurationManager.guardYAxisSteps * deviceMultiplier < ((yTile + 1) * GameStateManager.sharedManager.getTileHeight())
						{
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else
						{
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						yPos = (yTile + 1) * GameStateManager.sharedManager.getTileHeight()
						}
					if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile += 1
						}
					}
				else
					{
					// Player is likely hanging off ladder adjacent to guard, leave ladder to catch him
					if playerPosition.y == yTile && playerPosition.x == xTile - 1 && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked && !playerFalling
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					// Player is likely hanging off ladder adjacent to guard, leave ladder to catch him
					else if playerPosition.y == yTile && playerPosition.x == xTile + 1 && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked && !playerFalling
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if playerPosition.y > yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
						{
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						imageView.image = image
						}
					// Only let guard fall off ladder in the rare occasion of NOT making the smart decision
					else if playerPosition.x < xTile && playerPosition.y < yTile && !guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if playerPosition.x < xTile && playerPosition.y <= yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked && tileDownLeftCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0
						{
						status = .Left
						xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					// Only let guard fall off ladder in the rare occasion of NOT making the smart decision
					else if playerPosition.x > xTile && playerPosition.y < yTile && !guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if playerPosition.x > xTile && playerPosition.y <= yTile && guardSmartDecision && isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked && tileDownRightCharacteristics & ConfigurationManager.spriteHeaderFallthroughable == 0
						{
						status = .Right
						xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						else
							{
							if tileHangable
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							else
								{
								let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
								image = firstSprite.image
								animationFrame = firstSprite.frame
								}
							}
						imageView.image = image
						}
					else if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
						{
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						imageView.image = image
						}
					else if !guardSmartDecision		// Pick a random direction
						{
						var directionChosen = false
						// Character is stuck in an unmovable position. Stay there until something changes
						if (!isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) || isLeftBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) || isRightBlocked) && (!isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) || isDownBlocked || onPlatform) && !tileClimbable
							{
							status = .Still
							directionChosen = true
							}
						while directionChosen == false
							{
							let randomDirection = arc4random_uniform(UInt32(ConfigurationManager.guardPossibleRandomDirections))
							switch randomDirection
								{
								case 0:				// Left
									if xTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.left, tileAttribute: surroundingAttributes.left) && !isLeftBlocked
											{
											status = .Left
											xPos -= ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Left")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 1:				// Right
									if xTile == currentLevel.width - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.right, tileAttribute: surroundingAttributes.right) && !isRightBlocked
											{
											status = .Right
											xPos += ConfigurationManager.guardXAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right With Gold")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											else
												{
												if tileHangable
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Shimmy")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												else
													{
													let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
													image = firstSprite.image
													animationFrame = firstSprite.frame
													}
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 2:				// Up
									if yTile == 0
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.up, tileAttribute: surroundingAttributes.up) && tileClimbable
											{
											status = .ClimbingUp
											yPos -= ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								case 3:				// Down
									if yTile == currentLevel.height - 1
										{
										continue
										}
									else
										{
										if isCharacterTraversable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked
											{
											yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
											var image : UIImage!
											if goldPossessed
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb With Gold")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											else
												{
												let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Climb")
												image = firstSprite.image
												animationFrame = firstSprite.frame
												}
											imageView.image = image
											directionChosen = true
											}
										}
								default:
									break;
								}
							}
						}
					else
						{
						status = .Still
						}
					}
			case .Falling:
				if yOffset != 0
					{
					if yPos + ConfigurationManager.guardYAxisSteps * deviceMultiplier < ((yTile + 1) * GameStateManager.sharedManager.getTileHeight())
						{
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							imageView.image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						}
					else
						{
						let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
						imageView.image = nextSprite.image
						animationFrame = nextSprite.frame
						yPos = (yTile + 1) * GameStateManager.sharedManager.getTileHeight()
						}
					if yPos > (yTile * GameStateManager.sharedManager.getTileHeight() + (GameStateManager.sharedManager.getTileHeight() / 2))
						{
						yTile += 1
						}
					}
				else
					{
					if isCharacterFallthroughable(tileNumber: surroundingTiles.down, tileAttribute: surroundingAttributes.down) && !isDownBlocked && !tileHangable
						{
						yPos += ConfigurationManager.guardYAxisSteps * deviceMultiplier
						var image : UIImage!
						if goldPossessed
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb With Gold", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						else
							{
							let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Climb", currentFrame: animationFrame)
							image = nextSprite.image
							animationFrame = nextSprite.frame
							}
						imageView.image = image
						}
					else
						{
						status = .Still
						}
					}
			default:
				break
			}
		if onPlatform
			{
			if xPos < platformRiding!.xPos - (GameStateManager.sharedManager.getTileWidth() / 2) && xPos + GameStateManager.sharedManager.getTileWidth() <= platformRiding!.xPos + GameStateManager.sharedManager.getTileWidth() + (GameStateManager.sharedManager.getTileWidth() / 2)
				{
				onPlatform = false
				platformRiding = nil
				if yOffset != 0
					{
					status = .Falling
					}
				}
			}
		if imageView.image == nil
			{
			imageView.image = currentImage
			}
		viewFrame.origin.x = CGFloat(xPos)
		viewFrame.origin.y = CGFloat(yPos)
		imageView.frame = viewFrame
	}

	func detectCollisions(imageView: UIImageView)
	{
		// First, check for hitting a transporter
		let teleporters = GameStateManager.sharedManager.getTeleporters()
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
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
		if !onPlatform
			{
			let platforms = GameStateManager.sharedManager.getPlatforms()
			for nextPlatform in platforms
				{
				let platformOffset = nextPlatform.getPlatformTopOffset()
				if yPos + GameStateManager.sharedManager.getTileHeight() >= nextPlatform.yPos + platformOffset && yPos + GameStateManager.sharedManager.getTileHeight() <= nextPlatform.yPos + platformOffset + ConfigurationManager.playerYAxisSteps * deviceMultiplier
					{
					if xPos == nextPlatform.xPos
						{
						onPlatform = true
						platformRiding = nextPlatform
						readyToDisembark = false
						yPos = nextPlatform.yPos + platformOffset - GameStateManager.sharedManager.getTileHeight()
						status = .Still
						}
					}
				}
			}
		// Then, check for picking up a gold bar
		if !goldPossessed
			{
			let bars = GameStateManager.sharedManager.getGoldBars()
			for nextBar in bars
				{
				if yTile == nextBar.yTile && xTile == nextBar.xTile
					{
					goldPossessed = true
					nextBar.possessedBy = self
					nextBar.xTile = -1
					nextBar.yTile = -1
					SoundManager.sharedManager.playSentryGetGold()
					}
				}
			}
	}

	func sendToTeleporter(destination: Teleporter, imageView: UIImageView)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let destinationX = destination.xTile
		let destinationY = destination.yTile
		let deviceMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1
		var viewFrame = imageView.frame
		let xOffset = xPos - (xTile * GameStateManager.sharedManager.getTileWidth())
		let entryFromLeft = xOffset < 0 ? true : false
		let xSteps = GameStateManager.sharedManager.getTileWidth() / ConfigurationManager.playerXAxisSteps
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

	func isAboveStasisField() -> Bool
	{
		let stasisFieldOne = GameStateManager.sharedManager.getStasisFieldOne()
		let stasisFieldTwo = GameStateManager.sharedManager.getStasisFieldTwo()
		if (stasisFieldOne.xTile == xTile && stasisFieldOne.yTile == yTile + 1 && stasisFieldOne.stage >= ConfigurationManager.stasisFieldBlockingStage) || (stasisFieldTwo.xTile == xTile && stasisFieldTwo.yTile == yTile + 1 && stasisFieldTwo.stage >= ConfigurationManager.stasisFieldBlockingStage)
			{
			return true
			}
		else
			{
			return false
			}
	}
}
