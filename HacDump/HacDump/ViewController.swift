//
//  ViewController.swift
//  HacDump
//
//  Created by Andrew McDonnell on 17/2/2022.
//

import UIKit
import HomeKit

class ViewController: UITableViewController, HMHomeManagerDelegate {
    var homeManager: HMHomeManager!
    var homes: [HMHome]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Home Analyser"

        homeManager = HMHomeManager()
        homeManager.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(askAddNewHome))
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let n: Int = homes?.count  { return n }
        return 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Home", for: indexPath)
        let home: HMHome = self.homes[indexPath.row]
        cell.textLabel?.text = "\(home.name)"
        cell.detailTextLabel?.text = home.isPrimary ? "(Primary)" : ""
        return cell
    }
    @available(iOS 13.0, *)
    func getAuthStatus() -> String? {
        print("HomeManager.authorized ~> \(homeManager.authorizationStatus)")
        print("HMHomeManagerAuthorizationStatus.determined ~> \(HMHomeManagerAuthorizationStatus.determined)")
        print("HMHomeManagerAuthorizationStatus.authorized ~> \(HMHomeManagerAuthorizationStatus.authorized)")
        print("HMHomeManagerAuthorizationStatus.restricted ~> \(HMHomeManagerAuthorizationStatus.restricted)")
        if (homeManager.authorizationStatus.contains(HMHomeManagerAuthorizationStatus.restricted)) {
            return "The app doesn’t have access to home data."
        }
        // The others can be combined(!)
        if (homeManager.authorizationStatus.contains(HMHomeManagerAuthorizationStatus.determined)) {
            return "The user has set the app’s level of access to home data."
        }
        if (homeManager.authorizationStatus.contains(HMHomeManagerAuthorizationStatus.authorized)) {
            return "The app has access to home data."
        }
        return nil;
    }
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        assert(homeManager === manager)
        homes = manager.homes
        if #available(iOS 13.0, *) {
            let authStatus = getAuthStatus()
            NSLog("HomeManager.authorized ~> \(authStatus ?? "unknown")")
        } else {
            NSLog("HomeManager.authorized ~> iOS version too old")
        }
        NSLog("HomeManagerDidUpdateHomes ~> has \(homes.count) homes")
        for home in homes {
            NSLog("Have home ~> \(home)")
        }
        tableView.reloadData()
        if (homes.count == 0) {
            
        }
    }
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        NSLog("homeManagerDidUpdatePrimaryHome ~> has \(manager.homes.count) homes")
        tableView.reloadData()
    }
    func homeManager(_ manager: HMHomeManager, didAdd: HMHome) {
        NSLog("homeManagerDidAdd ~> has \(manager.homes.count) homes")
        tableView.reloadData()
    }
    func homeManager(_ manager: HMHomeManager, didRemove: HMHome) {
        NSLog("homeManagerDidRemove ~> has \(manager.homes.count) homes")
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeInfo") as? HomeInfoViewController {
            vc.selectedHome = homes[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func askAddNewHome() {
        let ac = UIAlertController(title: "Create new home?", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Create", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.makeNewHome(name: answer)
        }
        submitAction.isEnabled = false
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: ac.textFields?[0],
            queue: OperationQueue.main) { (notification) -> Void in
                let tf = ac.textFields?[0].text
                submitAction.isEnabled = !(tf?.isEmpty ?? false) }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(ac, animated: true)
    }
    func makeNewHome(name: String) {
//        let ac = UIAlertController(title: "Create new home:", message: name, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
        homeManager.addHome(withName: name) { home, err in
            if (err == nil) {
                print("Created \(name)")
            } else {
                NSLog(err.debugDescription)
            }
        }
    }
}


