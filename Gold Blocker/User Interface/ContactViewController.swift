/*******************************************************************************
* ContactViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Contact Us screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	09/16/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import FirebaseAnalytics
import MessageUI

class ContactViewController: UIViewController, MFMailComposeViewControllerDelegate
{

	// MARK: Lifecycle Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
	@IBAction func exit(_ sender: UIButton)
	{
		dismiss(animated: true, completion: nil)
	}

	@IBAction func email(_ sender: UIButton)
	{
		if MFMailComposeViewController.canSendMail()
			{
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients([ConfigurationManager.defaultContactEmail])
			mail.modalPresentationStyle = .fullScreen
			present(mail, animated: true)
			Analytics.logEvent("ComposeEmail", parameters: nil)
			}
		else
			{
            let alert = UIAlertController(title: "Mail Error", message: "This account not set up for e-mail", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            	}))
			self.present(alert, animated: true, completion: nil)
			Analytics.logEvent("ComposeEmailFailure", parameters: nil)
			}
	}

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
	{
		if error == nil
			{
			Analytics.logEvent("EmailSent", parameters: nil)
			}
		else
			{
			Analytics.logEvent("EmailSendFailed", parameters: nil)
			}
		controller.dismiss(animated: true)
	}
}
