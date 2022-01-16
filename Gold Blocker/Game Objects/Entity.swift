/*******************************************************************************
* Entity.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the base class for in-game entities
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/08/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation

class Entity
{
	enum Motion
	{
		case Still
		case Left
		case Right
		case ClimbingDown
		case ClimbingUp
		case Falling
		case PlatformLeft
		case PlatformRight
		case PlatformUp
		case PlatformDown
	}

	static var nextEntityID = 0

	var entityID : Int
	var xPos : Int
	var yPos : Int
	var xTile : Int
	var yTile : Int
	var status : Motion
	var animationFrame : Int

	static func getNextID() -> Int
	{
		nextEntityID += 1
		return nextEntityID - 1
	}

	static func getLastID() -> Int
	{
		return nextEntityID
	}

	init(positionX: Int, positionY: Int, tileX: Int, tileY: Int, status: Motion, animationFrame: Int)
	{
		entityID = Entity.getNextID()
		self.xPos = positionX
		self.yPos = positionY
		self.xTile = tileX
		self.yTile = tileY
		self.status = status
		self.animationFrame = animationFrame
	}

	func getCurrentTile() -> Int
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		return currentLevel.tileMap[yTile][xTile]
	}

	func getCurrentTileAttributes() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		var attributes = 0 as UInt8
		if currentLevel.attributeMap[yTile][xTile].count > 0
			{
			attributes = currentLevel.attributeMap[yTile][xTile][0]
			}
		else
			{
			attributes = 0
			}
		return attributes
	}

	func getCurrentTileCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		let tileNumber = currentLevel.tileMap[yTile][xTile]
		if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		return getCharacteristicsForTileNumber(tileNumber: tileNumber)
	}

	func getTileLeftCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if xTile == 0
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile][xTile - 1]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getTileRightCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if xTile == currentLevel.width - 1
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile][xTile + 1]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getTileDownLeftCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if xTile == 0 || yTile == currentLevel.height - 1
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile + 1][xTile - 1]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getTileDownRightCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if xTile == currentLevel.width - 1 || yTile == currentLevel.height - 1
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile + 1][xTile + 1]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getTileUpCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if yTile == 0
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile - 1][xTile]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getTileDownCharacteristics() -> UInt8
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		if yTile == currentLevel.height - 1
			{
			return 0
			}
		else if (StasisField.isPositionBlocked(xPosition: xTile, yPosition: yTile))
			{
			return 0
			}
		else
			{
			let tileNumber = currentLevel.tileMap[yTile + 1][xTile]
			return getCharacteristicsForTileNumber(tileNumber: tileNumber)
			}
	}

	func getCharacteristicsForTileNumber(tileNumber: Int) -> UInt8
	{
		let tileSprite = SpriteManager.sharedManager.getSprite(number: tileNumber)
		let spriteCharacteristic = tileSprite!.headerData[0]
		// Tweak made because sprite files didn't properly set rope tiles as fallthroughable
		if spriteCharacteristic & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable
			{
			return spriteCharacteristic | ConfigurationManager.spriteHeaderFallthroughable
			}
		return spriteCharacteristic
	}

	func getSurroundingTiles() -> (left: Int, right: Int, up: Int, down: Int)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		var left = -1
		var right = -1
		var up = -1
		var down = -1

		if xTile > 0
			{
			left = currentLevel.tileMap[yTile][xTile - 1]
			}
		if xTile < (currentLevel.width - 1)
			{
			right = currentLevel.tileMap[yTile][xTile + 1]
			}
		if yTile > 0
			{
			up = currentLevel.tileMap[yTile - 1][xTile]
			}
		if yTile < (currentLevel.height - 1)
			{
			down = currentLevel.tileMap[yTile + 1][xTile]
			}

		return (left, right, up, down)
	}

	func getSurroundingAttributes() -> (left: UInt8, right: UInt8, up: UInt8, down: UInt8)
	{
		let currentLevel = GameboardManager.sharedManager.getGameboard(number: GameStateManager.sharedManager.getCurrentLevel() - 1)
		var left = 0 as UInt8
		var right = 0 as UInt8
		var up = 0 as UInt8
		var down = 0 as UInt8

		// Figure Left clearness
		if xTile > 0
			{
			if currentLevel.attributeMap[yTile][xTile - 1].count > 0
				{
				left = currentLevel.attributeMap[yTile][xTile - 1][0]
				}
			}
		// Figure Right clearness
		if xTile < (currentLevel.width - 1)
			{
			if currentLevel.attributeMap[yTile][xTile + 1].count > 0
				{
				right = currentLevel.attributeMap[yTile][xTile + 1][0]
				}
			}
		// Figure Top clearness
		if yTile > 0
			{
			if currentLevel.attributeMap[yTile - 1][xTile].count > 0
				{
				up = currentLevel.attributeMap[yTile - 1][xTile][0]
				}
			}
		// Figure Bottom clearness
		if yTile < (currentLevel.height - 1)
			{
			if currentLevel.attributeMap[yTile + 1][xTile].count > 0
				{
				down = currentLevel.attributeMap[yTile + 1][xTile][0]
				}
			}

		return (left, right, up, down)
	}

	func isCharacterTraversable(tileNumber: Int, tileAttribute: UInt8) -> Bool
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
		if spriteAttribute & ConfigurationManager.spriteHeaderTraversable == ConfigurationManager.spriteHeaderTraversable
			{
			traversable = true
			}
		else if spriteAttribute == 0
			{
			return false
			}
		// Then, check the attributes of the tiles position
		if tileAttribute == 0
			{
			traversable = true
			}
		return traversable
	}

	func isCharacterFallthroughable(tileNumber: Int, tileAttribute: UInt8) -> Bool
	{
		guard tileNumber > -1
			else
				{
				return false
				}
		let tileSprite = SpriteManager.sharedManager.getSprite(number: tileNumber)
		let spriteAttribute = tileSprite!.headerData[0]
		var fallthroughable = false
		// First, check the tile sprite's attributes
			// Tweak made because sprite files didn't properly set rope tiles as fallthroughable
		if (spriteAttribute & ConfigurationManager.spriteHeaderFallthroughable == ConfigurationManager.spriteHeaderFallthroughable) || (spriteAttribute & ConfigurationManager.spriteHeaderHangable == ConfigurationManager.spriteHeaderHangable)
			{
			fallthroughable = true
			}
		else if spriteAttribute == 0
			{
			return false
			}
		return fallthroughable
	}
}
