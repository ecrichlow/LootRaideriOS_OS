/*******************************************************************************
* TutorialSentriesViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's tutorial sentries section
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/20/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

class TutorialSentriesViewController: UIViewController
{

	@IBOutlet weak var sentryImageView: UIImageView!

	private var spriteAnimationTimer : Timer!
	private var sentryFrame = ConfigurationManager.guardSpriteIndex

	var tutorialController : TutorialPageViewController!

	// MARK: Lifecycle Methods

	override func viewDidLoad()
    {
        super.viewDidLoad()
		let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Robot Right")
		sentryFrame = firstSprite.frame
    }

	override func viewWillAppear(_ animated: Bool)
	{
		spriteAnimationTimer = Timer(timeInterval: ConfigurationManager.spriteAnimationLoopTimerDelay, repeats: true, block: {_ in DispatchQueue.main.async(execute: { () -> Void in self.animateSprites()})})
		RunLoop.main.add(spriteAnimationTimer, forMode: RunLoopMode.commonModes)
	}

	override func viewWillDisappear(_ animated: Bool)
	{
		spriteAnimationTimer.invalidate()
		spriteAnimationTimer = nil
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

	// MARK: Business Logic

	private func animateSprites()
	{
		let nextSprite = SpriteManager.sharedManager.imageForNextFrameOfAnimationNamed(name: "Robot Right", currentFrame: sentryFrame)
		sentryImageView.image = nil
		sentryImageView.image = nextSprite.image
		sentryFrame = nextSprite.frame
	}
}
