//
//  ViewController.swift
//  NewLibraryFirebase
//
//  Created by megatran on 11/28/16.
//  Copyright © 2016 Colorado School of Mines. All rights reserved.
//

import UIKit
import Firebase

// Define some key names that we can use to reference nodes.
struct K {
    static let bookKey = "Book"
    static let titleKey = "Title"
    static let authorKey = "Author"
    static let yearKey = "Year"
}

class ViewController: UITableViewController {

    var books = [Book]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupDBListeners()
        // Create some dummy books for testing.
//        for i in 0...20 {
//            let book = Book()
//            book.author = "Author \(i)"
//            book.title = "title \(i)"
//            book.year = "\(2000+i)"
//            books.append(book)
//        }
//        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    // Returns the table view cell at the desired row and section in the table.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:
            "CellIdentifier", for: indexPath)
        cell.textLabel?.text = books[indexPath.row].title
        cell.detailTextLabel?.text = books[indexPath.row].author
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailViewController
        if segue.identifier == "addSegue" {
            // Create a new book and pass it to the detail view.
            detailVC.book = Book()
            detailVC.isAddAction = true
            detailVC.viewTitleLabelString = "Add book"
        } else if segue.identifier == "editSegue" {
            // Load the existing book into the detail view, for editing.
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            detailVC.book = books[indexPath.row]
            detailVC.viewTitleLabelString = "Edit book"
            detailVC.isAddAction = false
        }
    }
    
    // Setup observers that perform a closure each time a book is added,
    // removed, or changed.
    func setupDBListeners() {
        // Listen for new books added. Also, let’s make sure it
        // returns each book in order by title.
        let ref = FIRDatabase.database().reference()
        ref.child(K.bookKey)
            .queryOrdered(byChild: K.titleKey)
            .observe(.childAdded, with: { (snapshot) in
                let book = self.convertSnapshotToBookObj(snapshot)
                self.books.append(book)
                self.tableView.reloadData()
            })
        // Listen for changes in book data.
        ref.child(K.bookKey)
            .observe(.childChanged, with: { (snapshot) in
                let book = self.convertSnapshotToBookObj(snapshot)
                for i in 0...self.books.count {
                    if self.books[i].id == book.id {
                        self.books[i] = book
                        self.tableView.reloadData()
                        return
                    }
                }
            })
        // Listen for books removed.
        ref.child(K.bookKey)
            .observe(.childRemoved, with: { (snapshot) in
                let book = self.convertSnapshotToBookObj(snapshot)
                for i in 0...self.books.count {
                    if self.books[i].id == book.id {
                        self.books.remove(at: i)
                        self.tableView.reloadData()
                        return
                    }
                }
            })
    }
    
    /**
     Convert a FIRDataSnapshot object to a Book object.
     Parameters: accepts a FIRDataSnapshot that
     contains a single child node of Book
     Returns: a Book object created from the FIRDataSnapshot data
     **/
    func convertSnapshotToBookObj(_ snap: FIRDataSnapshot) -> Book {
        //print(#function)
        let bookValues = snap.value as! [String : AnyObject]
        
        // Pull out the book id. This is the name of the node, not the node content.
        let id = snap.key
        
        // Pull out the other properties. Make sure the key actually exists before using it.
        let author = bookValues[K.authorKey] == nil ? "" : bookValues[K.authorKey]! as! String
        let title = bookValues[K.titleKey] == nil ? "" : bookValues[K.titleKey]! as! String
        let year = bookValues[K.yearKey] == nil ? "" : bookValues[K.yearKey]! as! String
        
        // Return a book object with the properties set.
        let book = Book()
        book.id = id
        book.author = author
        book.title = title
        book.year = year
        return book
    }
}

