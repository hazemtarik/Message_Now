//
//  ChatingViewController.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/24/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ChatingViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet var titleView        : UIView!
    @IBOutlet weak var titleLabel  : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var tableView   : UITableView!
    
    
    @IBOutlet weak var recordView  : UIView!
    @IBOutlet weak var prograssBar : UIProgressView!
    @IBOutlet weak var timeLabel   : UILabel!
    
    @IBOutlet weak var sendButton  : UIButton!
    @IBOutlet weak var mapButton   : UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoButton : UIButton!
    
    @IBOutlet weak var textView    : UITextView!
    @IBOutlet weak var BottomView  : UIVisualEffectView!
    @IBOutlet weak var parentactionStack: UIStackView!
    @IBOutlet weak var actionsStack: UIStackView!
    
    
    @IBOutlet weak var heightVisualView: NSLayoutConstraint!
    @IBOutlet weak var bottomVisualView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfStack: NSLayoutConstraint!
    
    
    private let button = UIButton()
    
    public  var name = String()
    public  var uid  = String()
    
    private let database = FBDatabase.shared
    private var selectedCell = Message()
    private let manager  = CLLocationManager()
    private let vm       = ChatingViewModel()
    private var current  = 0.0
    
    
    private let player   = Audio()
    private var timer    = Timer()
    private var recordingSession: AVAudioSession!
    private var audioRecorder   : AVAudioRecorder!
    
    
    private var heightKeyboard: CGFloat = 0
    private var heightOfBottomView: CGFloat = 0
    private var keyboardWillShow = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initUserVM()
        initMessageVM()
        initNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.isEditable = false
        textView.resignFirstResponder()
        
        vm.endTyping(friendID: uid)
        
        let indexPath = self.tableView.indexPathsForVisibleRows
        for i in indexPath! {
            let cell = self.tableView.cellForRow(at: i) as? VoiceTableViewCell
            cell?.dismiss()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        vm.checkBlocking(uid: uid)
        super.viewWillAppear(animated)
        textView.isEditable = true
    }
    
    
    deinit {
        removeNotifications()
        FBDatabase.shared.removewMessagesObserver(forUID: uid)
        vm.readMessages(friendID: uid)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Init user and messages View Models
    
    func initUserVM() {
        vm.updateBottomViewClouser = { [weak self] in
            guard let self = self else { return }
            self.vm.isFriendBlocked || self.vm.isYouBlocked ? self.hideBottomView() : self.showBottomView()
        }
        vm.updateUserInfoClouser = { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text  = self.vm.friend?.name
            self.statusLabel.text = self.vm.friend?.status
        }
        vm.updateUserImageoClouser = { [weak self] in
            guard let self = self else { return }
            self.button.setImage(self.vm.friend_image, for: .normal)
        }
        vm.updateFriendStatusClouser = { [weak self] in
            guard let self = self else { return }
            self.statusLabel.text = self.vm.isTyping ? "Typing..." : self.vm.friend?.status
        }
        vm.fetchUserInfo(uid: uid)
        vm.detectFrindTyping(friendID: uid)
    }
    
    
    func initMessageVM() {
        vm.reloadTableViewClouser = { [weak self] in
            guard let self = self else { return }
            if self.vm.isNew {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
                self.player.playSound(file: "Message")
                self.vm.isNew = false
                self.vm.readMessages(friendID: self.uid)
            } else { self.tableView.reloadData() }
        }
        vm.fetchMessages(uid: uid)
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Setup view
    
    private func initView() {
        updateBottomView()
        setupBottomView()
        setupRightButton()
        textView.text = "Aa"
        textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        sendButton.isEnabled = false
        
        let bottom = view.safeAreaInsets.top + 44 + 30
        tableView.contentInset = .init(top: 5, left: 0, bottom: bottom, right: 0)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.estimatedRowHeight = 100
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.titleView = titleView
    }
    //---------------------------------------------------------------------------------------------
    private func setupBottomView() {
        textView.delegate = self
        textView.textContainerInset = .init(top: 7, left: 15, bottom: 7, right: 15)
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = true
    }
    //---------------------------------------------------------------------------------------------
    private func setupRightButton() {
        button.translatesAutoresizingMaskIntoConstraints             = false
        button.layer.cornerRadius                                    = 15
        button.layer.masksToBounds                                   = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive  = true
        
        let lefButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = lefButton
        button.addTarget(self, action: #selector(imagePressed), for: .touchUpInside)
    }
    //---------------------------------------------------------------------------------------------
    @objc private func imagePressed() {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else { performSegue(withIdentifier: "ChatingToAbout", sender: self) }
        
    }
    //---------------------------------------------------------------------------------------------
    func resizeImage(image: UIImage, newWidth: CGFloat, newHieght: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHieght))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHieght))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
    //---------------------------------------------------------------------------------------------
    func hideBottomView() {
        BottomView.isHidden = true
    }
    //---------------------------------------------------------------------------------------------
    func showBottomView() {
        BottomView.isHidden = false
    }
    
    
    
    
    
    
    
    
    
    
    
    // MARK:- Handle action buttons
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            if textView.isHidden { sendAudioRecording() }
            else {
                vm.sendTextMessage(uid: uid, text: textView.text)
                textView.text = ""
                let size = CGSize(width: textView.frame.width, height: .infinity)
                let height = textView.sizeThatFits(size)
                heightVisualView.constant = CGFloat(height.height) + 20
                heightConstraintOfStack.constant = CGFloat(height.height)
            }
            sender.isEnabled = false
            if vm.countOfCells != 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            SystemAuthorization.shared.photoAuthorization { [weak self] (isAuth, message) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if isAuth {
                        self.photoPressed()
                    } else {
                        Alert.showAlert(at: self, title: "Photo Library Access", message: message!)
                    }
                }
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            SystemAuthorization.shared.cameraAuthorization { [weak self] (isAuth, message) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if isAuth {
                        self.cameraPressed()
                    } else {
                        Alert.showAlert(at: self, title: "Camera Access", message: message!)
                    }
                }
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        manager.delegate = self
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            let status = CLLocationManager.authorizationStatus()
            if status == .denied  || status == .restricted{
                Alert.showAlert(at: self, title: "Loaction Access", message: "Please enable Location Services in your Settings")
            } else if status == .notDetermined {
                manager.requestWhenInUseAuthorization()
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "map") as! MapsViewController
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                vc.delegate = self
                DispatchQueue.main.async {
                    self.present(vc, animated: true)
                }
                
            }
        }
    }
    
    //---------------------------------------------------------------------------------------------
    // Handle recording action
    @IBAction func microphoneButtonPressed(_ sender: Any) {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            recordingSession = .sharedInstance()
            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                try recordingSession.overrideOutputAudioPort(.speaker)
                recordingSession.requestRecordPermission() { [unowned self] isAuth in
                    DispatchQueue.main.async {
                        if isAuth {
                            self.startAudioRecording()
                        } else {
                            Alert.showAlert(at: self, title: "Microphone Access", message: "Please enable Microphone in your Settings")
                        }
                    }
                }
            } catch {
                Alert.showAlert(at: self, title: "Voice Issue", message: error.localizedDescription)
            }
        }
    }
    //---------------------------------------------------------------------------------------------
    private func startAudioRecording() {
        let fileName = getDirectory().appendingPathComponent("sentAudio.m4a")
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        do{
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            updateRecordingUI()
        }catch{
            Alert.showAlert(at: self, title: "Voice Note", message: "There's a problem, Thanks to try again")
            print(error.localizedDescription)
        }
    }
    //---------------------------------------------------------------------------------------------
    private func sendAudioRecording() {
        audioRecorder.stop()
        recordingSession = .sharedInstance()
        do{
            try recordingSession.setActive(false)
            let data = try Data(contentsOf: getDirectory().appendingPathComponent("sentAudio.m4a"))
            vm.sendVoiceMessage(data: data, seconds: current, uid: uid)
            audioRecorder = nil
            updateRecordingUI()
        }catch{
            Alert.showAlert(at: self, title: "Voice Problem", message: error.localizedDescription)
        }
    }
    //---------------------------------------------------------------------------------------------
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    //---------------------------------------------------------------------------------------------
    @IBAction func cancelRecording(_ sender: UIButton) {
        audioRecorder.stop()
        audioRecorder.deleteRecording()
        audioRecorder = nil
        player.playSound(file: "Cancel")
        updateRecordingUI()
    }
    //---------------------------------------------------------------------------------------------
    private func updateRecordingUI() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if self.audioRecorder != nil {
                    self.actionsStack.isHidden = true
                    self.textView.isHidden = true
                    self.sendButton.isEnabled = true
                    self.recordView.isHidden = false
                    self.prograssBar.setProgress(0.0, animated: true)
                    self.timer = .scheduledTimer(timeInterval: 1.0, target: self, selector:
                        #selector(self.updateRecordingTime), userInfo: nil, repeats: true)
                    self.timer.fire()
                    
                } else {
                    self.timer.invalidate()
                    self.recordView.isHidden = true
                    self.actionsStack.isHidden = false
                    self.textView.isHidden = false
                    self.sendButton.isEnabled = false
                }
            }
        }
    }
    //---------------------------------------------------------------------------------------------
    @objc func updateRecordingTime() {
        current = audioRecorder.currentTime
        let seconds = stringFormate(time: Int(audioRecorder.currentTime)%60)
        let minuts = stringFormate(time: Int(audioRecorder.currentTime)/60)
        timeLabel.text = "\(minuts):\(seconds)"
        prograssBar.progress = Float(audioRecorder.currentTime / 600)
    }
    //---------------------------------------------------------------------------------------------
    private func stringFormate(time: Int)-> String{
        return String(format: "%02d", Int(time) % 60)
    }
    
    
    
    
    
    
    
    
    // MARK:- Handling Keyboard with Notifications
    
    private func initNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBottomView), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification?) {
        if (heightKeyboard != 0) { return }
        keyboardWillShow = true
        if let info = notification?.userInfo {
            if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                if (self.keyboardWillShow) {
                    self.heightKeyboard = keyboard.size.height
                    bottomVisualView.constant = heightKeyboard
                    tableView.contentInset.top = -view.safeAreaInsets.bottom + 10
                    let size = CGSize(width: textView.frame.width, height: .infinity)
                    let height = textView.sizeThatFits(size)
                    heightVisualView.constant = CGFloat(height.height) + 20
                    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
                    }) { (isSuccess) in
                        
                    }
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification?) {
        heightKeyboard = 0
        self.keyboardWillShow = false
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.bottomVisualView.constant = self.heightKeyboard
            self.tableView.contentInset.top = 10
            self.view.layoutIfNeeded()
        }, completion: nil)
        let height = heightOfBottomView + 5
        heightVisualView.constant = height
        textView.isEditable = true
    }
    
    @objc private func updateBottomView() {
        var height = (tabBarController?.tabBar.frame.height) ?? 42
        if UIDevice.current.orientation.isLandscape {
            height += 20
            heightOfBottomView = height
            tableView.contentInset.top = 25
        } else {
            height += 5
            heightOfBottomView = height
            heightVisualView.constant = height
            tableView.contentInset.top = 5
        }
    }
    
}









// MARK:- Handle Location

extension ChatingViewController: CLLocationManagerDelegate, locationDelegate {
    
    func sendLocation(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        vm.sendLocationMessage(uid: uid, latitude: latitude, longitude: longitude)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            let vc = storyboard?.instantiateViewController(withIdentifier: "map") as! MapsViewController
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .fullScreen
            vc.delegate = self
            present(vc, animated: true)
        }
    }

    
    @objc func openLocationByMap(tapGesture: UITapGestureRecognizer) {
        let gesture = tapGesture.view as! UIImageView
        let tag = gesture.tag
        let message = vm.messageViewModel[tag]
        let latitude = String(message.latitude!)
        let longitude = String(message.longitude!)
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(URL(string: "http://maps.google.com/maps?q=loc:\(latitude),\(longitude)&zoom=14&views=traffic&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
        }
    }
    
}








// MARK:- Handle Image Picker delegate and navigation

extension ChatingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func photoPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    private func cameraPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image = UIImage()
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        vm.sendPhotoMessage(image: image, uid: uid)
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func photoCellPressed(tapGesture: UITapGestureRecognizer) {
        let gesture = tapGesture.view as! UIImageView
        let tag = gesture.tag
        let vc = storyboard?.instantiateViewController(withIdentifier: "toPhoto") as! PhotoDetailViewController
        vc.photoURL = vm.messageViewModel[tag].photoURL!
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
}








// MARK:- TableView Data source and Delegate

extension ChatingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.countOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = vm.messageViewModel[indexPath.row]
        
        if message.msgKind == database.CheckMessageKind(msgKind: .photo) {
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoTableViewCell
            photoCell.photoStack.alignment = message.to == uid ? .trailing: .leading
            photoCell.checkMessageType(senderID: message.to!, photo: vm.friend_image!)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoCellPressed(tapGesture:)))
            photoCell.photo.tag = indexPath.row
            photoCell.photo.addGestureRecognizer(tapGesture)
            photoCell.msgVM = message
            return photoCell
            
            
            
            
            
        } else if message.msgKind == database.CheckMessageKind(msgKind: .location) {
            let locationCell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
            locationCell.locationStack.alignment = message.to == uid ? .trailing: .leading
            locationCell.checkMessageType(senderID: message.to!, photo: vm.friend_image!)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLocationByMap))
            locationCell.locationImage.addGestureRecognizer(tapGesture)
            locationCell.locationImage.tag = indexPath.row
            locationCell.msgVM = message
            return locationCell
            
            
            
            
            
        } else if message.msgKind == database.CheckMessageKind(msgKind: .voice) {
            let voiceCell = tableView.dequeueReusableCell(withIdentifier: "voiceCell", for: indexPath) as! VoiceTableViewCell
            voiceCell.checkMessageType(senderID: message.to!)
            if message.to == uid {
                voiceCell.VoiceStack.alignment = .trailing
                voiceCell.userImage.image = currentUser.image!
            } else {
                voiceCell.VoiceStack.alignment = .leading
                voiceCell.userImage.image = vm.friend_image
            }
            voiceCell.msgVM = message
            return voiceCell
            
            
            
            
            
        } else {
            if message.to == uid {
                let fromCell = tableView.dequeueReusableCell(withIdentifier: "FromCell", for: indexPath) as! FromCell
                fromCell.msgVM = message
                return fromCell
            } else {
                let toCell = tableView.dequeueReusableCell(withIdentifier: "ToCell", for: indexPath) as! ToCell
                toCell.msgVM = message
                toCell.userImage.image = vm.friend_image

                return toCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == vm.countOfCells - 2  {
            vm.fetchMoreMessages(uid: uid)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        vm.pressedCell(at: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatingToAbout" {
            let vc = segue.destination as! AboutTableViewController
            vc.name = vm.friend?.name
            vc.uid = vm.friend?.uid
        }
    }
    
}






// MARK:- TextView Delegate

extension ChatingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.starts(with: " ") {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
        textView.isScrollEnabled = false
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let height = textView.sizeThatFits(size)
        heightVisualView.constant = CGFloat(height.height) + 20
        heightConstraintOfStack.constant = CGFloat(height.height)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        vm.startTyping(friendID: uid)
        UIView.animate(withDuration: 0.2) {
            self.actionsStack.isHidden = true
        }
        textView.text = ""
        checkDarkMode()
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        vm.endTyping(friendID: uid)
        UIView.animate(withDuration: 0.2) {
            self.actionsStack.isHidden = false
        }
        
        textView.text = "Aa"
        textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        textView.sizeToFit()
        heightVisualView.constant = heightOfBottomView + 5
        heightConstraintOfStack.constant = 33
        self.view.layoutIfNeeded()
    }
    
    private func checkDarkMode() {
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                textView.textColor = .white
            } else {
                textView.textColor = .darkText
            }
        }
    }
    
}
