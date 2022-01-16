/*******************************************************************************
* TutorialPlatformsTeleportersViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's tutorial platforms and teleporters section
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/20/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

class TutorialPlatformsTeleportersViewController: UIViewController
{

	@IBOutlet weak var teleporterImageViewOne: UIImageView!
	@IBOutlet weak var teleporterImageViewTwo: UIImageView!
	@IBOutlet weak var teleporterImageViewThree: UIImageView!

	private var spriteAnimationTimer : Timer!
	private var bidirectionalTeleporterFrame = ConfigurationManager.teleporterSpriteIndex
	private var sendingTeleporterFrame = ConfigurationManager.teleporterSpriteIndex
	private var receivingTeleporterFrame = ConfigurationManager.teleporterSpriteIndex
	private var pulseOut = true

	var tutorialController : TutorialPageViewController!

	// MARK: Lifecycle Methods

	override func viewDidLoad()
    {
        super.viewDidLoad()
		let firstSprite = SpriteManager.sharedManager.imageForFirstFrameOfAnimationNamed(name: "Teleporter")
		let lastSprite = SpriteManager.sharedManager.imageForLastFrameOfAnimationNamed(name: "Teleporter")
		bidirectionalTeleporterFrame = firstSprite.frame
		sendingTeleporterFrame = lastSprite.frame
		receivingTeleporterFrame = firstSprite.frame
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
		// Roundtrippable
		if pulseOut
			{
			if bidirectionalTeleporterFrame < Teleporter.endFrame
				{
				bidirectionalTeleporterFrame += 1
				}
			else
				{
				bidirectionalTeleporterFrame -= 1
				pulseOut = false
				}
			let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: bidirectionalTeleporterFrame)
			teleporterImageViewOne.image = image
			}
		else
			{
			if bidirectionalTeleporterFrame > Teleporter.startFrame
				{
				bidirectionalTeleporterFrame -= 1
				}
			else
				{
				bidirectionalTeleporterFrame += 1
				pulseOut = true
				}
			let image = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: bidirectionalTeleporterFrame)
			teleporterImageViewOne.image = image
			}
		// Sendable
		if sendingTeleporterFrame == Teleporter.startFrame
			{
			sendingTeleporterFrame = Teleporter.endFrame
			}
		else
			{
			sendingTeleporterFrame -= 1
			}
		let sendableImage = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: sendingTeleporterFrame)
		teleporterImageViewTwo.image = sendableImage
		// Receivable
		if receivingTeleporterFrame < Teleporter.endFrame
			{
			receivingTeleporterFrame += 1
			}
		else
			{
			receivingTeleporterFrame = Teleporter.startFrame
			}
		let receivableImage = SpriteManager.sharedManager.imageForSpriteNumber(spriteNumber: receivingTeleporterFrame)
		teleporterImageViewThree.image = receivableImage
	}
}
