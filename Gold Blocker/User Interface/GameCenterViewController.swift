/*******************************************************************************
* GameCenterViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's main screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/03/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import FirebaseAnalytics

class GameCenterViewController: UIViewController
{

	@IBOutlet weak var highScoreListView: UIView!
	@IBOutlet weak var highScoreEntryView: UIView!
	@IBOutlet weak var highScoreNameTextField: UITextField!
	@IBOutlet weak var howToPlayButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var logoTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var playButtonBottomConstraint: NSLayoutConstraint!
	
	var highScoreEntries = [UIView]()
	var invertedHighScoreEntries = [UIView]()
	var mostRecentHighScore = 0
	var highScoreAnimationFrame = 0
	var highScoreAnimationTimer: Timer?
	var newHighScore : Int?
	var tutorialPageViewController : TutorialPageViewController?

	// MARK: Lifecycle Methods

	override func viewDidLoad()
	{
		super.viewDidLoad()
		switch UIDevice.current.userInterfaceIdiom
			{
			case .phone:
				logoTopConstraint.constant = ConfigurationManager.iPhoneTopConstraintOffset
				playButtonBottomConstraint.constant = ConfigurationManager.iPhoneBottomConstraintOffset
			case .pad:
				logoTopConstraint.constant = ConfigurationManager.iPadTopConstraintOffset
				playButtonBottomConstraint.constant = ConfigurationManager.iPadBottomConstraintOffset
			default:
				logoTopConstraint.constant = ConfigurationManager.iPhoneTopConstraintOffset
				playButtonBottomConstraint.constant = ConfigurationManager.iPhoneBottomConstraintOffset
			}
		SpriteManager.sharedManager.loadSprites()
		GameboardManager.sharedManager.loadGameboards()
		GameStateManager.sharedManager.arrangeAnimations()
	}

	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		if newHighScore == nil
			{
			SoundManager.sharedManager.playTheme()
			displayHighScores()
			startHighScoreAnimation()
			}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}

	// MARK: Game Logic

	@IBAction func play(_ sender: UIButton)
	{
		let appDelegate = UIApplication.shared.delegate as! GoldBlockerAppDelegate
		if !appDelegate.viewsConstructed
			{
			appDelegate.constructViews()
			}
		stopHighScoreAnimation()
		GameStateManager.sharedManager.setCurrentLevel(startLevel: ConfigurationManager.sharedManager.getStartLevel())
		Analytics.logEvent("StartGame", parameters: [AnalyticsParameterLevel: GameStateManager.sharedManager.getCurrentLevel()])
		present(appDelegate.getGameScreenViewController(), animated: true, completion: nil)
	}

	@IBAction func showTutorial(_ sender: UIButton)
	{
		if tutorialPageViewController == nil
			{
			let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
			tutorialPageViewController = mainStoryboard.instantiateViewController(withIdentifier: "TutorialPageViewController") as! TutorialPageViewController
			}
		stopHighScoreAnimation()
		Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: nil)
		tutorialPageViewController?.modalPresentationStyle = .fullScreen
		present(tutorialPageViewController!, animated: true, completion: nil)
	}

	@IBAction func showSettings(_ sender: UIButton)
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let settingsViewController = mainStoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
		stopHighScoreAnimation()
		Analytics.logEvent("ViewSettings", parameters: nil)
		settingsViewController.modalPresentationStyle = .fullScreen
		present(settingsViewController, animated: true, completion: nil)
	}

	@IBAction func cancelHighScoreEntry(_ sender: UIButton)
	{
		newHighScore = nil
		highScoreEntryView.isHidden = true
		highScoreNameTextField.text = ""
		highScoreNameTextField.resignFirstResponder()
		howToPlayButton.isEnabled = true
		settingsButton.isEnabled = true
		playButton.isEnabled = true
		displayHighScores()
		startHighScoreAnimation()
		Analytics.logEvent("CancelHighScoreEntry", parameters: nil)
	}

	@IBAction func acceptHighScoreEntry(_ sender: UIButton)
	{
		let highScoresEntry = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemHighScores, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [Dictionary<String, Any>])
		var highScores = highScoresEntry.value
		var index = 0
		for highScore in highScores
			{
			let highScoreValue = highScore[ConfigurationManager.highScoreEntryFieldScore] as! NSNumber
			if newHighScore! > highScoreValue.intValue
				{
				var highScoreEntry = [String: Any]()
				highScoreEntry[ConfigurationManager.highScoreEntryFieldScore] = newHighScore
				highScoreEntry[ConfigurationManager.highScoreEntryFieldName] = highScoreNameTextField.text
				highScores.insert(highScoreEntry, at: index)
				highScores.removeLast()
				mostRecentHighScore = index
				PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemHighScores, value: highScores, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
				break
				}
			index += 1
			}
		highScoreEntryView.isHidden = true
		highScoreNameTextField.text = ""
		highScoreNameTextField.resignFirstResponder()
		newHighScore = nil
		howToPlayButton.isEnabled = true
		settingsButton.isEnabled = true
		playButton.isEnabled = true
		displayHighScores()
		startHighScoreAnimation()
		Analytics.logEvent("AcceptHighScoreEntry", parameters: [AnalyticsParameterItemName: highScoreNameTextField.text])
	}

	func displayHighScores()
	{
		// Set up blank high scores first time through
		if !PersistenceManager.sharedManager.checkForValue(name: ConfigurationManager.persistenceItemHighScores, from: .UserDefaults)
			{
			// Pre-populate with blank entries
			var highScores = [Dictionary<String, Any>]()
			for _ in 0..<ConfigurationManager.numberHighScoresDisplayed
				{
				var highScoreEntry = [String: Any]()
				highScoreEntry[ConfigurationManager.highScoreEntryFieldScore] = 0
				highScoreEntry[ConfigurationManager.highScoreEntryFieldName] = ""
				highScores.append(highScoreEntry)
				}
			PersistenceManager.sharedManager.saveValue(name: ConfigurationManager.persistenceItemHighScores, value: highScores, type: .Array, destination: .UserDefaults, protection: .Unsecured, lifespan: .Immortal, expiration: nil, overwrite: true)
			}
		let highScores = PersistenceManager.sharedManager.readValue(name: ConfigurationManager.persistenceItemHighScores, from: .UserDefaults) as! (result: PersistenceManager.PersistenceReadResultCode, value: [Dictionary<String, Any>])
		for nextEntry in highScoreEntries
			{
			nextEntry.removeFromSuperview()
			}
		highScoreEntries.removeAll()
		for nextEntry in invertedHighScoreEntries
			{
			nextEntry.removeFromSuperview()
			}
		invertedHighScoreEntries.removeAll()
		var entryIndex = 0
		for subview in highScoreListView.subviews
			{
			subview.removeFromSuperview()
			}
		for nextHighScore in highScores.value
			{
			let score = nextHighScore[ConfigurationManager.highScoreEntryFieldScore] as! NSNumber
			let name = nextHighScore[ConfigurationManager.highScoreEntryFieldName] as! String
			let entryFrame = CGRect(x: 0.0, y: CGFloat(entryIndex) * ConfigurationManager.highScoreEntryHeight, width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight)
			let rankFrame = CGRect(x: 0.0, y: (ConfigurationManager.highScoreEntryHeight - ConfigurationManager.highScoreFontHeight) / 2, width: ConfigurationManager.highScoreRankFieldWidth, height: ConfigurationManager.highScoreFontHeight)
			let scoreFrame = CGRect(x: ConfigurationManager.highScoreRankFieldWidth + ConfigurationManager.highScoreFieldBufferWidth, y: (ConfigurationManager.highScoreEntryHeight - ConfigurationManager.highScoreFontHeight) / 2, width: ConfigurationManager.highScoreScoreFieldWidth, height: ConfigurationManager.highScoreFontHeight)
			let nameFrame = CGRect(x: ConfigurationManager.highScoreRankFieldWidth + ConfigurationManager.highScoreScoreFieldWidth + (ConfigurationManager.highScoreFieldBufferWidth * 2), y: (ConfigurationManager.highScoreEntryHeight - ConfigurationManager.highScoreFontHeight) / 2, width: ConfigurationManager.highScoreNameFieldWidth, height: ConfigurationManager.highScoreFontHeight)
			// First set up normal view
			let entryView = UIView(frame: entryFrame)
			let rankLabel = UILabel(frame: rankFrame)
			let scoreLabel = UILabel(frame: scoreFrame)
			let nameLabel = UILabel(frame: nameFrame)
			rankLabel.backgroundColor = UIColor.clear
			rankLabel.textColor = UIColor.black
			rankLabel.text = "\(entryIndex + 1)"
			rankLabel.textAlignment = .left
			rankLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			scoreLabel.backgroundColor = UIColor.clear
			scoreLabel.textColor = UIColor.black
			scoreLabel.text = "\(score)"
			scoreLabel.textAlignment = .left
			scoreLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			nameLabel.backgroundColor = UIColor.clear
			nameLabel.textColor = UIColor.black
			nameLabel.text = name
			nameLabel.textAlignment = .left
			nameLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			entryView.backgroundColor = UIColor.clear
			entryView.addSubview(rankLabel)
			entryView.addSubview(scoreLabel)
			entryView.addSubview(nameLabel)
			highScoreListView.addSubview(entryView)
			highScoreEntries.append(entryView)
			// Then set up inverted view
			let invertedEntryView = UIView(frame: entryFrame)
			let invertedRankLabel = UILabel(frame: rankFrame)
			let invertedScoreLabel = UILabel(frame: scoreFrame)
			let invertedNameLabel = UILabel(frame: nameFrame)
			invertedRankLabel.backgroundColor = UIColor.clear
			invertedRankLabel.textColor = UIColor.black
			invertedRankLabel.text = "\(entryIndex + 1)"
			invertedRankLabel.textAlignment = .left
			invertedRankLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			invertedScoreLabel.backgroundColor = UIColor.clear
			invertedScoreLabel.textColor = UIColor.black
			invertedScoreLabel.text = "\(score)"
			invertedScoreLabel.textAlignment = .left
			invertedScoreLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			invertedNameLabel.backgroundColor = UIColor.clear
			invertedNameLabel.textColor = UIColor.black
			invertedNameLabel.text = name
			invertedNameLabel.textAlignment = .left
			invertedNameLabel.font = UIFont.systemFont(ofSize: ConfigurationManager.highScoreFontHeight)
			invertedEntryView.backgroundColor = UIColor.clear
			invertedEntryView.addSubview(invertedRankLabel)
			invertedEntryView.addSubview(invertedScoreLabel)
			invertedEntryView.addSubview(invertedNameLabel)
			invertedHighScoreEntries.append(invertedEntryView)
			entryIndex += 1
			}
	}

	func startHighScoreAnimation()
	{
		let selectedHSEntry = highScoreEntries[mostRecentHighScore]
		let selectedInvertedHSEntry = invertedHighScoreEntries[mostRecentHighScore]
		selectedHSEntry.backgroundColor = UIColor.white
		selectedInvertedHSEntry.backgroundColor = UIColor.blue
		highScoreListView.addSubview(selectedInvertedHSEntry)
		highScoreAnimationTimer = Timer.scheduledTimer(withTimeInterval: ConfigurationManager.gameUpdateLoopTimerDelay, repeats: true, block: {(timer) in self.updateHSAnimation()})
	}

	func stopHighScoreAnimation()
	{
		let selectedHSEntry = highScoreEntries[mostRecentHighScore]
		let selectedInvertedHSEntry = invertedHighScoreEntries[mostRecentHighScore]
		selectedHSEntry.backgroundColor = UIColor.clear
		selectedInvertedHSEntry.backgroundColor = UIColor.clear
		if highScoreAnimationTimer != nil
			{
			highScoreAnimationTimer!.invalidate()
			}
		highScoreAnimationTimer = nil
	}

	func updateHSAnimation()
	{
		let selectedNormalEntry = highScoreEntries[mostRecentHighScore]
		let selectedInvertedEntry = invertedHighScoreEntries[mostRecentHighScore]
		// Figure out which animation frame to display next
		if highScoreAnimationFrame < (Int(ConfigurationManager.highScoreEntryHeight) * 2) - 1
			{
			highScoreAnimationFrame += 1
			}
		else
			{
			highScoreAnimationFrame = 0
			}
		// Swap the foreground view when necessary
		if highScoreAnimationFrame == 1
			{
			highScoreListView.bringSubview(toFront: selectedNormalEntry)
			selectedInvertedEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight)
			}
		else if highScoreAnimationFrame == (Int(ConfigurationManager.highScoreEntryHeight) + 1)
			{
			selectedNormalEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight)
			highScoreListView.bringSubview(toFront: selectedInvertedEntry)
			}
		// Now piece together the 2 views that will simulate the animation
		if highScoreAnimationFrame == 0															// The original, unhighlighted image
			{
			selectedNormalEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight)
			}
		else if highScoreAnimationFrame == Int(ConfigurationManager.highScoreEntryHeight)		// The full inverted view
			{
			selectedInvertedEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight)
			}
		else if highScoreAnimationFrame < Int(ConfigurationManager.highScoreEntryHeight)		// Inverted image gets placed first
			{
			selectedNormalEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight - CGFloat(highScoreAnimationFrame))
			}
		else																					// Original image gets placed first
			{
			selectedInvertedEntry.frame = CGRect(x: 0.0, y: ConfigurationManager.highScoreEntryHeight * CGFloat(mostRecentHighScore), width: ConfigurationManager.highScoreEntryWidth, height: ConfigurationManager.highScoreEntryHeight - (CGFloat(highScoreAnimationFrame) - ConfigurationManager.highScoreEntryHeight))
			}
	}

	func end()
	{
		dismiss(animated: true, completion: nil)
	}

	func promptNewHighScore(score: Int)
	{
		SoundManager.sharedManager.playHighScore()
		newHighScore = score
		self.highScoreEntryView.isHidden = false
		highScoreNameTextField.becomeFirstResponder()
		howToPlayButton.isEnabled = false
		settingsButton.isEnabled = false
		playButton.isEnabled = false
		Analytics.logEvent("PromptHighScoreEntry", parameters: [AnalyticsParameterScore: score])
	}
}

