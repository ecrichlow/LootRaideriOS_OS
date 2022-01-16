/*******************************************************************************
* StartLevelTableViewCell.swift
*
* Title:			Gold Blocker
* Description:		Gold Blocker for iPhone and iPad
*						This file contains the controller implementation for
*						application's Settings Starting Level tableview cell
* Author:			Eric Crichlow
* Version:			1.0
* Copyright:		(c) 2018 Infusions of Grandeur. All rights reserved.
********************************************************************************
*	08/26/18		*	EGC	*	File creation date
*******************************************************************************/

import UIKit

class StartLevelTableViewCell: UITableViewCell
{

	@IBOutlet weak var levelImageView: UIImageView!
	@IBOutlet weak var levelNumberLabel: UILabel!
	@IBOutlet weak var levelNameLabel: UILabel!
	@IBOutlet weak var currentStartLevelLabel: UILabel!
	
	override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

}
