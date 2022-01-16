/*******************************************************************************
* Teleporter.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a teleporter
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/09/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class Teleporter : Entity
{
	static var startFrame : Int!
	static var endFrame : Int!

	var sendable : Bool
	var receivable : Bool
	var roundtrippable : Bool
	var identifier : UInt8?
	var pair : Teleporter?
	var pulseOut = true
	var cyclesToSkip = ConfigurationManager.cyclesToSkipBetweenTeleporterFrames

	static func setStartFrame(start: Int)
	{
		startFrame = start
	}

	static func setEndFrame(end: Int)
	{
		endFrame = end
	}

	init(positionX: Int, positionY: Int, tileX: Int, tileY: Int, status: Motion, animationFrame: Int, sendable: Bool, receivable: Bool, roundtrippable: Bool, identifier: UInt8?)
	{
		self.sendable = sendable
		self.receivable = receivable
		self.roundtrippable = roundtrippable
		self.identifier = identifier
		super.init(positionX: positionX, positionY: positionY, tileX: tileX, tileY: tileY, status: status, animationFrame: animationFrame)
	}

	func runCycle(imageView: UIImageView)
	{
		if cyclesToSkip > 0
			{
			cyclesToSkip -= 1
			return
			}
		if roundtrippable
			{
			if pulseOut
				{
				if animationFrame < Teleporter.endFrame
					{
					animationFrame += 1
					}
				else
					{
					animationFrame -= 1
					pulseOut = false
					}
				let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
				imageView.image = image
				}
			else
				{
				if animationFrame > Teleporter.startFrame
					{
					animationFrame -= 1
					}
				else
					{
					animationFrame += 1
					pulseOut = true
					}
				let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
				imageView.image = image
				}
			}
		else if receivable
			{
			if animationFrame < Teleporter.endFrame
				{
				animationFrame += 1
				}
			else
				{
				animationFrame = Teleporter.startFrame
				}
			let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
			imageView.image = image
			}
		else if sendable
			{
			if animationFrame == Teleporter.startFrame
				{
				animationFrame = Teleporter.endFrame
				}
			else
				{
				animationFrame -= 1
				}
			let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: animationFrame)
			imageView.image = image
			}
		cyclesToSkip = ConfigurationManager.cyclesToSkipBetweenTeleporterFrames
	}
}
