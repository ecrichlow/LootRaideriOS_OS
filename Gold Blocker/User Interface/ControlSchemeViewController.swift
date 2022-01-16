/*******************************************************************************
* ControlSchemeViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Settings Control Scheme screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/23/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import FirebaseAnalytics

class ControlSchemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

	@IBOutlet weak var controlSchemeTableView: UITableView!
	
	// MARK: Lifecycle Methods

	override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
	@IBAction func cancel(_ sender: UIButton)
	{
		dismiss(animated: true, completion: nil)
	}

	// MARK: Tableview delegate methods
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
	{
		let row = indexPath.row
		if UIDevice.current.userInterfaceIdiom == .pad && (row == 3 || row == 4)
			{
            let alert = UIAlertController(title: "Choose Again", message: "This control scheme not supported on iPad", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            	}))
			self.present(alert, animated: true, completion: nil)
			return nil
			}
		else
			{
			return indexPath
			}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		let row = indexPath.row
		switch row
			{
			case 0:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Horizontal1)
			case 1:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Horizontal2)
			case 2:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Horizontal5)
			case 3:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Horizontal3)
			case 4:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Horizontal4)
			case 5:
				ConfigurationManager.sharedManager.setLayoutScheme(newScheme: .Vertical)
			default:
				break
			}
		Analytics.logEvent("SetControlScheme", parameters: [AnalyticsParameterValue: row])
		dismiss(animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return ConfigurationManager.defaultSettingsControlLayoutRowHeight
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
			return ConfigurationManager.defaultSettingsNumLayoutConfigurations
			}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
	
        let cell = tableView.dequeueReusableCell(withIdentifier: "ControlSchemeTableViewCell", for: indexPath) as! ControlSchemeTableViewCell

		let row = indexPath.row
		let controlScheme = ConfigurationManager.sharedManager.getLayoutType()
		
		switch row
			{
			case 0:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal1iPad.png")
					cell.schemeDescriptionLabel.text = "Landscape view, control pad on right"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal1.png")
					cell.schemeDescriptionLabel.text = "Landscape view, control pad on right; Largest game screen"
					}
				if controlScheme == .Horizontal1
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			case 1:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal2iPad.png")
					cell.schemeDescriptionLabel.text = "Landscape view, control pad on left"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal2.png")
					cell.schemeDescriptionLabel.text = "Landscape view, control pad on left; Largest game screen"
					}
				if controlScheme == .Horizontal2
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			case 2:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal5iPad.png")
					cell.schemeDescriptionLabel.text = "Landscape view, D-pad style, directional controls on left, action buttons on right"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal5.png")
					cell.schemeDescriptionLabel.text = "Landscape view, D-pad style, directional controls on left, action buttons on right; Largest game screen"
					}
				if controlScheme == .Horizontal5
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			case 3:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal3iPad.png")
					cell.schemeDescriptionLabel.text = "Landscape view, up/down controls on left, left/right controls on right"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal3.png")
					cell.schemeDescriptionLabel.text = "Landscape view, up/down controls on left, left/right controls on right; Smaller game screen"
					}
				if controlScheme == .Horizontal3
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			case 4:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal4iPad.png")
					cell.schemeDescriptionLabel.text = "Landscape view, up/down controls on right, left/right controls on left"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotHorizontal4.png")
					cell.schemeDescriptionLabel.text = "Landscape view, up/down controls on right, left/right controls on left; Smaller game screen"
					}
				if controlScheme == .Horizontal4
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			case 5:
				if UIDevice.current.userInterfaceIdiom == .pad
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotVerticaliPad.png")
					cell.schemeDescriptionLabel.text = "Portrait view"
					}
				else
					{
					cell.controlSchemeImageView.image = UIImage(named: "ScreenshotVertical.png")
					cell.schemeDescriptionLabel.text = "Portrait view; Smallest game screen"
					}
				if controlScheme == .Vertical
					{
					cell.currentSchemeLabel.isHidden = false
					}
				else
					{
					cell.currentSchemeLabel.isHidden = true
					}
			default:
				break
			}
		return cell
	}
}
