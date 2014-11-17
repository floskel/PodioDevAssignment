//
//  ViewController.swift
//  Podio Dev Test
//
//  Created by Karlo Kristensen on 17/11/14.
//  Copyright (c) 2014 floskel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let CellId = "CellId"
    private var organizations:[Organization] = []
    
    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        
        tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier:self.CellId)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 40
        tableView.sectionHeaderHeight = 30
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Podio Workspaces"

        if navigationController != nil {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: Selector("refreshButtonTapped:"))
            navigationItem.setRightBarButtonItems([refreshButton], animated: true)
        }

        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if PodioApi.sharedInstance.isLoggedIn {
            reloadDataSource()
        } else {
            //present login view
            let loginViewController = LoginViewController()
            presentViewController(loginViewController, animated: false, completion:nil)
        }
    }
    
    //MARK: Convenience
    
    internal func reloadDataSource() {
        PodioApi.sharedInstance.getOrganizations() { success, organizations in
            if success == true {
                self.organizations = organizations
                self.tableView.reloadData()
            }
        }
    }
    
    internal func refreshButtonTapped(button:UIBarButtonItem) {
        organizations = []
        tableView.reloadData()
        reloadDataSource()
    }
    
    //MARK: TableView Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.organizations.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.organizations[section].spaces.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.organizations[section].name
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let space = self.organizations[indexPath.section].spaces[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(CellId, forIndexPath: indexPath) as? UITableViewCell
        
        cell?.textLabel.text = space.name
        return cell!
    }
}

