//
//  Extensions.swift
//  Message Now
//
//  Created by Hazem Tarek on 4/20/20.
//  Copyright © 2020 Hazem Tarek. All rights reserved.
//

import UIKit
import Kingfisher

extension UITableView {
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
        
        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}

extension UIImageView {
    func load(url: String) {
        DispatchQueue.global().async { [weak self] in
            if let Url = URL(string: url) {
                if let data = try? Data(contentsOf: Url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    }
    
    func KFloadImage(url: String){
        let url = URL(string: url)
        self.kf.setImage(with: url, placeholder: nil, options: [.transition(ImageTransition.fade(0.2))], progressBlock: .none)
        
    }
    
    func KFload(url: String, complation: @escaping(UIImage)->()){
        let url = URL(string: url)
        self.kf.setImage(with: url, placeholder: nil, options: [.transition(ImageTransition.fade(0.2))], progressBlock: .none) { (result) in
            switch result {
                case.success(let data):
                    complation(data.image)
                case .failure(_):
                print("error")
            }
        }
    }
    
}





extension Double {
    
    func getDays() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        //Day
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "EEE"
        let day = formatterDay.string(from: date)
        
        //Month
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "dd MMM"
        let month = formatterDate.string(from: date)
        
        
        // min, hours, days
        let currentDate = Date()
        let components = Set<Calendar.Component>([.day, .minute, .hour])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: currentDate)
        
        
        if differenceOfDate.day! <= 2 {
            if differenceOfDate.day! < 1 {
                if differenceOfDate.hour! < 1 {
                    if differenceOfDate.minute! < 2 {
                        return "Just now"
                    } else {
                        return "\(differenceOfDate.minute!)m" }
                } else {
                    return "\(differenceOfDate.hour!)h" }
            } else { return "\(differenceOfDate.day!)d" }
        } else if differenceOfDate.day! > 2 && differenceOfDate.day! <= 7 {
            return "\(day)"
        } else {
            return "\(month)"
        }
    }
    
    func getMessageTime() -> String {
        let date = Date(timeIntervalSince1970: self)
        //Time
        let formatterTime = DateFormatter()
        formatterTime.timeStyle = .short
        let time = formatterTime.string(from: date)
        
        //Month
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "dd MMM h:mm"
        let month = formatterDate.string(from: date)
        
        // min, hours, days
        let currentDate = Date()
        let components = Set<Calendar.Component>([.day])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: currentDate)
        
        if differenceOfDate.day! < 1 {
            return "\(time)"
        } else {
            return "\(month)"
        }
    }
    
}
