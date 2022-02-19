//
//  HomeInfoView.swift
//  HacDump
//
//  Created by Andrew McDonnell on 18/2/2022.
//

import HomeKit

class HomeInfoViewController: UITableViewController {
    weak var selectedHome: HMHome?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = selectedHome?.name
    }

    // Todo: split this up into sections
    // Todo: learn about dictionaries etc
    // Section 1 is the key value stuff
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Home", for: indexPath)
        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "Home = \(selectedHome?.name ?? "unknown")"
            break
        case 1:
            cell.textLabel?.text = "Primary = \(selectedHome?.isPrimary ?? false ? "yes" : "no")"
            break
        case 2:
            cell.textLabel?.text = "UUID = \(selectedHome?.uniqueIdentifier.uuidString ?? "unknown")"
            break;
        case 3:
            cell.textLabel?.text = "User = \(selectedHome?.currentUser.name ?? "unknown")"
            break;
        case 4:
            cell.textLabel?.text = "Accessories = \(selectedHome?.accessories.count ?? 0)"
            break;
        case 5:
            cell.textLabel?.text = "Zones = \(selectedHome?.zones.count ?? 0)"
            break;
        case 6:
            cell.textLabel?.text = "ActionSets = \(selectedHome?.actionSets.count ?? 0)"
            break;
        case 7:
            cell.textLabel?.text = "ServiceGroups = \(selectedHome?.serviceGroups.count ?? 0)"
            break;
        case 8:
            cell.textLabel?.text = "Triggers = \(selectedHome?.triggers.count ?? 0)"
            break;
        case 9:
            let homeHubState: String
            if #available(iOS 13.2, *) {
                if selectedHome != nil {
                    homeHubState = "\(selectedHome!.homeHubState.rawValue)"
                } else {
                    homeHubState = "unknown"
                }
            } else {
                homeHubState = "unknown (before iOS 11)"
            }
            cell.textLabel?.text = "HomeHubState = \(homeHubState)"
            break;
        case 10:
            let canHaveRouter: String
            if #available(iOS 13.2, *) {
                canHaveRouter = selectedHome?.supportsAddingNetworkRouter ?? false ? "yes" : "no"
            } else {
                canHaveRouter = "unknown (before iOS 13.2)"
            }
            cell.textLabel?.text = "Can have router = \(canHaveRouter)"
            break;
        default:
            break;
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row != 0) { return }
        selectedHome?.manageUsers(completionHandler: { (err) in
            print(err.debugDescription)
        })
    }
}

