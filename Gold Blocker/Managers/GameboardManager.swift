/*******************************************************************************
* GameboardManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for the gameboards
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import UIKit
import FirebaseAnalytics

class GameboardManager
{

	private var header : [UInt8]?
	private var gameboards = [Gameboard]()

	static let sharedManager = GameboardManager()

	func loadGameboards()
	{
		// Load default gameboard set first
		let gameboarData = NSDataAsset(name: ConfigurationManager.defaultGameboardFilename)!.data
		let parsedData = parseGameboardsetData(gameboarData)

		header = parsedData.headerData
		gameboards.append(contentsOf: parsedData.gameboardArray)
		// Then load any additional sets downloaded as In-App purchases
		if PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults)
			{
			let purchasedItemsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPurchasedItems, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
			let purchasedItems = purchasedItemsEntry.value
			for nextItem in purchasedItems
				{
				var purchasedItemList : [String]!
				if ConfigurationManager.comboIdentifiers.contains(nextItem)
					{
					purchasedItemList = productIdentifiersForComposite(identifier: nextItem)
					}
				else
					{
					purchasedItemList = [nextItem]
					}
				for item in purchasedItemList
					{
					if ConfigurationManager.sharedManager.fileExistsForProductIdentifier(identifier: item)
						{
						if let boardData = NSData(contentsOf: URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents").appendingPathComponent(ConfigurationManager.sharedManager.filenameForProductIdentifier(identifier: item)))
							{
							let parsedBoardData = parseGameboardsetData(boardData as Data)
							gameboards.append(contentsOf: parsedBoardData.gameboardArray)
							}
						}
					}
				}
			}
	}

	func productIdentifiersForComposite(identifier: String) -> [String]
	{
		switch identifier
			{
			case "LR_0007":
				return ["LR_0003", "LR_0004", "LR_0005", "LR_0006"]
			case "LR_0008":
				return ["LR_0003", "LR_0004", "LR_0005", "LR_0006"]
			case "LR_00014":
				return ["LR_0009", "LR_0010", "LR_0011", "LR_0012", "LR_0013"]
			case "LR_00015":
				return ["LR_0009", "LR_0010", "LR_0011", "LR_0012", "LR_0013"]
			case "LR_00016":
				return ["LR_0003", "LR_0004", "LR_0005", "LR_0006", "LR_0009", "LR_0010", "LR_0011", "LR_0012", "LR_0013"]
			case "LR_00017":
				return ["LR_0003", "LR_0004", "LR_0005", "LR_0006", "LR_0009", "LR_0010", "LR_0011", "LR_0012", "LR_0013"]
			default:
				break
			}
		return [String]()
	}

	func getGameboard(number: Int) -> Gameboard
	{
		for nextGameboard in gameboards
			{
			if nextGameboard.number == number + 1
				{
				return nextGameboard
				}
			}
		// The above should catch the correct level. If for some reason it doesn't, default to the first level
		Analytics.logEvent("GameboardError", parameters: [AnalyticsParameterLevel: number])
		return gameboards[0]
	}

	private func parseGameboardsetData(_ fileData: Data) -> (headerData : [UInt8], gameboardArray: [Gameboard])
	{
		var parseData = Data(fileData)
		var header = [UInt8]()
		var gameboardArray = [Gameboard]()
		if isGameboardSetHeader(parseData)
			{
			parseData = parseData.advanced(by: ConfigurationManager.gameboardSetDefaultHeader.count)
			let headerCount = parseData[0]
			if headerCount > 0
				{
				let count = Int(headerCount)
				parseData = parseData.advanced(by: 1)
				for index in 0..<count
					{
					header.append(parseData[index])
					}
				parseData = parseData.advanced(by: count)
				}
			else
				{
				parseData = parseData.advanced(by: 1)
				}
			while isGameboardHeader(parseData)
				{
				parseData = parseData.advanced(by: ConfigurationManager.gameboardDelineator.count)
				var headerBytes = [UInt8]()
				var identifier : String?
				var number : Int?
				if isGameboardHeaderDataHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.gameboardSectionHeaderDelineator.count)
					let headerCount = parseData[0]
					if headerCount > 0
						{
						let count = Int(headerCount)
						parseData = parseData.advanced(by: 1)
						for index in 0..<count
							{
							headerBytes.append(parseData[index])
							}
						parseData = parseData.advanced(by: count)
						number = Int(headerBytes[0])
						}
					else
						{
						parseData = parseData.advanced(by: 1)
						}
					}
				if isGameboardIdentifierHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.gameboardSectionIdentifierDelineator.count)
					let identifierCount = parseData[0]
					let count = Int(identifierCount)
					var identifierBytes = Data()
					parseData = parseData.advanced(by: 1)
					for index in 0..<count
						{
						identifierBytes.append(parseData[index])
						}
					identifier = String(data: identifierBytes, encoding: String.Encoding.utf8)
					parseData = parseData.advanced(by: count)
					}
				var width : Int!
				var height : Int!
				if isGameboardDimensionsHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.gameboardSectionDimensionsDelineator.count)
					var dimenHigherByte = Int(parseData[0])
					var dimenLowerByte = Int(parseData[1])
					width = dimenLowerByte + (dimenHigherByte << 8)
					parseData = parseData.advanced(by: 2)
					dimenHigherByte = Int(parseData[0])
					dimenLowerByte = Int(parseData[1])
					height = dimenLowerByte + (dimenHigherByte << 8)
					parseData = parseData.advanced(by: 2)
					}
				var tileMap = [[Int]](repeating: [Int](repeating: 0, count: width), count: height)
				var spriteMap = [[Int]](repeating: [Int](repeating: -1, count: width), count: height)
				var attributeMap = [[[UInt8]]](repeating: [[UInt8]](repeating: [UInt8](), count: width), count: height)
				if isTileMapHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.gameboardSectionTileMapDelineator.count)
					for rows in 0..<height
						{
						for columns in 0..<width
							{
							let tileByte = Int(parseData[0])
							let spriteByte = Int(parseData[1])
							let attributeCountByte = Int(parseData[2])
							if parseData.count > 3
								{
								parseData = parseData.advanced(by: 3)
								}
							if tileByte > 0
								{
								tileMap[rows][columns] = tileByte - 1
								}
							spriteMap[rows][columns] = spriteByte - 1
							if attributeCountByte > 0
								{
									for _ in 0..<attributeCountByte
									{
									let nextAttribute = parseData[0]
									attributeMap[rows][columns].append(nextAttribute)
									if parseData.count > 1
										{
										parseData = parseData.advanced(by: 1)
										}
									}
								}
							}
						}
					}
				let gameboard = Gameboard(width: width, height: height, header: headerBytes, identifier: identifier, number: number, tileMap: tileMap, spriteMap: spriteMap, attributeMap: attributeMap)
				gameboardArray.append(gameboard)
				// Add gameboard to list of authorized gameboards if necessary
				ConfigurationManager.sharedManager.addAuthorizedLevel(number: number!, name: identifier!)
				}
			}
		else
			{
            let alert = UIAlertController(title: "File Error", message: "Not a valid Gameboard file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            	}))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
			}
		return (header, gameboardArray)
	}

	private func isGameboardSetHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.gameboardSetDefaultHeader[0] && data[1] == ConfigurationManager.gameboardSetDefaultHeader[1] && data[2] == ConfigurationManager.gameboardSetDefaultHeader[2]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isGameboardHeader(_ data: Data) -> Bool
	{
		if data.count < ConfigurationManager.gameboardDelineator.count
			{
			return false
			}
		else if data[0] == ConfigurationManager.gameboardDelineator[0] && data[1] == ConfigurationManager.gameboardDelineator[1] && data[2] == ConfigurationManager.gameboardDelineator[2] && data[3] == ConfigurationManager.gameboardDelineator[3] && data[4] == ConfigurationManager.gameboardDelineator[4]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isGameboardHeaderDataHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.gameboardSectionHeaderDelineator[0] && data[1] == ConfigurationManager.gameboardSectionHeaderDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isGameboardIdentifierHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.gameboardSectionIdentifierDelineator[0] && data[1] == ConfigurationManager.gameboardSectionIdentifierDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isGameboardDimensionsHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.gameboardSectionDimensionsDelineator[0] && data[1] == ConfigurationManager.gameboardSectionDimensionsDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isTileMapHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.gameboardSectionTileMapDelineator[0] && data[1] == ConfigurationManager.gameboardSectionTileMapDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

}
