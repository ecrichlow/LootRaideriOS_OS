/*******************************************************************************
* GoldBlockerRunnerAppDelegate.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the application's delegated methods
*						and application-level utility methods
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/03/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import Firebase

@UIApplicationMain
class GoldBlockerAppDelegate: UIResponder, UIApplicationDelegate
{

	var window: UIWindow?
	var gameCenterViewController : GameCenterViewController?
	var gameScreenViewController : GameScreenViewController?
	var viewsConstructed = false
	var currentLayout : GameScreenViewController.GameScreenLayoutScheme?

	// MARK: Application Lifecycle Methods

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
	{
		// Set up analytics
		FirebaseApp.configure()
		switch UIDevice.current.userInterfaceIdiom
			{
			case .phone:
				Analytics.setUserProperty("iPhone", forName: "DeviceType")
			case .pad:
				Analytics.setUserProperty("iPad", forName: "DeviceType")
			default:
				Analytics.setUserProperty("unknown", forName: "DeviceType")
			}
		if ProcessInfo.processInfo.environment["DEV"] != nil
			{
			Analytics.setUserProperty("Dev", forName: "Environment")
			}
		else if ProcessInfo.processInfo.environment["BETA"] != nil
			{
			Analytics.setUserProperty("Beta", forName: "Environment")
			}
		else
			{
			Analytics.setUserProperty("Production", forName: "Environment")
			}
		// Have to prepare for Store transactions early in case Store immediately notifies us of unfinished downloads
		InAppPurchaseManager.sharedManager.prepareForTransactions()
		// Set up main screens
		if !viewsConstructed
			{
			constructViews()
			}
		return true
	}

	func applicationWillResignActive(_ application: UIApplication)
	{
	}

	func applicationDidEnterBackground(_ application: UIApplication)
	{
	}

	func applicationWillEnterForeground(_ application: UIApplication)
	{
	}

	func applicationDidBecomeActive(_ application: UIApplication)
	{
	}

	func applicationWillTerminate(_ application: UIApplication)
	{
	}

	// MARK: System-wide functionality

	func constructViews()
	{
		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		if let window = UIApplication.shared.keyWindow
			{
			self.window = window
			gameCenterViewController = (window.rootViewController as! GameCenterViewController)
			let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
			currentLayout = layoutScheme
			switch layoutScheme
				{
				case .Vertical:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenVertical") as! GameScreenViewController)
				case .Horizontal1:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal1") as! GameScreenViewController)
				case .Horizontal2:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal2") as! GameScreenViewController)
				case .Horizontal3:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal3") as! GameScreenViewController)
				case .Horizontal4:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal4") as! GameScreenViewController)
				case .Horizontal5:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal5") as! GameScreenViewController)
				}
			viewsConstructed = true
			gameCenterViewController?.modalPresentationStyle = .fullScreen
			gameScreenViewController?.modalPresentationStyle = .fullScreen
			}
	}

	func getGameScreenViewController() -> GameScreenViewController
	{
		let layoutScheme = ConfigurationManager.sharedManager.getLayoutType()
		if currentLayout != nil && layoutScheme == currentLayout
			{
			return gameScreenViewController!
			}
		else
			{
			let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
			currentLayout = layoutScheme
			switch layoutScheme
				{
				case .Vertical:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenVertical") as! GameScreenViewController)
				case .Horizontal1:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal1") as! GameScreenViewController)
				case .Horizontal2:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal2") as! GameScreenViewController)
				case .Horizontal3:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal3") as! GameScreenViewController)
				case .Horizontal4:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal4") as! GameScreenViewController)
				case .Horizontal5:
					gameScreenViewController = (mainStoryboard.instantiateViewController(withIdentifier: "GameScreenHorizontal5") as! GameScreenViewController)
				}
			return gameScreenViewController!
			}
	}

	func resetGameScreenViewController()
	{
		gameScreenViewController = nil
		constructViews()
	}
}

