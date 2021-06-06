//
//  InterfaceController.swift
//  WatchBACster Extension
//
//  Created by Adam Circle on 6/4/21.
//

import WatchKit
import Foundation


class TableController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    var questionID = "drinkClass"
    var question = questionsDict["drinkClass"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
//    private func loadTableData() {
//        tableView.setNumberOfRows(question?.answers.count ?? 0, withRowType: <#T##String#>)
//    }

}

class RowController: NSObject {
    @IBOutlet var questionLabel: WKInterfaceLabel!
    
}
