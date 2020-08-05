//
//  ChatsTableViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/23/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, PresentChatingDelegate {
    
    private let vm                   = ChatsViewModel()
    private var filtred              = [RecentsViewModel]()
    private let searchController     = UISearchController()
    private let button               = UIButton()
    private let badge                = UILabel(frame: .init(x: 20, y: -5, width: 22, height: 22))
    
    private var selectedCell    : UserViewModel?
    
    @IBOutlet var connectionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        badge.layoutIfNeeded()
        tableView.reloadData()
        let image = currentUser.image
        button.setImage(resizeImage(image: image!, newWidth: 30, newHieght: 30), for: .normal)
    }
    
    
    
    
    
    
    
    // MARK:- Init View and ViewModel
    
    private func initView() {
        setupLeftButton()
        tableView.alpha = 0
        tableView.tableFooterView = UIView()
        
        ActivityIndicator.initActivityIndecator(view: view)
        ActivityIndicator.startAnimating()
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.shadowImage = UIImage()
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.clipsToBounds = true
    }
    
    
    
    private func initVM() {
        vm.updateIndicatorClouser = { [weak self] in
            guard let self = self else { return }
            if !self.vm.isAnimating {
                ActivityIndicator.stopAnimating()
            } else {
                ActivityIndicator.startAnimating()
                self.tableView.alpha = 0
            }
        }
        
        vm.updateRequestsClouser = { [weak self] in
            guard let self = self else { return }
            let numberOfRequests = FBNetworkRequest.shared.requestsRecived.count
            if numberOfRequests == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.badge.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.badge.alpha = 1
                    self.badge.text = "\(numberOfRequests)"
                }
            }
            self.badge.layoutIfNeeded()
        }
        
        vm.updateTableViewClouser = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.tableView.alpha = 1
                    self.tableView.reloadData()
                }
            }
        }
        vm.updatebadgeClouser = { [weak self] in
            guard let self = self else { return }
            let value = self.vm.countUnreadedMessages
            if value == 0 {
                self.tabBarController?.tabBar.items![0].badgeValue = nil
            } else {
                self.tabBarController?.tabBar.items![0].badgeValue = "\(value)"
            }
        }
        vm.initFetchUnreadMessages()
        vm.initFetchRequests()
        vm.initFetchMessages()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Actions
    
    @objc private func requestsPressed() {
        let storyboard = UIStoryboard.init(name: "Chats", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "requests")
        present(vc, animated: true)
    }
    
    @IBAction func friendsPressd(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard.init(name: "Chats", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "friends") as! FriendsViewController
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    
    // Implementation for a protocol to pesent Chating View Controller
    func selectedCell(user: UserViewModel) {
        selectedCell = user
        performSegue(withIdentifier: "ChatsToChating", sender: self)
    }
    
    
    // Setup left button bar
    private func setupLeftButton() {
        let requestView                                              = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30))
        badge.alpha                                                  = 0
        badge.textColor                                              = .white
        badge.font                                                   = UIFont.systemFont(ofSize: 13)
        badge.textAlignment                                          = .center
        badge.backgroundColor                                        = .systemRed
        badge.layer.cornerRadius                                     = 11
        badge.layer.masksToBounds                                    = true
        badge.adjustsFontSizeToFitWidth                              = true
        
        button.center                                                = requestView.center
        button.translatesAutoresizingMaskIntoConstraints             = false
        button.layer.cornerRadius                                    = 15
        button.layer.masksToBounds                                   = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive  = true
        
        if UserDefaults.standard.string(forKey: "id") == Auth.auth().currentUser!.uid {
            let image = UIImage(data: UserDefaults.standard.data(forKey: "image")!)
            button.setImage(resizeImage(image: image!, newWidth: 30, newHieght: 30), for: .normal)
        }
        
        requestView.addSubview(button)
        requestView.addSubview(badge)
        let lefButton = UIBarButtonItem(customView: requestView)
        button.addTarget(self, action: #selector(requestsPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = lefButton
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat, newHieght: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHieght))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHieght))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
}












// MARK:- Setup TableView Datasource

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {  return vm.numberOfSection }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return vm.isReachable ? UIView() : connectionView }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return 25 }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return vm.numberOfMessages }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.chats, for: indexPath) as! ChatsCell
        cell.cellVM = vm.messageViewModel[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.pressedCell(at: indexPath)
        performSegue(withIdentifier: "ChatsToChating", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatsToChating" {
            let vc = segue.destination as! ChatingViewController
            if selectedCell != nil {
                vc.name = selectedCell!.name!
                vc.uid  = selectedCell!.uid!
                selectedCell = nil
            } else {
                vc.name = vm.selectedCell!.name!
                vc.uid  = vm.selectedCell!.uid!
            }
        }
    }
    
    
    
}








// MARK:- Search Controller Delegate

extension ChatsViewController: UISearchControllerDelegate, UISearchResultsUpdating {
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
