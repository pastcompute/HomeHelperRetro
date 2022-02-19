//
//  RoomInfoViewController.swift
//  HacDump
//
//  Created by Andrew McDonnell on 19/2/2022.
//

import HomeKit

class RoomInfoViewController: UITableViewController {
   weak var selectedHome: HMHome?
   
   override func viewDidLoad() {
       super.viewDidLoad()
       // Do any additional setup after loading the view.
       title = "Rooms of \(selectedHome?.name ?? "unknown")"
       navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(askAddNewRoom))
   }
    @objc func askAddNewRoom() {
        let ac = UIAlertController(title: "Create new room?", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "Create", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.makeNewRoom(name: answer)
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
    func makeNewRoom(name: String) {
        selectedHome?.addRoom(withName: name) { home, err in
            if (err == nil) {
                print("Created \(name)")
            } else {
                NSLog(err.debugDescription)
            }
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedHome?.rooms.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room", for: indexPath)
        if let room: HMRoom = (selectedHome?.rooms[indexPath.row]) {
            cell.textLabel?.text = "\(room.name)"
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else {
            cell.textLabel?.text = "<error>"
        }
        return cell
    }

}
