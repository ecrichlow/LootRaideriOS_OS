/*******************************************************************************
* TutorialStasisFieldsViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's tutorial stasis fields section
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/20/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

class TutorialStasisFieldsViewController: UIViewController
{

	var tutorialController : TutorialPageViewController!

	// MARK: Lifecycle Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func regressInTutorial(_ sender: UIButton)
	{
		tutorialController.regressTutorial()
	}

	@IBAction func progressInTutorial(_ sender: UIButton)
	{
		tutorialController.advanceTutorial()
	}
}
