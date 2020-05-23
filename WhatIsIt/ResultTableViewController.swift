//
//  ResultTableViewController.swift
//  WhatIsIt
//
//  Created by Oscar Bennett on 23/05/2020.
//  Copyright © 2020 Oscar Bennett. All rights reserved.
//

import UIKit
import CoreData

class ResultTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var resultArray: [SavedResult]?
    private var resultStringToPass: String?
    private var imageToPass: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)

        if let resultArray = resultArray {
            let substring = resultArray[indexPath.row].resultString?.split(separator: "\n")[0]
            cell.textLabel?.text = String(substring ?? "Previous Result")
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if let resultArray = resultArray {
        resultStringToPass = resultArray[indexPath.row].resultString
            if let imageData = resultArray[indexPath.row].image {
                imageToPass = UIImage(data: imageData, scale: 1.0)
                performSegue(withIdentifier: "goToPreviousResult", sender: self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(resultArray![indexPath.row])
            saveItems()
            resultArray!.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    func loadItems(){
        let request: NSFetchRequest<SavedResult> = SavedResult.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        do {
            resultArray = try context.fetch(request)
        } catch {
            print("Problem fetching data from context, \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPreviousResult" {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.finalResultText = resultStringToPass!
            destinationVC.selectedImage = imageToPass
            destinationVC.oldResult = true
        }
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("Problem saving items, \(error)")
        }
    }
    
    
}
