//
//  AboutTableViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/10/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    public var name: String?
    public var uid : String?
    
    private let vm = AboutViewModel()
    
    
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
    }
    
    
    
    
    
    
    
    
    // MARK:- Init view and view model
    
    private func initView() {
        profileImage.layer.cornerRadius   = 35
        profileImage.layer.borderColor    = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        profileImage.layer.borderWidth    = 0.4
        profileImage.isUserInteractionEnabled = true
        
        statusView.layer.cornerRadius   = 7
        statusView.layer.borderColor    = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
        statusView.layer.borderWidth    = 1.5
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tapGesture.addTarget(self, action: #selector(photoPressed))
        
        tableView.tableFooterView = UIView()
        title = name
    }
    
    
    private func initVM() {
        vm.reloadTableViewClosure = { [unowned self] in
            let user = self.vm.userViewModel
            guard user.imageURL != nil else { return }
            self.profileImage.KFloadImage(url: user.imageURL!)
            let status = DefaultSettings.shared.availability()
            let isBlocked = FBNetworkRequest.shared.blockedList.contains(user.uid!)
            if !status || isBlocked || !user.isOnline! { self.statusView.isHidden = true }
            else {
                self.statusView.backgroundColor = .systemGreen
                self.statusView.isHidden = false
            }
            self.tableView.reloadData()
        }
        vm.showAlertClosure = { [unowned self] in
            Alert.showAlert(at: self, title: "", message: self.vm.message ?? "")
        }
        vm.checkBlocking(uid: uid!)
        vm.initFetch(uid: uid!)
    }
    
    
    
    
    
    
    // MARK:- Actions
    
    @objc private func photoPressed() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "toPhoto") as! PhotoDetailViewController
        vc.photoURL = vm.userViewModel.imageURL!
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return sectionView
        } else {
            return UIView()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 180
        } else {
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
        let row = indexPath.row
        let section = indexPath.section
        
        cell.detailTextLabel?.textColor = .gray
        
        if row == 0 && section == 0 {
            cell.textLabel?.text   = "Full Name"
            cell.detailTextLabel?.text = title
        } else if row == 1 && section == 0 {
            cell.textLabel?.text   = "Username"
            cell.detailTextLabel?.text = vm.userViewModel.username ?? ""
        } else if row == 2 && section == 0 {
            cell.textLabel?.text   = "Email"
            cell.detailTextLabel?.text = vm.userViewModel.email ?? ""
        } else if row == 3 && section == 0 {
            cell.textLabel?.text   = "Country"
            cell.detailTextLabel?.text = vm.userViewModel.country
        } else if row == 0 && section == 1 {
            cell.textLabel?.text   = vm.isBlocked ? "Unblock" : "Block"
            cell.textLabel?.textColor = .systemRed
            cell.detailTextLabel?.text = String()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 1 {
            vm.isBlocked ? vm.unblockUser(uid: uid!) : vm.blockUser(uid: uid!)
        }
    }
    
}
