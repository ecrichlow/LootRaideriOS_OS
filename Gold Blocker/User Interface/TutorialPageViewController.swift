/*******************************************************************************
* TutorialPageViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's tutorial page view controller
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/20/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import FirebaseAnalytics

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource
{

	var tutorialIntroController : TutorialIntroViewController?
	var tutorialSentriesController : TutorialSentriesViewController?
	var tutorialPlatformsTeleportersController : TutorialPlatformsTeleportersViewController?
	var tutorialStasisFieldsController : TutorialStasisFieldsViewController?
	var tutorialControlsController : TutorialControlsViewController?
	var selectedPageIndex = 0
	var tutorialViewControllers = [UIViewController]()

	// MARK: Lifecycle Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

	override func viewWillAppear(_ animated: Bool)
	{
		if tutorialIntroController == nil
			{
			let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
			tutorialIntroController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialIntro") as! TutorialIntroViewController)
			tutorialIntroController!.tutorialController = self
			tutorialViewControllers.append(tutorialIntroController!)
			let pageControl = UIPageControl.appearance()
			pageControl.pageIndicatorTintColor = UIColor.gray
			pageControl.currentPageIndicatorTintColor = UIColor.white
			pageControl.backgroundColor = UIColor.clear
			}
		setViewControllers([tutorialIntroController!], direction: .forward, animated: true, completion: nil)
	}

	// MARK: Business Logic

	func advanceTutorial()
	{
		Analytics.logEvent("AdvanceTutorial", parameters: [AnalyticsParameterValue : selectedPageIndex])
		if tutorialViewControllers.count < selectedPageIndex + 2
			{
			let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
			switch selectedPageIndex
				{
				case 0:
					tutorialSentriesController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialSentries") as! TutorialSentriesViewController)
					tutorialSentriesController!.tutorialController = self
					tutorialViewControllers.append(tutorialSentriesController!)
				case 1:
					tutorialPlatformsTeleportersController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialPlatformsTeleporters") as! TutorialPlatformsTeleportersViewController)
					tutorialPlatformsTeleportersController!.tutorialController = self
					tutorialViewControllers.append(tutorialPlatformsTeleportersController!)
				case 2:
					tutorialStasisFieldsController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialStasisFields") as! TutorialStasisFieldsViewController)
					tutorialStasisFieldsController!.tutorialController = self
					tutorialViewControllers.append(tutorialStasisFieldsController!)
				case 3:
					tutorialControlsController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialControls") as! TutorialControlsViewController)
					tutorialControlsController!.tutorialController = self
					tutorialViewControllers.append(tutorialControlsController!)
				default:
					break
				}
			}
		selectedPageIndex += 1
		setViewControllers([tutorialViewControllers[selectedPageIndex]], direction: .forward, animated: true, completion: nil)
	}

	func regressTutorial()
	{
		Analytics.logEvent("RegressTutorial", parameters: [AnalyticsParameterValue : selectedPageIndex])
		selectedPageIndex -= 1
		setViewControllers([tutorialViewControllers[selectedPageIndex]], direction: .reverse, animated: true, completion: nil)
	}

	func endTutorial()
	{
		Analytics.logEvent("EndTutorial", parameters: nil)
		selectedPageIndex = 0
		DispatchQueue.main.async
			{
			// TODO: This transition should be animated, but iOS 13 broke that
			self.dismiss(animated: false, completion: nil)
			}
	}

	// MARK: UIPageViewController DataSource methods

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
	{
		if viewController == tutorialControlsController
			{
			if tutorialStasisFieldsController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialStasisFieldsController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialStasisFields") as! TutorialStasisFieldsViewController)
				tutorialStasisFieldsController!.tutorialController = self
				tutorialViewControllers.append(tutorialStasisFieldsController!)
				}
			return tutorialStasisFieldsController
			}
		else if viewController == tutorialStasisFieldsController
			{
			if tutorialPlatformsTeleportersController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialPlatformsTeleportersController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialPlatformsTeleporters") as! TutorialPlatformsTeleportersViewController)
				tutorialPlatformsTeleportersController!.tutorialController = self
				tutorialViewControllers.append(tutorialPlatformsTeleportersController!)
				}
			return tutorialPlatformsTeleportersController
			}
		else if viewController == tutorialPlatformsTeleportersController
			{
			if tutorialSentriesController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialSentriesController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialSentries") as! TutorialSentriesViewController)
				tutorialSentriesController!.tutorialController = self
				tutorialViewControllers.append(tutorialSentriesController!)
				}
			return tutorialSentriesController
			}
		else if viewController == tutorialSentriesController
			{
			if tutorialIntroController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialIntroController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialIntro") as! TutorialIntroViewController)
				tutorialIntroController!.tutorialController = self
				tutorialViewControllers.append(tutorialIntroController!)
				}
			return tutorialIntroController
			}
		else if viewController == tutorialIntroController
			{
			return nil
			}
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
	{
		if viewController == tutorialIntroController
			{
			if tutorialSentriesController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialSentriesController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialSentries") as! TutorialSentriesViewController)
				tutorialSentriesController!.tutorialController = self
				tutorialViewControllers.append(tutorialSentriesController!)
				}
			return tutorialSentriesController
			}
		else if viewController == tutorialSentriesController
			{
			if tutorialPlatformsTeleportersController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialPlatformsTeleportersController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialPlatformsTeleporters") as! TutorialPlatformsTeleportersViewController)
				tutorialPlatformsTeleportersController!.tutorialController = self
				tutorialViewControllers.append(tutorialPlatformsTeleportersController!)
				}
			return tutorialPlatformsTeleportersController
			}
		else if viewController == tutorialPlatformsTeleportersController
			{
			if tutorialStasisFieldsController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialStasisFieldsController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialStasisFields") as! TutorialStasisFieldsViewController)
				tutorialStasisFieldsController!.tutorialController = self
				tutorialViewControllers.append(tutorialStasisFieldsController!)
				}
			return tutorialStasisFieldsController
			}
		else if viewController == tutorialStasisFieldsController
			{
			if tutorialControlsController == nil
				{
				let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
				tutorialControlsController = (mainStoryboard.instantiateViewController(withIdentifier: "TutorialControls") as! TutorialControlsViewController)
				tutorialControlsController!.tutorialController = self
				tutorialViewControllers.append(tutorialControlsController!)
				}
			return tutorialControlsController
			}
		else if viewController == tutorialControlsController
			{
			return nil
			}
		return nil
	}

	func presentationCount(for: UIPageViewController) -> Int
	{
		return ConfigurationManager.numberTutorialSegments
	}

	func presentationIndex(for: UIPageViewController) -> Int
	{
		return selectedPageIndex
	}

	// MARK: UIPageViewController Delegate methods

	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
	{
		let newViewController = pendingViewControllers.first
		if newViewController == tutorialIntroController
			{
			selectedPageIndex = 0
			}
		else if newViewController == tutorialSentriesController
			{
			selectedPageIndex = 1
			}
		else if newViewController == tutorialPlatformsTeleportersController
			{
			selectedPageIndex = 2
			}
		else if newViewController == tutorialStasisFieldsController
			{
			selectedPageIndex = 3
			}
		else if newViewController == tutorialControlsController
			{
			selectedPageIndex = 4
			}
	}

}
