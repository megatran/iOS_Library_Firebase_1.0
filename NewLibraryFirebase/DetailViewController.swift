//
//  DetailViewController.swift
//  NewLibraryFirebase
//
//  Created by megatran on 11/28/16.
//  Copyright © 2016 Colorado School of Mines. All rights reserved.
//

import UIKit
import Firebase

class DetailViewController: UIViewController {
    
    var book: Book?
    var viewTitleLabelString = ""

        // True if action should be to add a new book; false for update.
    var isAddAction: Bool?
    
    @IBOutlet weak var viewTitleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UITextField!
    @IBOutlet weak var bookTitleLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bookTitleLabel.text = book?.title
        authorLabel.text = book?.author
        yearLabel.text = book?.year
        viewTitleLabel.text = viewTitleLabelString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSaveButtonPressed(_ sender: Any) {
        if let book = book {
            book.author = authorLabel.text!
            book.title = bookTitleLabel.text!
            book.year = yearLabel.text!
            if let isAdd = isAddAction {
                if isAdd {
                    addBook(book)
                } else {
                    updateBook(book)
                }
            }
        }
        self.navigationController!.popViewController(animated: true)

    }

    @IBAction func onDeleteButtonPressed(_ sender: Any) {
        removeBook(book!.id)
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func textEditingDone(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // Database functions to add, delete, and update.
    func addBook(_ book: Book) {
        // Always start with the top level node.
        let ref = FIRDatabase.database().reference()
        ref.child(K.bookKey).child(book.id).setValue(
            [K.titleKey: book.title,
             K.authorKey: book.author,
             K.yearKey: book.year]
        )
    }
    
    func removeBook(_ id: String) {
        // Always start with the top level node.
        let ref = FIRDatabase.database().reference()
        ref.child(K.bookKey).child(id).removeValue()
    }
    
    func updateBook(_ book: Book) {
        // Always start with the top level node.
        let ref = FIRDatabase.database().reference()
        ref.child(K.bookKey).child(book.id).updateChildValues(
            [K.titleKey: book.title,
             K.authorKey: book.author,
             K.yearKey: book.year]
        )
    }
    
    @IBAction func onTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        
        authorLabel.resignFirstResponder()
        yearLabel.resignFirstResponder()
        bookTitleLabel.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
