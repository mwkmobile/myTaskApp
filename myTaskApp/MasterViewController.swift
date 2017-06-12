//
//  MasterViewController.swift
//  myTaskApp
//
//  Created by Michael Koenig on 6/10/17.
//  Copyright © 2017 Michael Koenig. All rights reserved.
//


import UIKit
import CoreData

class MasterViewController: UIViewController, UITableViewDelegate {
  
  @IBOutlet var tableView: UITableView!
  
  var isAuthenticated = false
  
  var managedObjectContext: NSManagedObjectContext!

  var didReturnFromBackground = false
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = editButtonItem
    view.alpha = 0
    
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    
    NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: .UIApplicationWillResignActive, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: .UIApplicationDidBecomeActive, object: nil)
  }
  
  @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {

    isAuthenticated = true
    view.alpha = 1.0
  }
  
  func appWillResignActive(_ notification : Notification) {

    view.alpha = 0
    isAuthenticated = false
    didReturnFromBackground = true
  }
  
  func appDidBecomeActive(_ notification : Notification) {

    if didReturnFromBackground {
      showLoginView()
    }
  }

  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showLoginView()
  }
  
  func showLoginView() {
    
    if !isAuthenticated {
      performSegue(withIdentifier: "loginView", sender: self)
    }
  }
  
  func insertNewObject(_ sender: AnyObject) {
    
    let context = fetchedResultsController.managedObjectContext
    
    guard let entityName = fetchedResultsController.fetchRequest.entity?.name else {
      return
    }

    let newNote = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! Note
    newNote.date = Date()
    newNote.noteText = "New Note"
    
    do {
      try context.save()
    } catch {
      print("Error inserting data \(error)")
    }
  }
  
  // MARK: - Segues
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      
      guard let indexPath = tableView.indexPathForSelectedRow else {
        return
      }
      
      let note = fetchedResultsController.object(at: indexPath)
      (segue.destination as! DetailViewController).note = note
    }
  }
  
  // MARK: - Table View
  
  
  @IBAction func logoutAction(_ sender: AnyObject) {
    isAuthenticated = false
    performSegue(withIdentifier: "loginView", sender: self)
  }
  
  // MARK: - Fetched results controller
    
  lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
    
    let fetchRequest = Note.fetchRequest() as! NSFetchRequest<Note>
    fetchRequest.fetchBatchSize = 20
    
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
    fetchedResultsController.delegate = self
    
    do {
      try fetchedResultsController.performFetch()
    } catch let error {
      print(error)
    }
    
    return fetchedResultsController
  }()
  
}

// MARK: - UITableViewDelegate
extension MasterViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        let note = self.fetchedResultsController.object(at: indexPath)
        configure(cell, with: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch let error1 as NSError {
                print("Error editing the table \(error1)")
                abort()
            }
        }
    }
    
    func configure(_ cell: UITableViewCell, with note: Note) {
        cell.textLabel!.text = note.noteText.description
    }
    
}


extension MasterViewController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections([sectionIndex], with: .fade)
    case .delete:
      tableView.deleteSections([sectionIndex], with: .fade)
    default:
      return
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      
      guard let cell = tableView.cellForRow(at: indexPath!), let note = anObject as? Note else {
        return
      }
      
      configure(cell, with: note)
      
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    }
  }
  
}
