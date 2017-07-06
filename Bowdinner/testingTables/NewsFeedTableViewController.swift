//
//  NewsFeedTableViewController.swift
//  testingTables
//
//  Created by Sophia M. Ardell on 5/1/16.
//  Copyright © 2016 Sophia M. Ardell. All rights reserved.
//

import UIKit

protocol MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?)
}

class NewsFeedTableViewController: UITableViewController, OtherProfileDataSource {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var userID: Int = -1
    
    let userDataModel = allUserDataModel()
    
    var statusArray = [userModel]()
    var users = [String: userModel]()
    
    let interactor = Interact()
    
    @IBAction func openMenu(sender: AnyObject) {
        performSegueWithIdentifier("openMenu", sender: nil)
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translationInView(view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegueWithIdentifier("openMenu", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationViewController = segue.destinationViewController as? NewMenuViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
        }
        
        else {
            
            var destination = segue.destinationViewController
            if let navCon = destination as? UINavigationController {
                destination = navCon.visibleViewController!
            }
            
            if let hvc = destination as? OtherProfileViewController {
                
                if let identifier = segue.identifier{
                    
                    if identifier == "ShowOtherProfileSegue" {
                        let seletectedIndexPath = tableView.indexPathForCell(sender as! NewsFeedTableViewCell)
                        let currentCell = tableView.cellForRowAtIndexPath((seletectedIndexPath)!) as? NewsFeedTableViewCell
                        hvc.dataSource = self
                        hvc.nameString = currentCell?.personName
                        
                    }
                    
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userAnyObject = defaults.objectForKey("userID")!
        self.userID = (userAnyObject as! NSNumber) as Int
        self.statusArray = userDataModel.downloadData(self.userID)
    }
    
    //checks if user has friend with specific name
    func profileInfo(name: [String]) -> userModel? {
        for i in 0...statusArray.count-1 {
            if statusArray[i].firstName == name[0] && statusArray[i].lastName == name[1] {
                //if name is found, return profile information
                return statusArray[i]
            }
        }
        
        return nil
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        self.statusArray = userDataModel.downloadData(self.userID)
        self.tableView.reloadData()
        sender.endRefreshing()
    }
    
    var signedIn: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        
        print("view did appear")
        
        let userAnyObject = defaults.objectForKey("userID")!
        
        self.userID = (userAnyObject as! NSNumber) as Int
        
        if (userID == -1) {
            self.performSegueWithIdentifier("goToLogin", sender: self)
        }
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("in table view")
        
        if (userID != -1) {
            
            print("not -1")
        
            // Configure the cell...
            let individual = statusArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! NewsFeedTableViewCell
            
            //cell.statusInformation = [individual[0], individual[1], individual[2], individual[3]]
            
            cell.personName = [individual.firstName!, individual.lastName!]
            
            cell.userName.text = "\(individual.firstName!) \(individual.lastName!)"
            
            if individual.status1 == 0 {
                cell.userAvailability.text = "Unavailable"
                cell.userLocation.text = " "
                cell.userTime.text = " "
            } else {
                cell.userAvailability.text = "Available"
                cell.userLocation.text = "\(individual.place1!)"
                cell.userTime.text = "\(individual.time1!)"
            }
            
            cell.userName.adjustsFontSizeToFitWidth = true
            cell.userAvailability.adjustsFontSizeToFitWidth = true
            cell.userTime.adjustsFontSizeToFitWidth = true
            cell.userLocation.adjustsFontSizeToFitWidth = true
            
            return cell
            
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! NewsFeedTableViewCell
        return cell
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var destination = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController!
        }
       
        if let hvc = destination as? OtherProfileViewController {
        
            if let identifier = segue.identifier{
            
                if identifier == "ShowOtherProfileSegue" {
                    let seletectedIndexPath = tableView.indexPathForCell(sender as! NewsFeedTableViewCell)
                    let currentCell = tableView.cellForRowAtIndexPath((seletectedIndexPath)!) as? NewsFeedTableViewCell
                    hvc.dataSource = self
                    hvc.nameString = currentCell?.personName
  
                }
        
            }
        }
    } */
    

}








extension NewsFeedTableViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

extension NewsFeedTableViewController : MenuActionDelegate {
    func openSegue(segueName: String, sender: AnyObject?) {
        dismissViewControllerAnimated(true){
            self.performSegueWithIdentifier(segueName, sender: sender)
        }
    }
}
