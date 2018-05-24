//
//  UITableView++.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 24/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

extension UITableView {
    
    func registerNib<T>(fromClass class: T.Type) where T: UITableViewCell {
        let name = NSStringFromClass(T.self).components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: name, bundle: nil)
        self.register(nib, forCellReuseIdentifier: name)
    }
    
    func dequeueCell<T>(withClass class: T.Type, forIndexPath indexPath: IndexPath) -> T where T: UITableViewCell {
        let name = NSStringFromClass(T.self).components(separatedBy: ".").last ?? ""
        return self.dequeueReusableCell(withIdentifier: name, for: indexPath) as! T
    }
    
}
