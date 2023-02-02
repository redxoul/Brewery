//
//  BeerDetailViewController.swift
//  Brewery
//
//  Created by Cody on 2022/08/27.
//

import UIKit
import Then

class BeerDetailViewController: UITableViewController {

    var beer: Beer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = beer?.name ?? "이름없는 맥주"
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        let imageURL = URL(string: beer?.imageUrl ?? "")
        let headerView = UIImageView(frame: frame).then {
            $0.contentMode = .scaleAspectFit
            $0.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "beer_icon"))
        }
        
        tableView = UITableView(frame: tableView.frame, style: .insetGrouped).then {
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "BeerDetailListCell")
            $0.rowHeight = UITableView.automaticDimension
            $0.tableHeaderView = headerView
        }
        
    }
}


// MARK: - Table view datasource, delegate
extension BeerDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return beer?.foodPairing?.count ?? 0
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "ID"
        case 1:
            return "Description"
        case 2:
            return "Brewers Tips"
        case 3:
            let isFoodPairingEmpty = beer?.foodPairing?.isEmpty ?? true
            return isFoodPairingEmpty ? nil : "Food Pairing"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BeerDetailListCell").then {
            $0.textLabel?.numberOfLines = 0
            $0.selectionStyle = .none
            
            switch indexPath.section {
            case 0:
                $0.textLabel?.text = String(describing: beer?.id ?? 0)
            case 1:
                $0.textLabel?.text = beer?.description ?? "설명 없는 맥주"
            case 2:
                $0.textLabel?.text = beer?.brewersTips ?? "팁 없는 맥주"
            case 3:
                $0.textLabel?.text = beer?.foodPairing?[indexPath.row] ?? ""
            default:
                $0.textLabel?.text = ""
            }
        }
        
        return cell
    }
}
