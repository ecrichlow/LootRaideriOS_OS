/*******************************************************************************
* SettingsViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Settings screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/22/18		*	EGC	*	File creation date
*	04/23/20		*	EGC	*	Adding game controller support
*     04/23/20             *       EGC *       Adding Easy Mode
********************************************************************************
*/

import UIKit
import FirebaseAnalytics
import GameController

class SettingsViewController: UIViewController
{

	@IBOutlet weak var playSoundsSwitch: UISwitch!
	@IBOutlet weak var playIntroAnimationsSwitch: UISwitch!
	@IBOutlet weak var skipPlayedLevelsIntroSwitch: UISwitch!
    @IBOutlet weak var easyModeSwitch: UISwitch!
	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var gameControllerLabel: UILabel!
	
	// MARK: Lifecycle Methods

	override func viewDidLoad()
    {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool)
	{
		let infoDictionary = Bundle.main.infoDictionary
		let majorVersion = infoDictionary!["CFBundleShortVersionString"] as! String
		let minorVersion = infoDictionary!["CFBundleVersion"] as! String
		let gameControllers = GCController.controllers()
		versionLabel.text = "Version: " + majorVersion + "." + minorVersion
		playSoundsSwitch.setOn(ConfigurationManager.sharedManager.getPlaySounds(), animated: false)
		playIntroAnimationsSwitch.setOn(ConfigurationManager.sharedManager.getPlayIntros(), animated: false)
		skipPlayedLevelsIntroSwitch.setOn(ConfigurationManager.sharedManager.getSkipPlayedLevelIntros(), animated: false)
        easyModeSwitch.setOn(ConfigurationManager.sharedManager.getEasyMode(), animated: false)
		if gameControllers.count > 0
			{
			let attributedString = NSAttributedString.init(string: "Game Controller Detected", attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue])
			gameControllerLabel.attributedText = attributedString
			}
		else
			{
			let attributedString = NSAttributedString.init(string: "No Game Controller Detected", attributes: [NSAttributedStringKey.foregroundColor: UIColor.red])
			gameControllerLabel.attributedText = attributedString
			}
	}

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
	@IBAction func setPlaySounds(_ sender: UISwitch)
	{
		ConfigurationManager.sharedManager.setPlaySounds(newValue: sender.isOn)
		Analytics.logEvent("SetPlaySounds", parameters: [AnalyticsParameterValue: sender.isOn])
	}

	@IBAction func setPlayIntroAnimations(_ sender: UISwitch)
	{
		ConfigurationManager.sharedManager.setPlayIntros(newValue: sender.isOn)
		Analytics.logEvent("SetPlayIntros", parameters: [AnalyticsParameterValue: sender.isOn])
	}

	@IBAction func skipPlayedIntroAnimations(_ sender: UISwitch)
	{
		ConfigurationManager.sharedManager.setSkipPlayedLevelIntros(newValue: sender.isOn)
		Analytics.logEvent("SetSkipPlayedIntroAnimations", parameters: [AnalyticsParameterValue: sender.isOn])
	}

	@IBAction func setControlScheme(_ sender: UIButton)
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controlSchemeController = (mainStoryboard.instantiateViewController(withIdentifier: "ControlScheme") as! ControlSchemeViewController)
		controlSchemeController.modalPresentationStyle = .fullScreen
		present(controlSchemeController, animated: true, completion: nil)
	}

    @IBAction func setEasyMode(_ sender: UISwitch)
    {
        ConfigurationManager.sharedManager.setEasyMode(newValue: sender.isOn)
        Analytics.logEvent("SetEasyMode", parameters: [AnalyticsParameterValue: sender.isOn])
    }

	@IBAction func setStartingLevel(_ sender: UIButton)
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let startingLevelController = (mainStoryboard.instantiateViewController(withIdentifier: "StartingLevel") as! StartingLevelViewController)
		startingLevelController.modalPresentationStyle = .fullScreen
		present(startingLevelController, animated: true, completion: nil)
	}

	@IBAction func getExtras(_ sender: UIButton)
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let extrasController = (mainStoryboard.instantiateViewController(withIdentifier: "GetExtras") as! ExtrasViewController)
		extrasController.modalPresentationStyle = .fullScreen
		present(extrasController, animated: true, completion: nil)
	}

	@IBAction func contact(_ sender: UIButton)
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let contactController = (mainStoryboard.instantiateViewController(withIdentifier: "ContactUs") as! ContactViewController)
		contactController.modalPresentationStyle = .fullScreen
		present(contactController, animated: true, completion: nil)
	}

	@IBAction func exit(_ sender: UIButton)
	{
		dismiss(animated: true, completion: nil)
	}
}
