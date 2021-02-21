//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import SQLite

class HomeViewController: UIViewController {
    
    var drinksConsumed: [Drink]
    var widmarkFactor: Float

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue   // WHERE "name" IS NOT NULL
        getDrinksConsumed()
        
        widmarkFactor = self.getWidmarkFactor(heightMeters: <#T##Float#>, weightKG: <#T##Float#>, age: <#T##Float#>, sex: <#T##Bool#>)
    
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        let cutoff_time = Int64(Date().addingTimeInterval(TimeInterval(-1 * 48 * 60.0 * 60.0)).timeIntervalSince1970) // 48 hours ago
        
        let time_added = Expression<Int64>("time_added")
        let drink = Expression<SQLite.Blob>("drink")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.select(drink)                       // SELECT "drink" FROM "drinks"
                              .filter(time_added >= cutoff_time)   // WHERE time_added >= cutoff time
            
            self.drinksConsumed = try db.prepare(query).map { row in
                return try row.decode()
            }
        } catch {
            NSLog("Query failed.")
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("insertion failed: \(error)")
        }
    }
    
    func calculateWeightKilograms(weightInLbs: Float) -> Float {
        return weightInLbs / 2.205
    }

    func calculateHeightMeters(heightInInches: Float) -> Float {
        return heightInInches / 39.37
    }

    func calculateWeightLbs(weightInKgs: Float) -> Float {
        return weightInKgs * 2.205
    }

    func calculateHeightInches(heightInMeters: Float) -> Float {
        return heightInMeters * 39.37
    }
    
    func truncateSeconds(fromDate: Date) -> Date {
        // Keep things simple by operating in units of minutes
        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate)
        return calendar.date(from: fromDateComponents)! as Date
    }

    func getWidmarkFactor(heightMeters: Float, weightKG: Float, age: Float, sex: Bool) -> Float {
        // Source: Posey et al. 2006. DOI: 10.1385/Forensic Sci. Med. Pathol.:3:1:33, page 35
        if sex {
            return 0.62544 + 0.13664 * heightMeters - weightKG * (0.00189 + 0.002425 / (heightMeters * heightMeters)) + 1 / (weightKG * (0.57986 + 2.54 * heightMeters - 0.02255 * age))
        }
        return 0.50766 + 0.11165 * heightMeters - weightKG * (0.001612 + 0.0031 / (heightMeters * heightMeters)) - 1 / (weightKG * (0.62115 - 3.1665 * heightMeters))
    }
    
    
    func calculateCurrentBAC() -> Float {
        return calculateBAC(atTime: truncateSeconds(fromDate: Date()))
    }
    
    func calculatePeakBAC() -> (Float, Date) {
        var current = truncateSeconds(fromDate: Date())
        var currentBAC = calculateCurrentBAC()
        var oneMinuteLater: Date = current.addingTimeInterval(60.0)
        var laterBAC = calculateBAC(atTime: oneMinuteLater)
        while (laterBAC >= currentBAC && (0 != laterBAC || 0 != currentBAC)) {
            laterBAC = calculateBAC(atTime: oneMinuteLater)
            if laterBAC > currentBAC {
                currentBAC = laterBAC
                current = oneMinuteLater
                oneMinuteLater = current.addingTimeInterval(60.0)
            } else {
                return (currentBAC, current)
            }
        }
    }
    
    func calculateBAC(atTime: Date) -> Float {
        var minutes: Int = (Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: drinksConsumed[0].timeBeganConsumption!), to: atTime)).minute!
        var bac: Float = 0
        while minutes >= 0 {
            bac += increaseBACEveryMinute(untilTime: atTime, minute: minutes)
            bac -= reduceBACEveryMinute(bac: bac)
            minutes -= 1;
        }
        return bac
    }
    
    func calculateBACtoAdd(drink: Drink, time: Int) -> Float {
        let time = Float(time)
        return (pow(2, ((1 - time) / Float(drink.halfLife!))) - pow(2, (time / Float(drink.halfLife!)))) * drink.gramsAlcohol! / (10 * widmarkFactor * weightKG)
    }
    
    func reduceBACEveryMinute(bac: Float) -> Float {
        if bac >= 0.00025 {
            return 0.00025
        } else {
            return bac
        }
    }
    
    func increaseBACEveryMinute(untilTime: Date, minute: Int) -> Float {
        var BACchange: Float = 0;
        let startTime: Date = untilTime.addingTimeInterval(Double(minute) * -1)
        for drink in self.drinksConsumed {
            let timeDiffMinutes: Int = Int(startTime.timeIntervalSince(Date(timeIntervalSince1970: drink.timeBeganConsumption!))) / 60
            
            if (timeDiffMinutes > 0 && Date(timeIntervalSince1970: drink.timeFullyAbsorbed!) >= startTime) {
                BACchange += calculateBACtoAdd(drink: drink, time: timeDiffMinutes)
            }
        }
        return BACchange
    }
        
        
}

