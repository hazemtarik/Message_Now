//
//  RequestsViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 6/17/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    
    var usersRecived = [User]() { didSet { self.tableView.reloadData() } }
    var usersSent    = [User]() { didSet { self.tableView.reloadData() } }
    
    let vm = RequestsViewModel()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
    }
    
    
    
    
    
    
    // MARK:- Init view and view model
    
    private func initView() {
        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.tableFooterView = UIView()
    }
    
    private func initVM() {
        vm.reloadTableView = { [weak self] in
            guard let self = self else { return }
            if self.vm.numberOfCells == 0 {
                self.tableView.isHidden = true
            } else {
                self.tableView.isHidden = false
            }
            self.tableView.reloadData()
        }
        vm.initFetch()
        
    }
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @IBAction func segmentedPress(_ sender: UISegmentedControl) {
        vm.selectedSegmentIndex(SegmentIndex: sender.selectedSegmentIndex)
    }
    
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}









// TableView delegate and datasource

extension RequestsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell", for: indexPath) as! RequestsCell
            cell.user = vm.userViewModel[indexPath.row]
            return cell
        } else {
            let Sentcell = tableView.dequeueReusableCell(withIdentifier: "SentCell", for: indexPath) as! SentCell
            Sentcell.user = vm.userViewModel[indexPath.row]
            return Sentcell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}
