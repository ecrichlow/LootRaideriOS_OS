/*******************************************************************************
* InAppPurchaseManager.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the manager for In-App Purchases
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/30/18		*	EGC	*	File creation date
*******************************************************************************/

import Foundation
import StoreKit

protocol IAPDelegate
{
	func productsRetrieved(products : [SKProduct])
	func failedProductRetrieval()
	func purchaseComplete(product: SKProduct?)
	func purchaseFailed(product: SKProduct?, reason: String)
	func downloadComplete(product: SKProduct?)
	func downloadDelayed(product: SKProduct?)
	func downloadFailed(product: SKProduct?, reason: String)
	func purchaseRestored(product: SKProduct?)
	func fileSaveError(product: SKProduct?)
}

class InAppPurchaseManager: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate
{

	static let sharedManager = InAppPurchaseManager()

	var delegate : IAPDelegate?

	var productList = [SKProduct]()
	var unfinishedDownloads = [SKDownload]()

	func prepareForTransactions()
	{
		SKPaymentQueue.default().add(self)
	}

	func retrieveProducts()
	{
		var productIDs = Set<String>()
		for index in 2..<ConfigurationManager.defaultNumProductsToQuery
			{
			let nextProductID = String(format: "LR_%04d", index)
			productIDs.insert(nextProductID)
			}
		productList.removeAll()
		let request = SKProductsRequest(productIdentifiers: productIDs)
		request.delegate = self
		request.start()
	}

	func buyProduct(product: SKProduct)
	{
		let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
	}

	func restoreProducts()
	{
		SKPaymentQueue.default().restoreCompletedTransactions()
	}

	func getProductForIdentifier(identifier: String) -> SKProduct?
	{
		for nextProduct in productList
			{
			if nextProduct.productIdentifier == identifier
				{
				return nextProduct
				}
			}
		return nil
	}

	// MARK: SKPaymentTransactionObserver methods

	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
	{
		for transaction in transactions
			{
			switch transaction.transactionState
				{
				case SKPaymentTransactionState.purchased:
					ConfigurationManager.sharedManager.addPurchasedItem(identifier: transaction.payment.productIdentifier)
					if ConfigurationManager.unlockAllLevelsPlusComboIdentifiers.contains(transaction.payment.productIdentifier)
						{
						ConfigurationManager.sharedManager.setUnlockAllLevels(newValue: true)
						}
					if transaction.payment.productIdentifier != ConfigurationManager.unlockAllLevelsIdentifier
						{
						let downloads = transaction.downloads
						unfinishedDownloads.append(contentsOf: downloads)
						SKPaymentQueue.default().start(downloads)
						}
					else
						{
						SKPaymentQueue.default().finishTransaction(transaction)
						}
					if delegate != nil
						{
						delegate!.purchaseComplete(product: getProductForIdentifier(identifier: transaction.payment.productIdentifier))
						}
				case SKPaymentTransactionState.failed:
					SKPaymentQueue.default().finishTransaction(transaction)
					if delegate != nil
						{
							delegate!.purchaseFailed(product: getProductForIdentifier(identifier: transaction.payment.productIdentifier), reason: transaction.error!.localizedDescription)
						}
				case SKPaymentTransactionState.restored:
					if ConfigurationManager.unlockAllLevelsPlusComboIdentifiers.contains(transaction.payment.productIdentifier)
						{
						ConfigurationManager.sharedManager.setUnlockAllLevels(newValue: true)
						}
					if transaction.payment.productIdentifier != ConfigurationManager.unlockAllLevelsIdentifier
						{
						let downloads = transaction.downloads
						unfinishedDownloads.append(contentsOf: downloads)
						SKPaymentQueue.default().start(downloads)
						}
					else
						{
						SKPaymentQueue.default().finishTransaction(transaction)
						}
					if delegate != nil
						{
						delegate!.purchaseRestored(product: getProductForIdentifier(identifier: transaction.payment.productIdentifier))
						}
				default:
					break
				}
			}
	}

	func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction])
	{
	}

	func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
	{
	}

	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
	{
	}

	func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload])
	{
		for download in downloads
			{
			if download.downloadState == .finished
				{
				guard let hostedContentPath = download.contentURL?.appendingPathComponent("Contents")
					else
						{
						return
						}
				do
					{
					let destination = NSHomeDirectory()
					let files = try FileManager.default.contentsOfDirectory(atPath: hostedContentPath.relativePath)
        			for file in files
        				{
            			let source = hostedContentPath.appendingPathComponent(file)
            			let destPath = URL(fileURLWithPath: destination)
            			let destFile = destPath.appendingPathComponent("Documents").appendingPathComponent(file)
            			if !FileManager.default.fileExists(atPath: destFile.path)
            				{
							try FileManager.default.moveItem(at: source, to: destFile)
							}
						}
					try FileManager.default.removeItem(at: download.contentURL!)
					}
				catch
					{
					if delegate != nil
						{
						delegate!.fileSaveError(product: getProductForIdentifier(identifier: download.transaction.payment.productIdentifier))
						}
					return
					}
				unfinishedDownloads.remove(at: unfinishedDownloads.index(of: download)!)
				if unfinishedDownloads.count == 0
					{
					SKPaymentQueue.default().finishTransaction(download.transaction)
					if delegate != nil
						{
						delegate!.downloadComplete(product: getProductForIdentifier(identifier: download.transaction.payment.productIdentifier))
						}
					break
					}
				}
			else if download.downloadState == .failed || download.downloadState == .cancelled
				{
				if delegate != nil
					{
					delegate!.downloadFailed(product: getProductForIdentifier(identifier: download.transaction.payment.productIdentifier), reason: download.error!.localizedDescription)
					}
				}
			else if download.downloadState == .waiting || download.downloadState == .paused
				{
				if delegate != nil
					{
					delegate!.downloadDelayed(product: getProductForIdentifier(identifier: download.transaction.payment.productIdentifier))
					}
				}
			}
	}

	func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool
	{
		return true
	}

	// MARK: SKProductsRequestDelegate methods

	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
	{
		if response.products.count > 0
			{
			for nextProduct in response.products
				{
				let identifier = nextProduct.productIdentifier
				let identifierNumber = Int(identifier.replacingOccurrences(of: "LR_", with: ""))
				var index = 0
				var inserted = false
				for nextSortedEntry in productList
					{
					let productIdentifier = nextSortedEntry.productIdentifier
					let productIdentifierNumber = Int(productIdentifier.replacingOccurrences(of: "LR_", with: ""))
					if identifierNumber! < productIdentifierNumber!
						{
						productList.insert(nextProduct, at: index)
						inserted = true
						break
						}
					index += 1
					}
				if !inserted
					{
					productList.append(nextProduct)
					}
				}
			}
		if delegate != nil
			{
			delegate!.productsRetrieved(products: productList)
			}
	}
}
