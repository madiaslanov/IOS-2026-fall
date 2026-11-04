//
//  ViewController.swift
//  FavoritesList
//
//  Created by madiaslanov on 04.11.2026.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        favoriteCars.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteCell",
            for: indexPath
        ) as! FavoriteCell

        cell.configure(with: favoriteCars[indexPath.row])
        return cell
    }
}
