/*******************************************************************************
* ExtrasTableViewCell.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's In-App Purchasing tableview cell
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	09/04/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit
import StoreKit

protocol BuyDelegate
{
	func buyButtonTapped(product : SKProduct)
}

class ExtrasTableViewCell: UITableViewCell
{

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var buyButton: UIButton!
	
	var product : SKProduct?
	var delegate : BuyDelegate?

	// MARK: Lifecycle Methods

	override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

	@IBAction func buy(_ sender: UIButton)
	{
		if let buyDelegate = delegate, let purchaseProduct = product
			{
			buyDelegate.buyButtonTapped(product: purchaseProduct)
			}
	}
}
