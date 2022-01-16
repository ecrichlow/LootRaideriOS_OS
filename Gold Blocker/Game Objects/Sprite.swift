/*******************************************************************************
* Sprite.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a sprite
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit

class Sprite
{
	let pixelMap : [[UIColor]]
	let pixelMask : [[Bool]]
	let bitmapData : Data
	let numberOfHeaderBytes : Int
	let headerData : [UInt8]
	let identifier : String?
	let isFirstAnimationFrame : Bool
	let isLastAnimationFrame : Bool
	let backgroundColor : UIColor
	let width : Int
	let height : Int

	init(width: Int, height: Int, header: [UInt8], identifier: String?, firstFrame: Bool, lastFrame: Bool, background: UIColor, pixelMap: [[UIColor]], pixelMask: [[Bool]], bitmapData: Data)
	{
		self.width = width
		self.height = height
		self.headerData = header
		self.numberOfHeaderBytes = header.count
		self.identifier = identifier
		self.isFirstAnimationFrame = firstFrame
		self.isLastAnimationFrame = lastFrame
		self.backgroundColor = background
		self.pixelMap = pixelMap
		self.pixelMask = pixelMask
		self.bitmapData = bitmapData
	}
}
