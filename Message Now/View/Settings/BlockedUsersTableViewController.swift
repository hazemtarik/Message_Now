//
//  BlockedUsersTableViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/25/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class BlockedUsersTableViewController: UITableViewController {

    
    private let vm = BlockedViewModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFetch()
    }

    
    // MARK:- Fetch users
    
    func initFetch() {
        vm.reloadTableViewClouser = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        vm.initFetch()
    }
    
    
    
    
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vm.numberOfCells!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath) as! BlockedUsersTableViewCell
        cell.userVM = vm.userViewModel[indexPath.row]
        return cell
    }
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }


}
