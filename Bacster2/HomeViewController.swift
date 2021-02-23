//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import SQLite

class HomeViewController: UIViewController {
    
    var drinksConsumed: [Drink] = []
    var widmarkFactor: Double?
    var weightKG: Double?
    var age: Double?
    var sex: Double?
    var updateTimer: Timer?
    var db: Connection?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBlue   // WHERE "name" IS NOT NULL
        db = self.create_db()
        
        // widmarkFactor = self.getWidmarkFactor(heightMeters: <#T##Double#>, weightKG: <#T##Double#>, age: <#T##Double#>, sex: <#T##Bool#>)
        
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        let cutoff_time = Int64(Date().addingTimeInterval(TimeInterval(-1 * 48 * 60.0 * 60.0)).timeIntervalSince1970) // 48 hours ago
        
        let timeBeganConsumption = Expression<Int64>("timeBeganConsumption")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.filter(timeBeganConsumption >= cutoff_time)   // WHERE timeAdded >= cutoff time

            for drink in try db.prepare(query) {
                self.drinksConsumed.append(Drink().load(from: drink))
            }
        } catch {
            NSLog("Query failed.")
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("insertion failed: \(error)")
        }
    }
    
    func calculateWeightKilograms(weightInLbs: Double) -> Double {
        return weightInLbs / 2.205
    }

    func calculateHeightMeters(heightInInches: Double) -> Double {
        return heightInInches / 39.37
    }

    func calculateWeightLbs(weightInKgs: Double) -> Double {
        return weightInKgs * 2.205
    }

    func calculateHeightInches(heightInMeters: Double) -> Double {
        return heightInMeters * 39.37
    }
    
    func truncateSeconds(fromDate: Date) -> Date {
        // Keep things simple by operating in units of minutes
        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate)
        return calendar.date(from: fromDateComponents)! as Date
    }

    func getWidmarkFactor(heightMeters: Double, weightKG: Double, age: Double, sex: Bool) -> Double {
        // Source: Posey et al. 2006. DOI: 10.1385/Forensic Sci. Med. Pathol.:3:1:33, page 35
        if sex {
            return 0.62544 + 0.13664 * heightMeters - weightKG * (0.00189 + 0.002425 / (heightMeters * heightMeters)) + 1 / (weightKG * (0.57986 + 2.54 * heightMeters - 0.02255 * age))
        }
        return 0.50766 + 0.11165 * heightMeters - weightKG * (0.001612 + 0.0031 / (heightMeters * heightMeters)) - 1 / (weightKG * (0.62115 - 3.1665 * heightMeters))
    }
    
    
    func calculateCurrentBAC() -> Double {
        return calculateBAC(atTime: truncateSeconds(fromDate: Date()))
    }
    
    func calculatePeakBAC() -> (Double, Date) {
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
        return (-1, Date()) // this line is added to make the program compile
    }
    
    func calculateBAC(atTime: Date) -> Double {
        var minutes: Int = (Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: drinksConsumed[0].timeBeganConsumption!), to: atTime)).minute!
        var bac: Double = 0
        while minutes >= 0 {
            bac += increaseBACEveryMinute(untilTime: atTime, minute: minutes)
            bac -= reduceBACEveryMinute(bac: bac)
            minutes -= 1;
        }
        return bac
    }
    
    func calculateBACtoAdd(drink: Drink, time: Int) -> Double {
        let time = Double(time)
        // return (pow(2, ((1 - time) / Double(drink.halfLife!))) - pow(2, (time / Double(drink.halfLife!)))) * drink.gramsAlcohol! / (10 * widmarkFactor * weightKG)
        return -1.0
    }
    
    func reduceBACEveryMinute(bac: Double) -> Double {
        if bac >= 0.00025 {
            return 0.00025
        } else {
            return bac
        }
    }
    
    func increaseBACEveryMinute(untilTime: Date, minute: Int) -> Double {
        var BACchange: Double = 0;
        let startTime: Date = untilTime.addingTimeInterval(Double(minute) * -1)
        for drink in self.drinksConsumed {
            let timeDiffMinutes: Int = Int(startTime.timeIntervalSince(Date(timeIntervalSince1970: drink.timeBeganConsumption!))) / 60
            
            if (timeDiffMinutes > 0 && Date(timeIntervalSince1970: drink.timeFullyAbsorbed!) >= startTime) {
                BACchange += calculateBACtoAdd(drink: drink, time: timeDiffMinutes)
            }
        }
        return BACchange
    }
    
    func create_db() -> Connection? {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        
        let id = Expression<Int64>("id")
        let timeAdded = Expression<Int64>("timeAdded")
        let gramsAlcohol = Expression<Double>("gramsAlcohol")
        let percentAlcohol = Expression<Double>("percentAlcohol")
        let timeBeganConsumption = Expression<Int64>("timeBeganConsumption")
        let timeFullyAbsorbed = Expression<Int64>("timeFullyAbsorbed")
        let drinkClass = Expression<String>("drinkClass")
        let volumeML = Expression<Int64>("volumeML")
        let drinkUnits = Expression<String?>("drinkUnits")
        let fullLife = Expression<Int64>("fullLife")
        let halfLife = Expression<Int64>("halfLife")
        let beerStrength = Expression<Double?>("beerStrength")
        let beerContainer = Expression<String?>("beerContainer")
        let wineColor = Expression<String?>("wineColor")
        let wineContainer = Expression<String?>("wineContainer")
        let spiritType = Expression<String?>("spiritType")
        let spiritContainer = Expression<String?>("spiritContainer")
        let cordialType = Expression<String?>("cordialType")
        let cocktailType = Expression<String?>("cocktailType")
        let cocktailMultiplier = Expression<Double?>("cocktailMultiplier")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            try db.run(drinks.create(ifNotExists: true) { t in     // CREATE TABLE "drinks" (
                t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(timeAdded, unique: true)
                t.column(gramsAlcohol)
                t.column(percentAlcohol)
                t.column(timeBeganConsumption)
                t.column(timeFullyAbsorbed)
                t.column(drinkClass)
                t.column(volumeML)
                t.column(drinkUnits)
                t.column(fullLife)
                t.column(halfLife)
                t.column(beerStrength)
                t.column(beerContainer)
                t.column(wineColor)
                t.column(wineContainer)
                t.column(spiritType)
                t.column(spiritContainer)
                t.column(cordialType)
                t.column(cocktailType)
                t.column(cocktailMultiplier)
            })
            
            NSLog("Table created successfully at: \(path)")
            return db
        } catch let error {
            NSLog("Table creation failed: \(error)")
            return nil
        }
    }
        
    @objc func update() {
        getDrinksConsumed()
    }
}

