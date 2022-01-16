/*******************************************************************************
* ExtrasViewController.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's In-App Purchasing screen
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	09/04/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import StoreKit
import FirebaseAnalytics

class ExtrasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BuyDelegate, IAPDelegate
{

	@IBOutlet weak var extrasTableView: UITableView!

	var productList : [SKProduct]?
	var missingPurchases = false

	// MARK: Lifecycle Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
		if SKPaymentQueue.canMakePayments()
			{
			InAppPurchaseManager.sharedManager.delegate = self
			InAppPurchaseManager.sharedManager.retrieveProducts()
			}
    }

	override func viewWillAppear(_ animated: Bool)
	{
	}

	override func viewDidAppear(_ animated: Bool)
	{
		if !SKPaymentQueue.canMakePayments()
			{
			let alert = UIAlertController(title: "Purchases Not Allowed", message: "Please enable In-App purchases for this app in Settings", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)})
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
	}

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
	// MARK: Game logic

	@IBAction func exit(_ sender: UIButton)
	{
		dismiss(animated: true, completion: nil)
	}

	@IBAction func restore(_ sender: UIButton)
	{
		if !missingPurchases
			{
			let alert = UIAlertController(title: "Restore Previous Purchases", message: "Check for In-App purchases that aren't currently loaded?", preferredStyle: .alert)
			let alertActionNo = UIAlertAction(title: "Cancel", style: .default, handler: nil)
			let alertActionYes = UIAlertAction(title: "OK", style: .default, handler: {action in
				InAppPurchaseManager.sharedManager.restoreProducts()})
			alert.addAction(alertActionNo)
			alert.addAction(alertActionYes)
			self.present(alert, animated: true, completion: nil)
			}
		else
			{
			let alert = UIAlertController(title: "Restore Previous Purchases", message: "You have purchases that aren't currently loaded. Restore them?", preferredStyle: .alert)
			let alertActionNo = UIAlertAction(title: "Cancel", style: .default, handler: nil)
			let alertActionYes = UIAlertAction(title: "OK", style: .default, handler: {action in
				InAppPurchaseManager.sharedManager.restoreProducts()})
			alert.addAction(alertActionNo)
			alert.addAction(alertActionYes)
			self.present(alert, animated: true, completion: nil)
			}
	}

	// MARK: Tableview delegate methods

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
	{
		return nil
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return ConfigurationManager.defaultSettingsGetExtrasRowHeight
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
			guard let list = productList
			else
				{
				return 0
				}
			return list.count
			}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExtrasTableViewCell", for: indexPath) as! ExtrasTableViewCell
		let row = indexPath.row
		let product = productList![row]
		let priceFormatter = NumberFormatter()
		priceFormatter.numberStyle = .currency
		cell.titleLabel.text = product.localizedTitle
		cell.descriptionLabel.text = product.localizedDescription
		cell.priceLabel.text = priceFormatter.string(from: product.price)
		cell.delegate = self
		cell.product = product
		if ConfigurationManager.sharedManager.checkForLevelOwned(identifier: product.productIdentifier)
			{
			// TODO: Do better than showing that an expansion is owned when it isn't present
			cell.buyButton.setImage(UIImage(named: "Owned"), for: .normal)
			cell.buyButton.setImage(UIImage(named: "Owned"), for: .selected)
			cell.buyButton.setImage(UIImage(named: "Owned"), for: .highlighted)
			cell.buyButton.setImage(UIImage(named: "Owned"), for: .focused)
			cell.buyButton.setImage(UIImage(named: "Owned"), for: .disabled)
			cell.buyButton.isEnabled = false
			if !(product.productIdentifier == ConfigurationManager.unlockAllLevelsIdentifier || ConfigurationManager.sharedManager.fileExistsForProductIdentifier(identifier:product.productIdentifier))
				{
				missingPurchases = true
				}
/*
			if product.productIdentifier == ConfigurationManager.unlockAllLevelsIdentifier || ConfigurationManager.sharedManager.fileExistsForProductIdentifier(identifier:product.productIdentifier)
				{
				cell.buyButton.setImage(UIImage(named: "Owned"), for: .normal)
				cell.buyButton.setImage(UIImage(named: "Owned"), for: .selected)
				cell.buyButton.setImage(UIImage(named: "Owned"), for: .highlighted)
				cell.buyButton.setImage(UIImage(named: "Owned"), for: .focused)
				cell.buyButton.setImage(UIImage(named: "Owned"), for: .disabled)
				cell.buyButton.isEnabled = false
				}
			else
				{
				cell.buyButton.setImage(UIImage(named: "Restore"), for: .normal)
				cell.buyButton.setImage(UIImage(named: "Restore"), for: .selected)
				cell.buyButton.setImage(UIImage(named: "Restore"), for: .highlighted)
				cell.buyButton.setImage(UIImage(named: "Restore"), for: .focused)
				cell.buyButton.setImage(UIImage(named: "Restore"), for: .disabled)
				cell.buyButton.isEnabled = true
				}
*/
			}
		else
			{
			cell.buyButton.setImage(UIImage(named: "Buy"), for: .normal)
			cell.buyButton.setImage(UIImage(named: "Buy"), for: .selected)
			cell.buyButton.setImage(UIImage(named: "Buy"), for: .highlighted)
			cell.buyButton.setImage(UIImage(named: "Buy"), for: .focused)
			cell.buyButton.setImage(UIImage(named: "Buy"), for: .disabled)
			cell.buyButton.isEnabled = true
			}

		return cell
	}

	// MARK: ExtrasTableViewCell BuyDelegate methods

	func buyButtonTapped(product : SKProduct)
	{
		InAppPurchaseManager.sharedManager.buyProduct(product: product)
		Analytics.logEvent("PurchaseInitiated", parameters: [AnalyticsParameterItemID: product.productIdentifier])
	}

	// MARK: IAPDelegate methods

	func productsRetrieved(products : [SKProduct])
	{
		productList = products
		DispatchQueue.main.async
			{
				self.extrasTableView.reloadData()
			}
	}

	func failedProductRetrieval()
	{
		let alert = UIAlertController(title: "Request Failed", message: "Was unable to retrieve list of available levels. Please restart and try again.", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
	}

	func purchaseComplete(product: SKProduct?)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		if purchaseProduct.productIdentifier == ConfigurationManager.unlockAllLevelsIdentifier
			{
			let alert = UIAlertController(title: "Purchase Complete", message: "All levels are now unlocked!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		else if ConfigurationManager.unlockAllLevelsPlusComboIdentifiers.contains(purchaseProduct.productIdentifier)
			{
			let alert = UIAlertController(title: "Purchase Complete", message: "All current levels are now unlocked, and new levels will be available shortly!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		else
			{
			let alert = UIAlertController(title: "Purchase Complete", message: "New levels will be available shortly!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		Analytics.logEvent("CompletedPurchase", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier])
		extrasTableView.reloadData()
	}

	func purchaseFailed(product: SKProduct?, reason: String)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		let alert = UIAlertController(title: "Purchase Failed", message: "Purchase was not successful. Please try again.", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
		Analytics.logEvent("PurchaseFailed", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier, "Error": reason])
	}

	func downloadComplete(product: SKProduct?)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		let alert = UIAlertController(title: "Download Complete", message: "New levels are ready to play!", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
		GameboardManager.sharedManager.loadGameboards()
		Analytics.logEvent("CompletedPurchase", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier])
	}

	func downloadDelayed(product: SKProduct?)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		let alert = UIAlertController(title: "Download Delayed", message: "New levels are not ready yet. Check again after restarting the game.", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
		Analytics.logEvent("DownloadDelayed", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier])
	}

	func downloadFailed(product: SKProduct?, reason: String)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		let alert = UIAlertController(title: "Download Failed", message: "New levels failed to download. Check again after restarting the game.", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
		Analytics.logEvent("DownloadFailed", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier, "Error": reason])
	}

	func purchaseRestored(product: SKProduct?)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		if purchaseProduct.productIdentifier == ConfigurationManager.unlockAllLevelsIdentifier
			{
			let alert = UIAlertController(title: "Restore Complete", message: "All levels are now unlocked!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		else if ConfigurationManager.unlockAllLevelsPlusComboIdentifiers.contains(purchaseProduct.productIdentifier)
			{
			let alert = UIAlertController(title: "Restore Complete", message: "All current levels are now unlocked, and new levels will be available shortly!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		else
			{
			let alert = UIAlertController(title: "Restore Complete", message: "New levels will be available shortly!", preferredStyle: .alert)
			let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(alertAction)
			self.present(alert, animated: true, completion: nil)
			}
		Analytics.logEvent("PurchaseRestored", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier])
	}

	func fileSaveError(product: SKProduct?)
	{
		guard let purchaseProduct = product
			else
				{
				return
				}
		let alert = UIAlertController(title: "File Save Failed", message: "New levels failed to save. Check again after restarting the game.", preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		self.present(alert, animated: true, completion: nil)
		Analytics.logEvent("FileSaveFailed", parameters: [AnalyticsParameterItemID: purchaseProduct.productIdentifier])
	}
}
