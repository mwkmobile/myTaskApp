//
//  DetailViewController.swift
//  myTaskApp
//
//  Created by Michael Koenig on 6/10/17.
//  Copyright © 2017 Michael Koenig. All rights reserved.
//


import UIKit
import CoreData

class DetailViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var detailTextView: UITextView!
  
  var note: Note?
  
  func configureView() {
    
    guard let note = note else {
      return
    }
    
    detailTextView?.text = note.noteText
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
}

// MARK: - UITextFieldDelegate
extension DetailViewController: UITextFieldDelegate {
  
  func textViewDidEndEditing( _ textView: UITextView) {
    
    guard let note = note else {
      return
    }
    
    note.noteText = detailTextView.text
    
    do {
      try note.managedObjectContext?.save()
    } catch {
      print("nothing saved.")
    }
  }
  
}

