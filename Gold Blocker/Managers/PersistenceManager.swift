/*******************************************************************************
* PersistenceManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for preference and data
*						local storage
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation

class PersistenceManager
{
	enum PersistenceSource : Int
	{
		case Memory
		case UserDefaults
		case FileStorage
	}

	enum PersistenceProtectionLevel : Int
	{
		case Unsecured
		case Secured
	}

	enum PersistenceLifespan : Int
	{
		case Immortal
		case Session
		case Expiration
	}

	enum PersistenceDataType : Int
	{
		case Number
		case String
		case Array
		case Dictionary
		case Data
	}

	enum PersistenceReadResultCode : Int
	{
		case Success
		case NotFound
		case Expired
	}

	static let sharedManager = PersistenceManager()

	var memoryStore = [String: Dictionary<String, Any>]()

	init()
	{
		Timer.scheduledTimer(timeInterval: ConfigurationManager.timerPeriodPersistenceExpirationCheck, target: self, selector: #selector(self.checkForExpiredItems), userInfo: nil, repeats: true)
	}

	@discardableResult func saveValue(name: String, value: Any, type: PersistenceDataType, destination: PersistenceSource, protection: PersistenceProtectionLevel, lifespan: PersistenceLifespan, expiration: Date?, overwrite: Bool) -> Bool
	{
		var savedDataElement = [String: Any]()
		savedDataElement[ConfigurationManager.persistencElementValue] = value
		savedDataElement[ConfigurationManager.persistencElementType] = type.rawValue
		savedDataElement[ConfigurationManager.persistencElementSource] = destination.rawValue
		savedDataElement[ConfigurationManager.persistencElementProtection] = protection.rawValue
		savedDataElement[ConfigurationManager.persistencElementLifespan] = lifespan.rawValue
		savedDataElement[ConfigurationManager.persistencElementExpiration] = expiration
		if destination == .Memory
			{
			if memoryStore[name] == nil || overwrite
				{
				memoryStore[name] = savedDataElement
				}
			else if memoryStore[name] != nil && !overwrite
				{
				return false
				}
			}
		else if destination == .UserDefaults
			{
			if UserDefaults.standard.object(forKey: name) == nil || overwrite
				{
				UserDefaults.standard.set(savedDataElement, forKey: name)
				UserDefaults.standard.synchronize()
				}
			else if UserDefaults.standard.object(forKey: name) != nil && !overwrite
				{
				return false
				}
			}
		else if destination == .FileStorage
			{
			let destinationPath = NSHomeDirectory()
			let destPath = URL(fileURLWithPath: destinationPath)
			let destFile = destPath.appendingPathComponent("Documents").appendingPathComponent(name)
			let dictionary = savedDataElement as! NSDictionary
			if !FileManager.default.fileExists(atPath: destFile.path)
				{
				dictionary.write(to: destFile, atomically: true)
				}
			else if overwrite
				{
				do
					{
					try FileManager.default.removeItem(at: destFile)
					dictionary.write(to: destFile, atomically: true)
					}
				catch
					{
					return (false);
					}
				}
			else
				{
				return false
				}
			}
		if let expirationDate = expiration
			{
			if UserDefaults.standard.object(forKey: ConfigurationManager.persistenceManagementExpiringItems) == nil
				{
				let expiringItemEntries = [expirationDate: [name]]
				UserDefaults.standard.set(expiringItemEntries, forKey: ConfigurationManager.persistenceManagementExpiringItems)
				}
			else
				{
				var expiringItemEntries = UserDefaults.standard.object(forKey: ConfigurationManager.persistenceManagementExpiringItems) as! Dictionary<Date, [String]>
				if var dateExpiringItemList = expiringItemEntries[expirationDate]
					{
					dateExpiringItemList.append(name)
					expiringItemEntries[expirationDate] = dateExpiringItemList
					}
				else
					{
					expiringItemEntries[expirationDate] = [name]
					}
				UserDefaults.standard.set(expiringItemEntries, forKey: ConfigurationManager.persistenceManagementExpiringItems)
				UserDefaults.standard.synchronize()
				}
			}
		return true
	}

	func readValue(name: String, from: PersistenceSource) -> (result: PersistenceReadResultCode, value: Any?)
	{
		if from == .Memory
			{
			if memoryStore[name] == nil
				{
				return (result: .NotFound, value: nil)
				}
			else
				{
				let savedDataElement = memoryStore[name] as! Dictionary<String, Any>
				let value = savedDataElement[ConfigurationManager.persistencElementValue]
				return (result: .Success, value: value)
				}
			}
		else if from == .UserDefaults
			{
			if UserDefaults.standard.object(forKey: name) == nil
				{
				return (result: .NotFound, value: nil)
				}
			else
				{
				let savedDataElement = UserDefaults.standard.object(forKey: name) as! Dictionary<String, Any>
				let value = savedDataElement[ConfigurationManager.persistencElementValue]
				return (result: .Success, value: value)
				}
			}
		else if from == .FileStorage
			{
			let sourcePath = NSHomeDirectory()
			let srcPath = URL(fileURLWithPath: sourcePath)
			let srcFile = srcPath.appendingPathComponent("Documents").appendingPathComponent(name)
			if !FileManager.default.fileExists(atPath: srcFile.path)
				{
				return (result: .NotFound, value: nil)
				}
			else
				{
				if let savedDataElement = NSDictionary.init(contentsOf: srcFile)
					{
					let value = savedDataElement[ConfigurationManager.persistencElementValue]
					return (result: .Success, value: value)
					}
				else
					{
					return (result: .NotFound, value: nil)
					}
				}
			}
		return (result: .NotFound, value: nil)
	}

	func checkForValue(name: String, from: PersistenceSource) -> Bool
	{
		if from == .Memory
			{
			if memoryStore[name] == nil
				{
				return false
				}
			else
				{
				return true
				}
			}
		else if from == .UserDefaults
			{
			if UserDefaults.standard.object(forKey: name) == nil
				{
				return false
				}
			else
				{
				return true
				}
			}
		else if from == .FileStorage
			{
			let sourcePath = NSHomeDirectory()
			let srcPath = URL(fileURLWithPath: sourcePath)
			let srcFile = srcPath.appendingPathComponent("Documents").appendingPathComponent(name)
			if FileManager.default.fileExists(atPath: srcFile.path)
				{
				return true
				}
			}
		return false
	}

	@discardableResult func clearValue(name: String, from: PersistenceSource) -> Bool
	{
		if checkForValue(name: name, from: from)
			{
			if from == .Memory
				{
				memoryStore[name] = nil
				return true
				}
			else if from == .UserDefaults
				{
				UserDefaults.standard.removeObject(forKey: name)
				UserDefaults.standard.synchronize()
				return true
				}
			else if from == .FileStorage
				{
				let sourcePath = NSHomeDirectory()
				let srcPath = URL(fileURLWithPath: sourcePath)
				let srcFile = srcPath.appendingPathComponent("Documents").appendingPathComponent(name)
				if FileManager.default.fileExists(atPath: srcFile.path)
					{
					do
						{
						try FileManager.default.removeItem(at: srcFile)
						return true
						}
					catch
						{
						return false
						}
					}
				}
			}
		return false
	}

	@objc func checkForExpiredItems()
	{
		if UserDefaults.standard.object(forKey: ConfigurationManager.persistenceManagementExpiringItems) != nil
			{
			let expiringItemEntries = UserDefaults.standard.object(forKey: ConfigurationManager.persistenceManagementExpiringItems) as! Dictionary<Date, [String]>
			var freshItemEntries = expiringItemEntries
			for nextExpirationDate in expiringItemEntries.keys
				{
				if nextExpirationDate.timeIntervalSinceNow < 0
					{
					let expiringItemList = expiringItemEntries[nextExpirationDate]
					for nextItem in expiringItemList!
						{
						UserDefaults.standard.removeObject(forKey: nextItem)
						}
					freshItemEntries.removeValue(forKey: nextExpirationDate)
					}
				}
			UserDefaults.standard.set(freshItemEntries, forKey: ConfigurationManager.persistenceManagementExpiringItems)
			UserDefaults.standard.synchronize()
			}
	}
}
