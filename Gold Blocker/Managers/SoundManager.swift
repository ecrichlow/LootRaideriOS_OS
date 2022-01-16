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
*	07/27/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import AVFoundation

class SoundManager
{

	var themeAudioPlayer : AVAudioPlayer?
	var playerGetGoldAudioPlayer : AVAudioPlayer?
	var sentryGetGoldAudioPlayer : AVAudioPlayer?
	var raiseStasisFieldAudioPlayer : AVAudioPlayer?
	var lowerStasisFieldAudioPlayer : AVAudioPlayer?
	var teleporterAudioPlayer : AVAudioPlayer?
	var playerCaughtAudioPlayer : AVAudioPlayer?
	var escapeLadderAudioPlayer : AVAudioPlayer?
	var winLevelAudioPlayer : AVAudioPlayer?
	var highScoreAudioPlayer : AVAudioPlayer?
	var extraLifeAudioPlayer : AVAudioPlayer?

	static let sharedManager = SoundManager()

	func playTheme()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if themeAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultIntroFilename)!.data
				try themeAudioPlayer = AVAudioPlayer(data: audioData)
				themeAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		themeAudioPlayer!.play()
	}

	func playPlayerGetGold()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if playerGetGoldAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultPlayerGetGoldFilename)!.data
				try playerGetGoldAudioPlayer = AVAudioPlayer(data: audioData)
				playerGetGoldAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		playerGetGoldAudioPlayer!.play()
	}

	func playSentryGetGold()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if sentryGetGoldAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultSentryGetGoldFilename)!.data
				try sentryGetGoldAudioPlayer = AVAudioPlayer(data: audioData)
				sentryGetGoldAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		sentryGetGoldAudioPlayer!.play()
	}

	func playRaiseStasisField()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if raiseStasisFieldAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultRaiseStasisFieldFilename)!.data
				try raiseStasisFieldAudioPlayer = AVAudioPlayer(data: audioData)
				raiseStasisFieldAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		raiseStasisFieldAudioPlayer!.play()
	}

	func playLowerStasisField()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if lowerStasisFieldAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultLowerStasisFieldFilename)!.data
				try lowerStasisFieldAudioPlayer = AVAudioPlayer(data: audioData)
				lowerStasisFieldAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		lowerStasisFieldAudioPlayer!.play()
	}

	func playTeleporter()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if teleporterAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultTeleporterFilename)!.data
				try teleporterAudioPlayer = AVAudioPlayer(data: audioData)
				teleporterAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		teleporterAudioPlayer!.play()
	}

	func playPlayerCaught()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if playerCaughtAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultPlayerCaughtFilename)!.data
				try playerCaughtAudioPlayer = AVAudioPlayer(data: audioData)
				playerCaughtAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		playerCaughtAudioPlayer!.play()
	}

	func playEscapeLadderRevealed()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if escapeLadderAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultEscapeLadderFilename)!.data
				try escapeLadderAudioPlayer = AVAudioPlayer(data: audioData)
				escapeLadderAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		escapeLadderAudioPlayer!.play()
	}

	func playWinLevel()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if winLevelAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultWinLevelFilename)!.data
				try winLevelAudioPlayer = AVAudioPlayer(data: audioData)
				winLevelAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		winLevelAudioPlayer!.play()
	}

	func playExtraLife()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		playerGetGoldAudioPlayer!.stop()
		if extraLifeAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultExtraLifeFilename)!.data
				try extraLifeAudioPlayer = AVAudioPlayer(data: audioData)
				extraLifeAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		extraLifeAudioPlayer!.play()
	}

	func playHighScore()
	{
		if !ConfigurationManager.sharedManager.getPlaySounds()
			{
			return
			}
		if highScoreAudioPlayer == nil
			{
			do
				{
				let audioData = NSDataAsset(name: ConfigurationManager.defaultHighScoreFilename)!.data
				try highScoreAudioPlayer = AVAudioPlayer(data: audioData)
				highScoreAudioPlayer!.prepareToPlay()
				}
			catch
				{
				}
			}
		highScoreAudioPlayer!.play()
	}

	func stopSoundsForPlayerDie()
	{
		playerGetGoldAudioPlayer!.stop()
		sentryGetGoldAudioPlayer!.stop()
		raiseStasisFieldAudioPlayer!.stop()
		lowerStasisFieldAudioPlayer!.stop()
		teleporterAudioPlayer!.stop()
		escapeLadderAudioPlayer!.stop()
	}

	func stopSoundsForLevelWin()
	{
		playerGetGoldAudioPlayer!.stop()
		sentryGetGoldAudioPlayer!.stop()
		raiseStasisFieldAudioPlayer!.stop()
		lowerStasisFieldAudioPlayer!.stop()
		teleporterAudioPlayer!.stop()
		escapeLadderAudioPlayer!.stop()
	}
}
