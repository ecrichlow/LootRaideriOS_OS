/*******************************************************************************
* ControlSchemeTableViewCell.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Settings Control Scheme tableview cell
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/24/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

class ControlSchemeTableViewCell: UITableViewCell
{

	@IBOutlet weak var controlSchemeImageView: UIImageView!
	@IBOutlet weak var currentSchemeLabel: UILabel!
	@IBOutlet weak var schemeDescriptionLabel: UILabel!

	override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
