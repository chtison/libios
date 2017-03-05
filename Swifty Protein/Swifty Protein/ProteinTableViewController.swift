//
//  ProteinTableViewController.swift
//  Swifty Protein
//
//  Copyright © 2017 chtison. All rights reserved.
//

import UIKit

class ProteinTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    lazy var ligandsList: [String] = []
    
    func loadLigandsList() {
        if !ligandsList.isEmpty {
            return
        }
        ligandsList = try! String(contentsOf: Bundle.main.url(forResource: "ligands", withExtension: "txt")!).components(separatedBy: "\n")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Logout"
        
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = .done
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ligandsList = []
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        loadLigandsList()
        return ligandsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        loadLigandsList()
        let cell = tableView.dequeueReusableCell(withIdentifier: "Ligand", for: indexPath)
        cell.textLabel!.text = ligandsList[indexPath.row]
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if navigationItem.rightBarButtonItem == nil {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Top", style: .plain, target: self, action: #selector(scrollTop))
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func scrollTop(sender: Any?) {
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
    }

    // MARK: - Search bar delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadLigandsList()
        var indexPath: IndexPath? = nil
        for (i, ligand) in ligandsList.enumerated() {
            if ligand.hasPrefix(searchText) {
                if indexPath == nil {
                    indexPath = IndexPath(row: i, section: 0)
                    break
                }
            }
        }
        if indexPath == nil {
            return
        }
        tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(false)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLigand" {
            let cell = sender as! UITableViewCell
            (segue.destination as! ProteinViewController).ligandId = cell.textLabel?.text!
        }
    }
}
