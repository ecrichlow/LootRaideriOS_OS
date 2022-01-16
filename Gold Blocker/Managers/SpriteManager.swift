/*******************************************************************************
* SpriteManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for the sprites
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*	01/02/20		*	EGC	*	Refactoring to store and reuse a set of images
*******************************************************************************/

import Foundation
import UIKit

class SpriteManager
{

	var header : [UInt8]?
	var sprites : [Sprite]?
	var images = [UIImage:Sprite]()

	static let sharedManager = SpriteManager()

	func loadSprites()
	{
		var spriteFilename : String!
		if UIDevice.current.userInterfaceIdiom == .pad
			{
			spriteFilename = ConfigurationManager.alternateSpriteFilename
			}
		else
			{
			spriteFilename = ConfigurationManager.defaultSpriteFilename
			}
		let spriteData = NSDataAsset(name: spriteFilename!)!.data
		let parsedData = parseSpritesetData(spriteData)
	
		header = parsedData.headerData
		sprites = parsedData.spriteArray
	}

	func getSprite(number: Int) -> Sprite?
	{
		if number < sprites!.count
			{
			return sprites![number]
			}
		else
			{
			return nil
			}
	}

	func imageForSprite(sprite: Sprite) -> UIImage
	{
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//		let image = CIImage(bitmapData: sprite.bitmapData, bytesPerRow: (sprite.width * 4), size: CGSize(width: sprite.width, height: sprite.height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//		return UIImage(ciImage: image)
		return cachedImageForSprite(sprite)
	}

	func imageForSpriteNumber(spriteNumber: Int) -> UIImage
	{
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//		let image = CIImage(bitmapData: sprites![spriteNumber].bitmapData, bytesPerRow: (sprites![spriteNumber].width * 4), size: CGSize(width: sprites![spriteNumber].width, height: sprites![spriteNumber].height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//		return UIImage(ciImage: image)
		return cachedImageForSprite(sprites![spriteNumber])
	}

	func spriteForFirstFrameOfAnimationNamed(name: String) -> Sprite
	{
		var index = 0
		for nextSprite in sprites!
			{
			if nextSprite.isFirstAnimationFrame == true && nextSprite.identifier == name
				{
				return sprites![index]
				}
			index += 1
			}
		return sprites![0]
	}

	func imageForFirstFrameOfAnimationNamed(name: String) -> (image: UIImage, frame: Int)
	{
		var index = 0
		for nextSprite in sprites!
			{
			if nextSprite.isFirstAnimationFrame == true && nextSprite.identifier == name
				{
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//				let image = CIImage(bitmapData: nextSprite.bitmapData, bytesPerRow: (nextSprite.width * 4), size: CGSize(width: nextSprite.width, height: nextSprite.height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//				return (UIImage(ciImage: image), index)
				return (cachedImageForSprite(nextSprite), index)
				}
			index += 1
			}
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//		let image = CIImage(bitmapData: sprites![0].bitmapData, bytesPerRow: (sprites![0].width * 4), size: CGSize(width: sprites![0].width, height: sprites![0].height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//		return (UIImage(ciImage: image), 0)
		return (cachedImageForSprite(sprites![0]), index)
	}

	// If spriteset file isn't properly constructed with an end sprite for every beginning sprite for an animation, this func can crash the app
	func imageForNextFrameOfAnimationNamed(name: String, currentFrame: Int) -> (image: UIImage, frame: Int)
	{
		if currentFrame == sprites!.count - 1
			{
			return imageForFirstFrameOfAnimationNamed(name: name)
			}
		for index in currentFrame..<(sprites!.count - 1)
			{
			let currentSprite = sprites![index]
			let nextSprite = sprites![index + 1]
			if currentSprite.isLastAnimationFrame
				{
				return imageForFirstFrameOfAnimationNamed(name: name)
				}
			else
				{
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//				let image = CIImage(bitmapData: nextSprite.bitmapData, bytesPerRow: (nextSprite.width * 4), size: CGSize(width: nextSprite.width, height: nextSprite.height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//				return (UIImage(ciImage: image), currentFrame + 1)
				return (cachedImageForSprite(nextSprite), currentFrame + 1)
				}
			}
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//		let image = CIImage(bitmapData: sprites![0].bitmapData, bytesPerRow: (sprites![0].width * 4), size: CGSize(width: sprites![0].width, height: sprites![0].height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//		return (UIImage(ciImage: image), 0)
		return (cachedImageForSprite(sprites![0]), 0)
	}

	// If spriteset file isn't properly constructed with an end sprite for every beginning sprite for an animation, this func can crash the app
	func imageForLastFrameOfAnimationNamed(name: String) -> (image: UIImage, frame: Int)
	{
		var index = 0
		var currentAnimationIdentifier : String?
		for nextSprite in sprites!
			{
			if nextSprite.isFirstAnimationFrame
				{
				currentAnimationIdentifier = nextSprite.identifier
				}
			if nextSprite.isLastAnimationFrame == true && currentAnimationIdentifier == name
				{
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//				let image = CIImage(bitmapData: nextSprite.bitmapData, bytesPerRow: (nextSprite.width * 4), size: CGSize(width: nextSprite.width, height: nextSprite.height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//				return (UIImage(ciImage: image), index)
				return (cachedImageForSprite(nextSprite), index)
				}
			index += 1
			}
// 1-4-20 - EGC - Refactoring this to stop creating so many images, instead storing and reusing one for each sprite
//		let image = CIImage(bitmapData: sprites![0].bitmapData, bytesPerRow: (sprites![0].width * 4), size: CGSize(width: sprites![0].width, height: sprites![0].height), format: kCIFormatARGB8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB))
//		return (UIImage(ciImage: image), 0)
		return (cachedImageForSprite(sprites![0]), 0)
	}

	private func parseSpritesetData(_ fileData: Data) -> (headerData : [UInt8], spriteArray: [Sprite])
	{
		var parseData = Data(fileData)
		var header = [UInt8]()
		var spriteArray = [Sprite]()
		if isSpriteSetHeader(parseData)
			{
			parseData = parseData.advanced(by: ConfigurationManager.spriteSetDefaultHeader.count)
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
			while isSpriteHeader(parseData)
				{
				parseData = parseData.advanced(by: ConfigurationManager.spriteDelineator.count)
				var headerBytes = [UInt8]()
				var identifier : String?
				if isSpriteHeaderDataHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionHeaderDelineator.count)
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
						}
					else
						{
						parseData = parseData.advanced(by: 1)
						}
					}
				if isSpriteIdentifierHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionIdentifierDelineator.count)
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
				var animStartFrame = false
				var animEndFrame = false
				if isAnimationHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionAnimationDelineator.count)
					let animationByte = parseData[0]
					if animationByte == 0x01
						{
						animStartFrame = true
						}
					else if animationByte == 0x02
						{
						animEndFrame = true
						}
					parseData = parseData.advanced(by: 1)
					}
				var backgroundColor : UIColor!
				if isBackgroundHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionBackgroundColorDelineator.count)
					let alphaByte = parseData[0]
					let redByte = parseData[1]
					let greenByte = parseData[2]
					let blueByte = parseData[3]
					parseData = parseData.advanced(by: 4)
					let alpha = CGFloat(Int(alphaByte) / 255)
					let red = CGFloat(Int(redByte) / 255)
					let green = CGFloat(Int(greenByte) / 255)
					let blue = CGFloat(Int(blueByte) / 255)
					let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
					backgroundColor = color
					}
				var width : Int!
				var height : Int!
				if isSpriteDimensionsHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionDimensionsDelineator.count)
					var dimenHigherByte = Int(parseData[0])
					var dimenLowerByte = Int(parseData[1])
					width = dimenLowerByte + (dimenHigherByte << 8)
					parseData = parseData.advanced(by: 2)
					dimenHigherByte = Int(parseData[0])
					dimenLowerByte = Int(parseData[1])
					height = dimenLowerByte + (dimenHigherByte << 8)
					parseData = parseData.advanced(by: 2)
					}
				var pixelMap = [[UIColor]](repeating: [UIColor](repeating: UIColor.clear, count: width), count: height)
				var bitmapData = Data()
				if isPixelDataHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionPixelMapDelineator.count)
					for rows in 0..<height
						{
						for columns in 0..<width
							{
							let alphaByte = parseData[0]
							let redByte = parseData[1]
							let greenByte = parseData[2]
							let blueByte = parseData[3]
							let alpha = CGFloat(Float(alphaByte) / 255.0)
							let red = CGFloat(Float(redByte) / 255.0)
							let green = CGFloat(Float(greenByte) / 255.0)
							let blue = CGFloat(Float(blueByte) / 255.0)
// 04-19-20 - EGC - Switching from alpha byte first to alpha byte last to silence runtime warning about the pixel format being unsupported
// 04-20-20 - EGC - With the switch from CIImage to CGImage this is how the data needed to be structured
							bitmapData.append(parseData[1])
							bitmapData.append(parseData[2])
							bitmapData.append(parseData[3])
							if ConfigurationManager.makeBlackPixelsTransparent && red == 0.0 && green == 0.0 && blue == 0.0
								{
								let color = UIColor(red: red, green: green, blue: blue, alpha: 0.0)
								pixelMap[rows][columns] = color
								bitmapData.append(0)
								}
							else
								{
								let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
								pixelMap[rows][columns] = color
								bitmapData.append(parseData[0])
								}
// 04-19-20 - EGC - Switching from alpha byte first to alpha byte last to silence runtime warning about the pixel format being unsupported
// 04-20-20 - EGC - With the switch from CIImage to CGImage this is how the data needed to be structured
//							bitmapData.append(parseData[1])
//							bitmapData.append(parseData[2])
//							bitmapData.append(parseData[3])
							parseData = parseData.advanced(by: 4)
							}
						}
					}
				var pixelMask = [[Bool]](repeating: [Bool](repeating: false, count: width), count: height)
				if isPixelMaskDataHeader(parseData)
					{
					parseData = parseData.advanced(by: ConfigurationManager.spriteSectionPixelMaskDelineator.count)
					for rows in 0..<height
						{
						for columns in 0..<width
							{
							let maskByte = parseData[0]
							if maskByte == 0
								{
								pixelMask[rows][columns] = false
								}
							else
								{
								pixelMask[rows][columns] = true
								}
							if parseData.count > 1
								{
								parseData = parseData.advanced(by: 1)
								}
							}
						}
					}
				let sprite = Sprite(width: width, height: height, header: headerBytes, identifier: identifier, firstFrame: animStartFrame, lastFrame: animEndFrame, background: backgroundColor, pixelMap: pixelMap, pixelMask: pixelMask, bitmapData: bitmapData)
				spriteArray.append(sprite)
				}
			}
		else
			{
            let alert = UIAlertController(title: "File Error", message: "Not a valid Sprite file", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            	}))
				UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
			}
		return (header, spriteArray)
	}

	private func isSpriteSetHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSetDefaultHeader[0] && data[1] == ConfigurationManager.spriteSetDefaultHeader[1] && data[2] == ConfigurationManager.spriteSetDefaultHeader[2]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isSpriteHeader(_ data: Data) -> Bool
	{
		if data.count < ConfigurationManager.spriteDelineator.count
			{
			return false
			}
		else if data[0] == ConfigurationManager.spriteDelineator[0] && data[1] == ConfigurationManager.spriteDelineator[1] && data[2] == ConfigurationManager.spriteDelineator[2] && data[3] == ConfigurationManager.spriteDelineator[3] && data[4] == ConfigurationManager.spriteDelineator[4]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isSpriteHeaderDataHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionHeaderDelineator[0] && data[1] == ConfigurationManager.spriteSectionHeaderDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isSpriteIdentifierHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionIdentifierDelineator[0] && data[1] == ConfigurationManager.spriteSectionIdentifierDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isAnimationHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionAnimationDelineator[0] && data[1] == ConfigurationManager.spriteSectionAnimationDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isBackgroundHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionBackgroundColorDelineator[0] && data[1] == ConfigurationManager.spriteSectionBackgroundColorDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isSpriteDimensionsHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionDimensionsDelineator[0] && data[1] == ConfigurationManager.spriteSectionDimensionsDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isPixelDataHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionPixelMapDelineator[0] && data[1] == ConfigurationManager.spriteSectionPixelMapDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func isPixelMaskDataHeader(_ data: Data) -> Bool
	{
		if data[0] == ConfigurationManager.spriteSectionPixelMaskDelineator[0] && data[1] == ConfigurationManager.spriteSectionPixelMaskDelineator[1]
			{
			return true
			}
		else
			{
			return false
			}
	}

	private func doesSpriteHaveCachedImage(_ sprite: Sprite) -> Bool
	{
		let values = images.values

		for nextSprite in values
			{
			if nextSprite === sprite
				{
				return true
				}
			}
		return false
	}

	private func cachedImageForSprite(_ sprite: Sprite) -> UIImage
	{
		if doesSpriteHaveCachedImage(sprite)
			{
			let keys = images.keys

			for nextKey in keys
				{
				let value = images[nextKey]
				if value === sprite
					{
					return nextKey
					}
				}
			}
		else
			{
// 04-19-20 - EGC - Switching from alpha byte first to alpha byte last to silence runtime warning about the pixel format being unsupported
// 04/20/20 - EGC - Switching from CIImage to build the sprites to CGImage because CIImage stopped working on iPads in iOS 13
//			let image = UIImage(ciImage: tempImage)
			let dataProvider = CGDataProvider.init(data: sprite.bitmapData as CFData)
			let colorSpace = CGColorSpaceCreateDeviceRGB()
			var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
			bitmapInfo |= CGImageAlphaInfo.last.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
			let cgImage = CGImage.init(width: sprite.width, height: sprite.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: (sprite.width * 4), space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
			let image = UIImage(cgImage: cgImage!)
			images[image] = sprite
			return image
			}
		return UIImage()
	}
}
