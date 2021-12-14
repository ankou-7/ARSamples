//
//  MenuTableViewController.swift
//  ARSample
//
//  Created by 安江洸希 on 2021/04/26.
//

import UIKit

class MenuTableViewController: UITableViewController {

    let viewModel = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Menu_cell", for: indexPath)
        
        let item = viewModel.item(row: indexPath.row)
        let title_label = cell.viewWithTag(1) as! UILabel
        let description_label = cell.viewWithTag(2) as! UILabel
        title_label.text = item.title
        description_label.text = item.description
        //cell.update(item: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = viewModel.viewController(row: indexPath.row)

        navigationController?.pushViewController(vc, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

}
