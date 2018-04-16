//
//  ViewController.swift
//  quotesApp
//
//  Created by Stephen Samuelsen on 2/28/18.
//  Copyright © Stephen Samuelsen. All rights reserved.
//

import UIKit
import CoreData






struct quoteDetails: Decodable {
    
    let quote: String
    let author: String
    let date: String
    //let copyright: String
    
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init (json:[String:Any]) throws {
        guard let quote = json["quote"] as? String else {throw SerializationError.missing("missing")}
        guard let author = json["author"] as? String else {throw SerializationError.missing("missing")}
        guard let date = json["date"] as? String else {throw SerializationError.missing("missing")}
        //guard let copyright = json["copyright"] as? String else {throw SerializationError.missing("missing")}
        
        self.quote = quote
        self.author = author
        self.date = date
        //self.copyright = copyright
        
    }
    
    static func getQuote() -> () {
        let quoteURLString = "https://quotes.rest/qod"
        guard let url = URL(string: quoteURLString)  else   //we use gaurd to avoid force unwrapping
        { return }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            var quotesArray:[quoteDetails] = []
            
            if let data = data {
                
                do {
                    
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        
                        if let contents = json["contents"] as? [String:Any] {
                            
                            
                        
                            if let quotes = contents["quotes"] as? [[String:Any]] {
                                for quoteData in quotes {
                                    if let quoteObject = try? quoteDetails(json: quoteData) {
                                        quotesArray.append(quoteObject)
                                        UserDefaults.standard.set(quoteObject.quote, forKey:"quoteOfDay")
                                        UserDefaults.standard.set(quoteObject.author, forKey:"quoteOfDayAuthor")
                                        UserDefaults.standard.set(quoteObject.date, forKey:"quoteOfDayDate")
                                    
                                        
                                    }
                                }
                            }
                            
                            
                            if let copy = contents["copyright"] as? [[String:Any]] {
                                for x in copy {
                                    if let quoteCopyright = try? quoteDetails(json: x) {
                                        //UserDefaults.standard.set(quoteCopyright.copyright, forKey:"quoteOfDayCopyright")
                                    }
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                    
                } catch {
                    print("Error")
                }
                
                
                
                
            }
            }.resume()
        
       
    }
    
    
}












class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var appTitleLabel: UILabel!
    
    @IBOutlet weak var quoteOfTheDay: View!
    @IBOutlet weak var addQuoteButton: SpringButton!
    @IBOutlet weak var qodBox: UILabel!
    @IBOutlet weak var qodAuthor: UILabel!
 
    @IBOutlet weak var qodCopyright: UILabel!
    @IBOutlet weak var addQuoteBox: SpringView!
    @IBOutlet weak var saveQuoteButton: SpringButton!
    @IBOutlet weak var authorName: UITextField!
    @IBOutlet weak var quoteInputBox: UITextView!       //stores users quotes
    
    @IBOutlet weak var quoteTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var refreshQOD: UIButton!
    
    
    
    
    
    
    
    @IBOutlet weak var addQuoteConstraint: NSLayoutConstraint!  //use to slide the quote menu out and in
    
    
    var controller: NSFetchedResultsController<SavedQuote>!   //you are required to start with the entity , which is why I use <SavedQuote>
    
    
    
    private var refreshControl: UIRefreshControl!
    var itemToEdit: SavedQuote?
    
  
    
    @objc
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attemptFetch()      //fetch API data
        quoteDetails.getQuote()         //call the daily quotes API function
        displayDailyQuote()     //display the quote to the app
        
        quoteTableView.delegate = self
        quoteTableView.dataSource = self
        
        
        //self.loadSaveData()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        quoteTableView.addSubview(refreshControl)
        
        
        
        
        

        
        var panGesture = UIPanGestureRecognizer()
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(_:)))
        quoteOfTheDay.isUserInteractionEnabled = true
        quoteOfTheDay.addGestureRecognizer(panGesture)
        
        
        
        
     
      
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundPicture.png")!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunction))
        
        
        
        
        
       
        
        
        
    } //end of viewDidLoad

    
    
  
    
    
    override func viewDidDisappear(_ animated: Bool) {
        resetQuoteOfTheDay()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        var frm: CGRect = quoteOfTheDay.frame
        frm.origin.x = frm.origin.x
        frm.origin.y = frm.origin.y
        frm.size.width = frm.size.width
        frm.size.height = frm.size.height
        quoteOfTheDay.frame = frm
        
        attemptFetch()  //reload the API when opening app
        quoteDetails.getQuote()         //call the daily quotes API function
        displayDailyQuote()     //display the quote to the app
        
        
    }
    
    
    //table view functions
    
    
   
    
    
   
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        
        let translation = sender.translation(in: self.view)
        quoteOfTheDay.center = CGPoint(x: quoteOfTheDay.center.x, y: quoteOfTheDay.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        if ((quoteOfTheDay.center.y) < (height-400)) {
            UIView.animate(withDuration: 1.0, delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           animations: {
                self.quoteOfTheDay.center = CGPoint(x: self.quoteOfTheDay.center.x, y: self.quoteOfTheDay.center.y + 100 )
                        
                })
            
            
            
            
        }
        
        
        if ((quoteOfTheDay.center.y) < (height-50)) {
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           animations: {
                            self.addQuoteButton.center = CGPoint(x:bounds.minX, y: self.addQuoteButton.center.y)
                            UIView.animate(withDuration: 0.5,
                                           delay: 1.0,
                                           usingSpringWithDamping: 1.0,
                                           initialSpringVelocity: 1.0,
                                           animations: {
                                            self.addQuoteButton.center = CGPoint(x:self.view.frame.midX, y: self.addQuoteButton.center.y)
                            })
            })
            
            
            
        }
        
        
  
        
        
    }
    
    
    func resetQuoteOfTheDay() {
        quoteOfTheDay.center = CGPoint(x: quoteOfTheDay.center.x, y: quoteOfTheDay.center.y)
        
    }
    
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        
        
       
            
    
        } //end of the function
    
    
    
    
    
    @objc func closeTapFunction(sender: UITapGestureRecognizer){
        
       
    }
    
    
    
    
    
    
    func displayDailyQuote() {
        
        guard let dailyQuote = UserDefaults.standard.string(forKey:"quoteOfDay") else {return}
        guard let dailyQuoteAuthor = UserDefaults.standard.string(forKey:"quoteOfDayAuthor") else {return}
        guard let dailyQuoteDate = UserDefaults.standard.string(forKey:"quoteOfDayDate") else {return}
        //guard let dailyQuoteCopyright = UserDefaults.standard.string(forKey: "quoteOfDayCopyright") else {return}
        

        
        
       
        qodBox.text = dailyQuote
        qodAuthor.text = dailyQuoteAuthor
        //qodCopyright.text = dailyQuoteCopyright
        
    }
    
    
    
    
    
    
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
   
        
            
    @IBAction func addQuoteButtonPressed(_ sender: Any) {
        
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        
        
        if(self.addQuoteConstraint.constant == bounds.minX + 50){
        
            UIView.animate(withDuration: 0.5, animations: {
                
                self.addQuoteConstraint.constant = bounds.maxX
                
                self.view.layoutIfNeeded()
                
                })
            
            self.addQuoteButton.setTitle("+_+",for: .normal)      //chnages the button to a + sign
            
        
        }else {
            
            
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           animations: {
                            
                            self.addQuoteConstraint.constant = bounds.minX + 50
                            self.view.layoutIfNeeded()
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                
                                //self.addQuoteButton.center = CGPoint(x: bounds.midX, y: self.addQuoteButton.center.y )
                                self.addQuoteButton.bringSubview(toFront: self.addQuoteBox)
                                self.addQuoteButton.setTitle("-_-",for: .normal)
                                
                            })
            })
            
            
            
        } //end of the if statement
        
        
        self.quoteTableView.reloadData()   //refresh the table view when button is pressed
        
        
        addQuoteButton.animation = "pop"
        addQuoteButton.curve = "easeOut"
        addQuoteButton.duration = 1.0
        addQuoteButton.animate()
      
        
        
      
    }//end of button pressed func
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {                //this pops the keyboard back down when return is pressed
        quoteInputBox.resignFirstResponder()
        authorName.resignFirstResponder()
        return true
        
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)                              //hides keyboard when clicking outside of it
    }
    
            
        
        
    @IBAction func saveQuoteButtonPressed(_ sender: Any) {
        
        if let quote = quoteInputBox.text, quoteInputBox.text.isEmpty != true {
            
            if let author = authorName.text, authorName.text?.isEmpty != true {
                
                addData(author: author, quote: quote)
                addQuoteButtonPressed(self)
                quoteInputBox.text = ""
                authorName.text = ""
            }
            else {
                
                saveQuoteButton.animation = "wobble"
                saveQuoteButton.curve = "spring"
                saveQuoteButton.duration = 1.0
                saveQuoteButton.damping = 0.1
                saveQuoteButton.velocity = 0.1
                saveQuoteButton.animate()
                
            }
            
        }
        else {
            
            saveQuoteButton.animation = "wobble"
            saveQuoteButton.curve = "spring"
            saveQuoteButton.duration = 1.0
            saveQuoteButton.damping = 0.1
            saveQuoteButton.velocity = 0.1
            saveQuoteButton.animate()
            
        }
        
        
        
        
        
        
        
        
    }
    
    
    
    
    
    
    //all the core data related functions
    
    
    var selectedIndex = -1
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(selectedIndex == indexPath.row) {
            selectedIndex = -1
        }
        else {
            selectedIndex = indexPath.row
        }
        
        self.quoteTableView.beginUpdates()
        self.quoteTableView.reloadRows(at: [indexPath], with: .automatic)
        self.quoteTableView.endUpdates()
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      
        let cell = quoteTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuoteCellStyle
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
        
     
        
    }//end of cellForRowAt function
    
    
    
    func configureCell(cell: QuoteCellStyle, indexPath: NSIndexPath){
        
        let item = controller.object(at: indexPath as IndexPath)
        cell.configureCell(item: item)
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if let sections = controller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
        
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = controller.sections {
            return sections.count
        }
        
        return 0
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = UIScreen.main.bounds
        
        if(selectedIndex == indexPath.row) {
            return (200)
        }
        else {
            return (height.height)/8
        }
        
        
        
    }
    
    
    
    
    //this function allows the cells to be swiped left to be deleted
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //function to delete cells when swiped
        
        if editingStyle == .delete {
            
            let item = controller.object(at: indexPath as IndexPath)            //here we set the item to equal object at the index path
            
            itemToEdit = item
            
            if itemToEdit != nil {
                context.delete(itemToEdit!)
                ad.saveContext()
            }
            
            _ = navigationController?.popViewController(animated: true)
            
            
        }
        
        
        
        
        
        
        
        
        
        refreshControl.endRefreshing()
        quoteTableView.reloadData()
        
        //self.loadSaveData()
        
    }
    
    
    
    
    func loadItemData() {
        
        
        
        
        
        
    }
    
    
    
    
    
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<SavedQuote> = SavedQuote.fetchRequest()
        let authorSort = NSSortDescriptor(key: "author", ascending: true)
        fetchRequest.sortDescriptors = [authorSort]                             //need to include this for it to not show error
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        
        self.controller = controller
        
        do {
            
            try controller.performFetch()
            
        } catch {
            
            let error = error as NSError
            print(error)
            
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        quoteTableView.beginUpdates()
        
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        quoteTableView.endUpdates()
        
        
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
            
        case.insert:
            if let indexPath = newIndexPath {
                quoteTableView.insertRows(at: [indexPath], with: .fade)
                
            }
            break
        case.delete:
            if let indexPath = indexPath {
                quoteTableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            break
        case.update:
            if let indexPath = indexPath {
                let cell = quoteTableView.cellForRow(at: indexPath) as! QuoteCellStyle
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
                
            }
            break
        case.move:
            if let indexPath = indexPath {
                quoteTableView.deleteRows(at: [indexPath], with: .fade)
                
            }
            if let indexPath = newIndexPath {
                quoteTableView.insertRows(at: [indexPath], with: .fade)
                
            }
            break
            
        }
    }
    
    
    func addData(author: String, quote: String) {          //use this function to pass in new quote to coreData
        
        
        let userQuoteItem = SavedQuote(context: context)
        userQuoteItem.author = author
        userQuoteItem.quote = quote
        
        ad.saveContext()
        
        
        
    }
    
    
    
    
    func deleteAllData(entity: String)          //this function deletes all the core data
    {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entity))
        do {
            try managedContext.execute(DelAllReqVar)
            //self.quoteTableView.reloadData()
        }
        catch {
            print(error)
        }
        
    
    }
   
    
    
    
    
    //refresh tableView
    @objc func refresh(sender:AnyObject) {
        
        attemptFetch()
        self.refreshControl.endRefreshing()
        self.quoteTableView.reloadData()
        
        
    }
    
    
    @IBAction func refreshQODPressed(_ sender: Any) {
        
        
        attemptFetch()
        displayDailyQuote()
        
        
        
        
    }
    
   
    
    
    
    
    
    
    
    
    
    

}//end of class

