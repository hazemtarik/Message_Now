//
//  FriendsViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/10/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit


protocol PresentChatingDelegate {
    func selectedCell(user: UserViewModel)
}




class FriendsViewController: UIViewController {
    
    
    
    
    let searchController = UISearchController()
    let vm               = PeopleViewModel()
    var filtred          = [UserViewModel]()
    
    var delegate: PresentChatingDelegate?
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noFriendsView : UIView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setupNoFriendsView()
        initVM()
    }
    
    
    
    
    
    
    //MARK:- Init view and view model
    
    private func initView() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.searchController = searchController
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        
        tableView.tableFooterView = UIView()
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
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    
}











// MARK:- TableView Delegate and Datasource

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        vm.pressedCell(at: indexPath)
        performSegue(withIdentifier: "FriendsToAbout", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FriendsToAbout" {
            let vc = segue.destination as! AboutTableViewController
            vc.name = vm.selectedCell!.name!
            vc.uid  = vm.selectedCell!.uid!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.pressedCell(at: indexPath)
        delegate?.selectedCell(user: vm.selectedCell!)
        if searchController.isActive { searchController.isActive = false }
        dismiss(animated: true)
    }
}














// MARK:- Search Controller Delegate

extension FriendsViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased()
        vm.searchAbout(text: text!)
        view.layoutIfNeeded()
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        vm.startSearching()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        vm.endSearching()
    }
}
