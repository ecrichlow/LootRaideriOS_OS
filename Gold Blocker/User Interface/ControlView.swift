/*******************************************************************************
* ControlView.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the implementation for the custom
*						input controller view
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	05/05/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

protocol ControlDelegate
{
	func directionTapped(direction : ControlView.ControllerDirection)
	func directionUpdated(direction : ControlView.ControllerDirection)
	func directionSwiped(direction : ControlView.ControllerDirection)
	func controlReleased()
}

class ControlView: UIView
{
	enum ControlType : Int
	{
		case Tap
		case Propel
		case Flick
	}

	enum ControlSet
	{
		case BothAxes
		case Horizontal
		case Vertical
	}

	enum ControllerDirection
	{
		case Center
		case Up
		case UpRight
		case Right
		case DownRight
		case Down
		case DownLeft
		case Left
		case UpLeft
	}

	var delegate : ControlDelegate?

	private var controlType = ConfigurationManager.sharedManager.getControlType()
	private var controlSet : ControlSet?
	private var touchStartPosition : CGPoint?

	// MARK: Lifecycle Methods

	override init(frame: CGRect)
	{
		super.init(frame: frame)
		self.alpha = 1.0
		self.backgroundColor = UIColor.clear
		self.isMultipleTouchEnabled = true
	}
	
	required init(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)!
		self.alpha = 1.0
		self.backgroundColor = UIColor.clear
		self.isMultipleTouchEnabled = true
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		for nextTouch in touches
			{
			touchStartPosition = nextTouch.location(in: self)
			if controlType == ControlType.Tap
				{
				if controlSet == ControlSet.BothAxes
					{
					let direction = getControlDirectionFor(touchPoint: touchStartPosition!)
					delegate?.directionTapped(direction: direction)
					}
				else if controlSet == ControlSet.Horizontal
					{
					let direction = getHorizontalControlDirectionFor(touchPoint: touchStartPosition!)
					delegate?.directionTapped(direction: direction)
					}
				else if controlSet == ControlSet.Vertical
					{
					let direction = getVerticalControlDirectionFor(touchPoint: touchStartPosition!)
					delegate?.directionTapped(direction: direction)
					}
				}
			}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if let touch = touches.first
			{
			let touchEndPosition = touch.location(in: self)
			if controlType == ControlType.Tap
				{
				if controlSet == ControlSet.BothAxes
					{
					let direction = getControlDirectionFor(touchPoint: touchEndPosition)
					delegate?.directionUpdated(direction: direction)
					}
				else if controlSet == ControlSet.Horizontal
					{
					let direction = getHorizontalControlDirectionFor(touchPoint: touchStartPosition!)
					delegate?.directionTapped(direction: direction)
					}
				else if controlSet == ControlSet.Vertical
					{
					let direction = getVerticalControlDirectionFor(touchPoint: touchStartPosition!)
					delegate?.directionTapped(direction: direction)
					}
				}
			}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		if touches.first != nil
			{
			if controlType == ControlType.Tap
				{
				delegate?.controlReleased()
				}
			}
	}

	// MARK: Business Logic

	func setControlType(type: ControlType)
	{
		controlType = type
	}

	func setControlSet(set: ControlSet)
	{
		controlSet = set
	}

	private func getControlDirectionFor(touchPoint : CGPoint) -> ControllerDirection
	{
		let centerPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
		let normalizedX = touchPoint.x - centerPoint.x
		let normalizedY = centerPoint.y - touchPoint.y
		let distanceFromCenter = sqrt((abs(normalizedX) * abs(normalizedX)) + (abs(normalizedY) * abs(normalizedY)))
		var aboveLine1 = false
		var aboveLine2 = false
		var nearUpperRight = false
		var nearUpperLeft = false
		var nearLowerLeft = false
		var nearLowerRight = false
		var deadRadius = (self.frame.size.width * CGFloat(ConfigurationManager.defaultControllerCenterDeadRadius)) / CGFloat(ConfigurationManager.defaultControllerSideLength)
		if distanceFromCenter < deadRadius
			{
			return .Center
			}
		else if touchPoint.x >= centerPoint.x && touchPoint.y <= centerPoint.y
			{
			aboveLine1 = true
			if normalizedX <= normalizedY
				{
				aboveLine2 = true
				if Int(((normalizedY - normalizedX) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearUpperRight = true
					}
				}
			else
				{
				if Int(((normalizedX - normalizedY) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearUpperRight = true
					}
				}
			}
		else if touchPoint.x <= centerPoint.x && touchPoint.y <= centerPoint.y
			{
			aboveLine2 = true
			if abs(normalizedX) < normalizedY
				{
				aboveLine1 = true
				if Int(((normalizedY - abs(normalizedX)) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearUpperLeft = true
					}
				}
			else
				{
				if Int(((abs(normalizedX) - normalizedY) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearUpperLeft = true
					}
				}
			}
		else if touchPoint.x <= centerPoint.x && touchPoint.y >= centerPoint.y
			{
			aboveLine1 = false
			if normalizedX < normalizedY
				{
				aboveLine2 = true
				if Int(((abs(normalizedX) - abs(normalizedY)) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearLowerLeft = true
					}
				}
			else
				{
				if Int(((abs(normalizedY) - abs(normalizedX)) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearLowerLeft = true
					}
				}
			}
		else if touchPoint.x >= centerPoint.x && touchPoint.y >= centerPoint.y
			{
			aboveLine2 = false
			if normalizedX > abs(normalizedY)
				{
				aboveLine1 = true
				if Int(((normalizedX - abs(normalizedY)) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearLowerRight = true
					}
				}
			else
				{
				if Int(((abs(normalizedY) - normalizedX) / self.frame.size.width) * 100) < ConfigurationManager.defaultMultiControlButtonProximityPercent
					{
					nearLowerRight = true
					}
				}
			}
		if nearUpperLeft
			{
			return .UpLeft
			}
		else if nearUpperRight
			{
			return .UpRight
			}
		else if nearLowerLeft
			{
			return .DownLeft
			}
		else if nearLowerRight
			{
			return .DownRight
			}
		else if aboveLine1 && aboveLine2
			{
			return .Up
			}
		else if !aboveLine2 && aboveLine1
			{
			return .Right
			}
		else if !aboveLine2 && !aboveLine2
			{
			return .Down
			}
		else if !aboveLine1 && aboveLine2
			{
			return .Left
			}
		return .Up
	}

	private func getHorizontalControlDirectionFor(touchPoint : CGPoint) -> ControllerDirection
	{
		let centerPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
		if touchPoint.x <= centerPoint.x
			{
			return .Left
			}
		else
			{
			return .Right
			}
	}

	private func getVerticalControlDirectionFor(touchPoint : CGPoint) -> ControllerDirection
	{
		let centerPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
		if touchPoint.y <= centerPoint.y
			{
			return .Up
			}
		else
			{
			return .Down
			}
	}
}
