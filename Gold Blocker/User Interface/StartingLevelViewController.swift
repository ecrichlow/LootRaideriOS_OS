/*******************************************************************************
* StartingLevelViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Settings Starting Level screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/26/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import FirebaseAnalytics

class StartingLevelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

	@IBOutlet weak var startingLevelTableView: UITableView!

	var sortedAuthorizedLevelsList : [[String: Any]]!
	var unlockAllLevels : Bool!

	// MARK: Lifecycle Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool)
	{
		buildSortedList()
		unlockAllLevels = ConfigurationManager.sharedManager.getUnlockAllLevels()
	}

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

	@IBAction func cancel(_ sender: UIButton)
	{
		dismiss(animated: true, completion: nil)
	}

	// MARK: Game logic

	func buildSortedList()
	{
		let authorizedLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [[String : Any]])
		let authorizedLevels = authorizedLevelsEntry.value
		if sortedAuthorizedLevelsList == nil
			{
			sortedAuthorizedLevelsList = [[String: Any]]()
			}
		else
			{
			sortedAuthorizedLevelsList.removeAll()
			}
		for nextLevelEntry in authorizedLevels
			{
			let entryLevel = nextLevelEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
			var inserted = false
			var index = 0
			for nextAuthEntry in sortedAuthorizedLevelsList
				{
				let nextAuthEntryLevel = nextAuthEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
				if entryLevel < nextAuthEntryLevel
					{
					sortedAuthorizedLevelsList.insert(nextLevelEntry, at: index)
					inserted = true
					break
					}
				index += 1
				}
			if !inserted
				{
				sortedAuthorizedLevelsList.append(nextLevelEntry)
				}
			}
	}

	// MARK: Tableview delegate methods
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
	{
		let row = indexPath.row
		if row == 0 || unlockAllLevels
			{
			return indexPath
			}
		else
			{
			let selectedLevel = sortedAuthorizedLevelsList[row]
			let selectedRowName = selectedLevel[ConfigurationManager.persistenceItemGameboardName] as! String
			if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults)
				{
				return nil
				}
			else
				{
				let beatenLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
				let beatenLevels = beatenLevelsEntry.value
				for levelName in beatenLevels
					{
					if levelName == selectedRowName
						{
						return indexPath
						}
					}
				return nil
				}
			}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let row = indexPath.row
		let levelEntry = sortedAuthorizedLevelsList[row]
		let levelNumber = levelEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
		ConfigurationManager.sharedManager.setStartLevel(newValue: levelNumber)
		Analytics.logEvent("SetStartLevel", parameters: [AnalyticsParameterValue: levelNumber])
		dismiss(animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return ConfigurationManager.defaultSettingsStartLevelRowHeight
	}

	// MARK: Tableview datasource methods

	func numberOfSections(in tableView: UITableView) -> Int
	{
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if section == 0
			{
			let authorizedLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemAuthorizedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [[String : Any]])
			let authorizedLevels = authorizedLevelsEntry.value
			return authorizedLevels.count
			}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "StartLevelTableViewCell", for: indexPath) as! StartLevelTableViewCell
		let row = indexPath.row
		let startLevel = ConfigurationManager.sharedManager.getStartLevel()
		let levelEntry = sortedAuthorizedLevelsList[row]
		let levelNumber = levelEntry[ConfigurationManager.persistenceItemGameboardNumber] as! Int
		let levelName = levelEntry[ConfigurationManager.persistenceItemGameboardName] as! String

		cell.levelImageView.isHidden = true
		cell.levelNameLabel.text = levelName
		cell.levelNumberLabel.text = "Level \(levelNumber)"

		if row == 0 || unlockAllLevels
			{
			let imageName = "Level\(levelNumber).png"
			var image = UIImage(named: imageName)
			if image == nil
				{
				let filename = NSHomeDirectory() + "/Documents/\(imageName)"
				image = UIImage(contentsOfFile: filename)
				}
			cell.levelImageView.image = image
			cell.levelImageView.isHidden = false
			}
		else
			{
			cell.currentStartLevelLabel.isHidden = true
			if PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults)
				{
				let beatenLevelsEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemPlayedLevels, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [String])
				let beatenLevels = beatenLevelsEntry.value
				for beatenLevelName in beatenLevels
					{
					if beatenLevelName == levelName
						{
						let imageName = "Level\(levelNumber).png"
						let image = UIImage(named: imageName)
						cell.levelImageView.image = image
						cell.levelImageView.isHidden = false
						}
					}
				}
			}

		if startLevel == levelNumber
			{
			cell.currentStartLevelLabel.isHidden = false
			}
		else
			{
			cell.currentStartLevelLabel.isHidden = true
			}

		return cell
	}
}
