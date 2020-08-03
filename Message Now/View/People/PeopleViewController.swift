//
//  PeopleTableViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/24/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {
    
    let searchController = UISearchController()
    let vm               = PeopleViewModel()
    var filtred          = [UserViewModel]()
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noFriendsView : UIView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupNoFriendsView()
        initVM()
    }
    
    
    
    
    
    // MARK:- Init view and view model
    
    
    private func initView() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    
    private func setupNoFriendsView() {
        noFriendsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noFriendsView)
        noFriendsView.isHidden = true
        noFriendsView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        noFriendsView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    }
    
    
    private func initVM() {
        vm.reloadTableViewClosure = { [weak self] in
            guard let self = self else { return }
            if self.vm.numberOfCells == 0 {
                self.tableView.alpha = 0
                self.noFriendsView.isHidden = false
            } else {
                self.tableView.reloadData()
                self.noFriendsView.isHidden = true
                UIView.animate(withDuration: 0.2) {
                    self.tableView.alpha = 1
                }
            }
        }
        vm.initFetch()
    }
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @IBAction func addFriendPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard.init(name: "People", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addFriend")
        present(vc, animated: true)
    }
    
    
    
}










// MARK:- TableView Delegate and Datasource

extension PeopleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.numbserOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return vm.titlesOfSection[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfCells
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.cellVM = vm.getCellViewModel(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        vm.pressedCell(at: indexPath)
        performSegue(withIdentifier: "PeopleToChating", sender: self)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        vm.pressedCell(at: indexPath)
        performSegue(withIdentifier: "PeopleToAbout", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PeopleToAbout" {
            let vc = segue.destination as! AboutTableViewController
            vc.name = vm.selectedCell!.name!
            vc.uid  = vm.selectedCell!.uid!
        } else if segue.identifier == "PeopleToChating" {
            let vc = segue.destination as! ChatingViewController
            vc.name = vm.selectedCell!.name!
            vc.uid  = vm.selectedCell!.uid!
        }
    }
}







// MARK:- Search controller delegate

extension PeopleViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased()
        vm.searchAbout(text: text!)
        
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        vm.startSearching()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        vm.endSearching()
    }
    
}
