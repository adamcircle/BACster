//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import SQLite

class HomeCVController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var drinksConsumed: [Drink] = []
    var timeLastUpdated: Int64 = 0
    var updateTimer: Timer!
    var db: Connection!
    var profile: UserHealthProfile!
    let ident = "ident"
    let cell_descs = ["Peak BAC", "Time to Peak BAC", "Time to Zero BAC", "Drinks in the last 24 hours", "Time since sober", "Time since last drink"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = .systemBlue   // WHERE "name" IS NOT NULL
        db = self.create_db()
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        collectionView?.register(InfoCell.self, forCellWithReuseIdentifier: ident)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return cell_descs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1 {
            return CGSize(width: self.view.frame.width / 2.2, height: 140)
        }
        return CGSize(width: self.view.frame.width - 100, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ident, for: indexPath) as! InfoCell
        if indexPath.section == 0 {
            cell.descriptionLabel.text = "Current BAC"
        } else {
            cell.descriptionLabel.text = cell_descs[indexPath.item]
        }
        
        switch indexPath.item {
        case 0:
            if indexPath.section == 0 {
                cell.quantityLabel.text = String(self.calculateCurrentBAC())
            } else {
                // peak bac
                //cell.quantityLabel.text = self.calculatePeakBAC()
            }
        case 1:  // time to peak bac
            cell.quantityLabel.text = "peakbac"
        case 2:
            cell.quantityLabel.text = self.getTimeToZero()
        case 3:
            cell.quantityLabel.text = String(self.drinksConsumed.count)
        case 4:
            cell.quantityLabel.text = self.getTimeSinceSober()
        case 5:
            cell.quantityLabel.text = self.getTimeSinceLastDrink()
        default:
            cell.quantityLabel.text = "Test qty"
        }
        
        if indexPath.section == 1 {
            cell.quantityLabel.font = cell.quantityLabel.font.withSize(25)
            cell.descriptionLabel.font = cell.descriptionLabel.font.withSize(15)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        return UIEdgeInsets()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func getTimeToZero() -> String {
        if drinksConsumed.count == 0 || calculateCurrentBAC() == 0.0 {
            return "You're sober!"
        }
        // let e = setDateObjectSecondsAndMillisecondsToZero(new Date(getTimeOfLastDrinkAsDateObject().getTime() + 6e4))
        var now: Double = truncateSeconds(fromDate: Date()).timeIntervalSince1970
        if now == drinksConsumed[-1].timeBeganConsumption {
            now += 60
        }
        
        let BACNow = calculateBAC(atTime: Date(timeIntervalSince1970: now))
        let timeMaxAbsorbed = getTimeMaxAbsorbed();
        //    for (; t > 0; )
        //        t = (e = setDateObjectSecondsAndMillisecondsToZero(new Date(e.getTime() + 6e4))) > o ? t - 25e-5 : calculateBAC(e);
        //    return timeZero
    }
    
    func getTimeMaxAbsorbed() -> Double {
        var timeFullyAbsorbed = 0.0
        for drink in self.drinksConsumed {
            timeFullyAbsorbed = max(timeFullyAbsorbed, drink.timeFullyAbsorbed!)
        }
        return timeFullyAbsorbed
    }
    
    func getTimeSinceSober() -> String {
        if self.drinksConsumed.count == 0 {
            return "You're sober!"
        }
        let timeOfFirstDrink = Date(timeIntervalSince1970: self.drinksConsumed[0].timeBeganConsumption!)
  
        return timeOfFirstDrink.getElapsedInterval()
    }
    
    func getTimeSinceLastDrink() -> String {
        if self.drinksConsumed.count == 0 {
            return "You're still sober!"
        }
        let timeOfLastDrink = Date(timeIntervalSince1970: self.drinksConsumed[-1].timeBeganConsumption!)
  
        return timeOfLastDrink.getElapsedInterval()
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        var cutoff_time = Int64(Date().addingTimeInterval(TimeInterval(-1 * 24 * 60.0 * 60.0)).timeIntervalSince1970) // 24 hours ago
        if cutoff_time < self.timeLastUpdated {
            cutoff_time = self.timeLastUpdated
        }
        
        let timeBeganConsumption = Expression<Int64>("timeBeganConsumption")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.filter(timeBeganConsumption >= cutoff_time)   // WHERE timeAdded >= cutoff time
            self.drinksConsumed = []
            for drink in try db.prepare(query) {
                self.drinksConsumed.append(Drink().load(from: drink))
            }
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
        if drinksConsumed.count == 0 {
            return 0.0
        }
        
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
        let part1: Double = (pow(2.0, (1.0 - Double(time)) / Double(drink.halfLife!)) - pow(2.0, Double(time) / Double(drink.halfLife!)))
        let part2: Double = drink.gramsAlcohol! / (10.0 * self.profile.widmarkFactor! * self.profile.weightInKilograms!)
        return part1 * part2
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
        let startTime: Date = untilTime.addingTimeInterval(Double(minute) * -1) // pretty sure this should be * 60
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
        let timeAdded = Expression<Double>("timeAdded")
        let gramsAlcohol = Expression<Double>("gramsAlcohol")
        let percentAlcohol = Expression<Double>("percentAlcohol")
        let timeBeganConsumption = Expression<Double>("timeBeganConsumption")
        let timeFullyAbsorbed = Expression<Double>("timeFullyAbsorbed")
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
        self.getDrinksConsumed()
        self.collectionView.reloadData()
        if drinksConsumed.count > 0 {
            for drink in drinksConsumed {
                NSLog("rowid: \(String(describing: drink.rowID))")
            }
        }
    }
}

class InfoCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var descriptionLabel: RoundedUILabel = {
        let label = RoundedUILabel()
        label.text = "test DESC"
        label.textAlignment = .center
        label.font = label.font.withSize(20)
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var quantityLabel: UILabel = {
        let label = UILabel()
        // label.text = "test QTY"
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = label.font.withSize(60)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setup() {
        self.layer.cornerRadius = 15
        self.backgroundColor = .white
        addSubview(descriptionLabel)
        addSubview(quantityLabel)
        let constraints = [
            quantityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            quantityLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            quantityLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            quantityLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descriptionLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

class RoundedUILabel: UILabel {
    
    var radius: Int = 15
    var borderColor: UIColor = .black
    var topLeft: Bool = false
    var topRight: Bool = false
    var bottomRight: Bool = true
    var bottomLeft: Bool = true
    
    override func draw(_ rect: CGRect) {
        var corners : UIRectCorner = []
        if topLeft { corners.insert(.topLeft) }
        if topRight { corners.insert(.topRight) }
        if bottomRight { corners.insert(.bottomRight) }
        if bottomLeft { corners.insert(.bottomLeft) }

        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer

        self.backgroundColor?.setFill()
        path.fill()
        borderColor.setStroke()
        path.stroke()
        let textToDraw = self.attributedText!
        textToDraw.draw(in: rect)
    }
}


extension Date
{
    func getElapsedInterval() -> String
    {
        let interval = Calendar.current.dateComponents([.hour, .minute], from: self, to: Date())
        
        var returnStr: String = ""
        
        if let hoursPassed = interval.hour,
               hoursPassed > 0 {
            returnStr += "\(hoursPassed) hour\(hoursPassed == 1 ? "" : "s")"
        }
        
        if let minutesPassed = interval.minute,
               minutesPassed > 0 {
            returnStr += "\r\(minutesPassed) minute\(minutesPassed == 1 ? "" : "s")"
        }
        
        return returnStr
    }
}
