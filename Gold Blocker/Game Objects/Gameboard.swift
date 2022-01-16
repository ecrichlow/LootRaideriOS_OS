/*******************************************************************************
* Gameboard.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the representation of a gameboard
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation

class Gameboard
{
	var tileMap : [[Int]]
	let spriteMap : [[Int]]
	var attributeMap : [[[UInt8]]]
	let numberOfHeaderBytes : Int
	let headerData : [UInt8]
	let identifier : String?
	let number : Int?
	let width : Int
	let height : Int

	init(width: Int, height: Int, header: [UInt8], identifier: String?, number: Int?, tileMap: [[Int]], spriteMap: [[Int]], attributeMap: [[[UInt8]]])
	{
		self.width = width
		self.height = height
		self.headerData = header
		self.numberOfHeaderBytes = header.count
		self.identifier = identifier
		self.number = number
		self.tileMap = tileMap
		self.spriteMap = spriteMap
		self.attributeMap = attributeMap
	}

	func setTile(xTile: Int, yTile: Int, tileNumber: Int, attributes: [UInt8])
	{
		tileMap[yTile][xTile] = tileNumber
		attributeMap[yTile][xTile] = attributes
	}
}
