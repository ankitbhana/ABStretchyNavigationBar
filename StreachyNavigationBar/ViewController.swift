//
//  ViewController.swift
//  StreachyNavigationBar
//
//  Created by Ankit Bhana on 29/05/19.
//  Copyright © 2019 Ankit Bhana. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stretchyNavigationBar: StretchyNavigationBar!
    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stretchyNavigationBar.delegate = self
    }
    
}

extension ViewController: StretchyNavigationBarDelegate {
    
    func scrollViewForBarStretching() -> UIScrollView {
        return tableView
    }
}
