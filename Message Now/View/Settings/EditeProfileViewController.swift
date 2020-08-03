//
//  EditeProfileViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 7/21/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import FirebaseStorage

class EditeProfileViewController: UIViewController {
    
    
    private var countryList = [String]()
    private let vm          = EditeProfileViewModel()
    private var image       = UIImage() { didSet {
                              profileImage.setImage(image, for: .normal) }}
    
    
    
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryList = Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
        
        initView()
        initVM()
    }

    
    
    
    
    
    
    // MARK:- Init view and view model
    
    private func initView() {
        profileImage.layer.cornerRadius = 55
        profileImage.layer.masksToBounds = true
    }
    
    private func initVM() {
        vm.loadUserInfoClosure = { [unowned self] in
            self.image = self.vm.userInfo?.photo ?? UIImage(named: "Avatar")!
            let index = self.countryList.firstIndex(of: self.vm.userInfo?.country ?? "Egypt")
            self.pickerView.selectRow(index!, inComponent: 0, animated: true)
        }
        vm.showAlertClosure = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
            Alert.showAlert(at: self, title: "", message: self.vm.message!)
        }
        vm.initFetch()
    }
    
    
    
    
    
    
    // MARK:- Actions
    
    @IBAction func profileImagePressed(_ sender: Any) {
        let alert = UIAlertController()
        alert.addAction(.init(title: "Change Photo", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            SystemAuthorization.shared.photoAuthorization { [weak self] (isAuth, message) in
                guard let self = self else { return }
                if isAuth {
                    self.imagePressed()
                } else {
                    DispatchQueue.main.async {
                        Alert.showAlert(at: self, title: "Photo Library", message: message!)
                    }
                }
            }
        }))
        alert.addAction(.init(title: "Remove Photo", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.image = UIImage(named: "Avatar")!
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let activity = UIActivityIndicatorView()
        activity.startAnimating()
        activity.hidesWhenStopped = true
        sender.customView = activity
        let country = countryList[pickerView.selectedRow(inComponent: 0)]
        vm.UpdateProfile(photo: image, country: country)
    }
    
    
    

}






// MARK:- Picker view delegate

extension EditeProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
}








// MARK:- Image picker  delegate

extension EditeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func imagePressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}
