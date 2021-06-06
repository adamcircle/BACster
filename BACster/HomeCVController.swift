//
//  ViewController.swift
//  Bacster2
//
//  Created by Adam Circle on 12/2/20.
//

import UIKit
import SQLite
import CoreData

class HomeCVController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var drinksConsumed: [Drink] = []
    var timeLastUpdated: Int64 = 0
    var updateTimer: Timer!
    var db: Connection!
    var profile: UserHealthProfile?
    var stats: BACStats = BACStats()
    let ident = "type1"
    let cell_descs = ["Peak BAC", "Time to Peak BAC", "Time to Zero BAC", "Drinks in the last 48 hours", "Time since sober", "Time since last drink"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.6470588235, green: 0.7294117647, blue: 0.831372549, alpha: 1)
        
        db = self.create_db()
        
        updateTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if self.profile != nil {} else {
            self.profile = UserHealthProfile().load()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("updateDashboard"), object: nil)
        
        collectionView?.register(InfoCell.self, forCellWithReuseIdentifier: ident)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInsetReference = .fromSafeArea
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        collectionView.isScrollEnabled = collectionView.collectionViewLayout.collectionViewContentSize.height > collectionView.frame.size.height - (self.tabBarController?.tabBar.frame.size.height)!
        collectionView.bounces = false
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.insetsLayoutMarginsFromSafeArea = true
        
        self.update()
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
            let lay = collectionViewLayout as! UICollectionViewFlowLayout
            let widthPerItem = collectionView.frame.width / 2 - lay.minimumInteritemSpacing * 2 - 20
            
            return CGSize(width: widthPerItem, height: widthPerItem - 0.09 * UIScreen.main.bounds.width)
            
            //return CGSize(width: (self.view.frame.width / 2) - 20, height: 140)
        }
        return CGSize(width: self.view.frame.width - 100, height: self.view.frame.height / 3 - 0.05 * UIScreen.main.bounds.width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ident, for: indexPath) as! InfoCell
        if indexPath.section == 0 {
            cell.descriptionLabel.text = "Current BAC"
            cell.quantityLabel.font = cell.quantityLabel.font.withSize(60)
        } else {
            cell.descriptionLabel.text = cell_descs[indexPath.item]
        }
        
        switch indexPath.item {
        case 0:
            if indexPath.section == 0 {
                cell.quantityLabel.text = String(format:"%.3f", self.stats.currBAC ?? 0)
            } else {
                // peak bac
                if self.stats.peakBAC == -1 {
                    cell.quantityLabel.text = "Past peak BAC"
                } else if self.stats.peakBAC == -2 {
                    cell.quantityLabel.text = "N/A"
                } else {
                    cell.quantityLabel.text = String(format:"%.3f", self.stats.peakBAC ?? 0)
                }
            }
        case 1:  // time to peak bac
            if self.stats.peakBAC == -1 {
                cell.quantityLabel.text = "N/A"
            } else {
                cell.quantityLabel.text = self.stats.timeToPeak
            }
        case 2:
            cell.quantityLabel.text = self.stats.timeToZero
        case 3:
            cell.quantityLabel.text = String(self.stats.numDrinksInLast48Hours ?? 0)
        case 4:
            cell.quantityLabel.text = self.stats.timeSinceSober
        case 5:
            cell.quantityLabel.text = self.stats.timeSinceLastDrink
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
            return UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
        }
        return UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func loadUHP() -> UserHealthProfile {
        return UserHealthProfile()
    }
    
    func getDrinksConsumed() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        
        let drinks = Table("drinks")
        var cutoff_time = Int64(Date().addingTimeInterval(TimeInterval(-1 * 48 * 60.0 * 60.0)).timeIntervalSince1970) // 48 hours ago
        if cutoff_time < self.timeLastUpdated {
            cutoff_time = self.timeLastUpdated
        }
        
        let timeAdded = Expression<Int64>("timeAdded")
        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            let query = drinks.filter(timeAdded >= cutoff_time)   // WHERE timeAdded >= cutoff time
            self.drinksConsumed = []
            for drink in try db.prepare(query) {
                self.drinksConsumed.append(Drink().load(from: drink))
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            NSLog("constraint failed, drinks not retreived: \(message), in \(String(describing: statement))")
        } catch let error {
            NSLog("drinks not retreived: \(error)")
        }
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
                t.column(id, primaryKey: true)
                t.column(timeAdded, unique: true)
                t.column(gramsAlcohol)
                t.column(percentAlcohol)
                t.column(timeBeganConsumption)
                t.column(timeFullyAbsorbed)
                t.column(drinkClass)
                t.column(volumeML)
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
            
            //NSLog("Table created successfully at: \(path)")
            return db
        } catch let error {
            NSLog("Drink table creation failed: \(error)")
            return nil
        }
    }
        
    @objc func update() {
        self.getDrinksConsumed()
        self.stats.update(drinks: self.drinksConsumed, healthProfile: self.profile!)
        self.collectionView.reloadData()
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
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.6235294118, blue: 1, alpha: 1)
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
        self.layer.borderWidth = 1
        self.layer.borderColor = .init(genericCMYKCyan: 0, magenta: 0, yellow: 0, black: 1, alpha: 1)
        self.backgroundColor = .white
        addSubview(descriptionLabel)
        addSubview(quantityLabel)
        let constraints = [
            quantityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            quantityLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            quantityLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
            quantityLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            descriptionLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
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
        
        
        var targetRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        targetRect.origin.y = (rect.size.height - targetRect.size.height) / 2
        let textToDraw = self.attributedText!
        textToDraw.draw(in: targetRect)
    }
    
//    override func drawText(in rect: CGRect) {
//        var targetRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
//        targetRect.origin.y = rect.size.height - targetRect.size.height / 2
//        super.drawText(in: targetRect)
//    }
}


extension Date
{
    func getElapsedInterval() -> String
    {
        let interval: DateComponents
        if Date().timeIntervalSince1970 > self.timeIntervalSince1970 {
            interval = Calendar.current.dateComponents([.day, .hour, .minute], from: self, to: Date())
        } else if Date().timeIntervalSince1970 < self.timeIntervalSince1970 {
            interval = Calendar.current.dateComponents([.day, .hour, .minute], from: Date(), to: self)
        } else {
            return "0 minutes"
        }
        let daysPassed = interval.day
        
        var returnStr: String = ""
        
        if daysPassed == 0 {
        
            if let hoursPassed = interval.hour,
                   hoursPassed > 0 {
                returnStr += "\(hoursPassed) hour\(hoursPassed == 1 ? "" : "s")\r"
            }
            
            if let minutesPassed = interval.minute,
                   minutesPassed >= 0 {
                returnStr += "\(minutesPassed) minute\(minutesPassed == 1 ? "" : "s")"
            }
        } else {
            if let daysPassed = interval.day,
                   daysPassed > 0 {
                returnStr += "\(daysPassed) day\(daysPassed == 1 ? "" : "s")\r"
            }
            
            if let hoursPassed = interval.hour,
                   hoursPassed > 0 {
             returnStr += "\(hoursPassed) hour\(hoursPassed == 1 ? "" : "s")"
            }
        }
        
        return returnStr
    }
}

class BACStats {
    var currBAC: Double!
    var peakBAC: Double!
    var timeToPeak: String!
    var timeToZero: String!
    var numDrinksInLast48Hours: Int!
    var timeSinceSober: String!
    var timeSinceLastDrink: String!
    var drinksConsumed: [Drink]!
    var profile: UserHealthProfile!
    
    func update(drinks: [Drink], healthProfile: UserHealthProfile) {
        
        drinksConsumed = drinks
        profile = healthProfile
        currBAC = calculateCurrentBAC()
        let result = calculatePeakBAC()
        peakBAC = result.peakBac
        timeToPeak = result.atTime
        timeToZero = getZeroTime()
        numDrinksInLast48Hours = drinksConsumed.count
        timeSinceSober = getTimeSinceSober()
        timeSinceLastDrink = getTimeSinceLastDrink()
    }
    
    func calculateCurrentBAC() -> Double {
        return calculateBAC(at: truncateSeconds(fromDate: Date()))
    }
    
    func calculatePeakBAC() -> (peakBac: Double, atTime: String) {
        var current_time = truncateSeconds(fromDate: Date())
        var currentBAC = calculateCurrentBAC()
        var oneMinuteLater: Date = current_time.addingTimeInterval(60.0)
        var laterBAC = calculateBAC(at: oneMinuteLater)
        if laterBAC == 0 || currentBAC == 0 {
            return (-2, "N/A")
        }
        if laterBAC < currentBAC {
            return (-1, "Past peak BAC")
        }
        
        while (laterBAC >= currentBAC && (0 != laterBAC || 0 != currentBAC)) {
            currentBAC = laterBAC
            current_time = oneMinuteLater
            oneMinuteLater = current_time.addingTimeInterval(60.0)
            laterBAC = calculateBAC(at: oneMinuteLater)
        }
        // NSLog("peakbac: \(currentBAC), \(current_time.getElapsedInterval())")
        return (currentBAC, current_time.getElapsedInterval())
        
    }
    
    func calculateBAC(at time: Date) -> Double {
        if drinksConsumed.count == 0 {
            return 0.0
        }
        
        
        var minutes: Int = (Calendar.current.dateComponents([.minute], from: Date(timeIntervalSince1970: drinksConsumed[0].timeBeganConsumption!), to: time)).minute!
        var bac: Double = 0
        while minutes >= 0 {
            bac += increaseBACEveryMinute(untilTime: time, minute: minutes)
            //NSLog("Bac after increase: \(bac)")
            bac -= reduceBACEveryMinute(bac: bac)
            //NSLog("Bac after decrease: \(bac), \(minutes)")
            minutes -= 1;
        }
        return bac
    }
    
    func truncateSeconds(fromDate: Date) -> Date {
        // Keep things simple by operating in units of minutes
        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate)
        return calendar.date(from: fromDateComponents)! as Date
    }
    
    func calcBACtoAdd(drink: Drink, time: Int) -> Double {
        return
            (calculatePercentAlcoholAbsorbedByMinute(time: Int(time), halfLife: Int(drink.halfLife!)) -
            calculatePercentAlcoholAbsorbedByMinute(time: Int(time) - 1, halfLife: Int(drink.halfLife!))) *
            drink.gramsAlcohol! /
            (self.profile.widmarkFactor! * self.profile.weightInKilograms! * 1000) * 100
    }
    
    func calculatePercentAlcoholAbsorbedByMinute(time: Int, halfLife: Int) -> Double {
        if time >= 0 {
            //NSLog("alc abs by min: \(Double(100 - (100 / pow(2, Double(time) / Double(halfLife)))) / 100)")
            return Double(100 - (100 / pow(2, Double(time) / Double(halfLife)))) / 100
        } else {
            return 0
        }
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
        let startTime: Date = untilTime.addingTimeInterval(Double(minute) * 60 * -1) // pretty sure this should be * 60
        for drink in self.drinksConsumed {
            let timeDiffMinutes: Int = Int(startTime.timeIntervalSince(Date(timeIntervalSince1970: drink.timeBeganConsumption!))) / 60
            
            if (timeDiffMinutes > 0 && Date(timeIntervalSince1970: drink.timeFullyAbsorbed!) >= startTime) {
                BACchange += calcBACtoAdd(drink: drink, time: timeDiffMinutes)
            }
        }
        return BACchange
    }
    
    func getZeroTime() -> String {
        if drinksConsumed.count == 0 || calculateCurrentBAC() == 0.0 {
            return "You're sober!"
        }
        
        let now = truncateSeconds(fromDate: Date())
        let timeLastDrink = drinksConsumed.last!.timeBeganConsumption + 60
        var time = timeLastDrink
        var BAC = calculateBAC(at: Date(timeIntervalSince1970: time))
        let timeMaxAbsorbed = getTimeMaxAbsorbed()
        while BAC > 0 {
            if time > timeMaxAbsorbed {
                BAC -= 25e-5
                time += 60
            } else {
                BAC = calculateBAC(at: Date(timeIntervalSince1970: timeMaxAbsorbed))
                time = timeMaxAbsorbed + 60
            }
        }
        return Date().addingTimeInterval(time - now.timeIntervalSince1970).getElapsedInterval()
    }
    
//    func getTimeToZero() -> String {
//        if drinksConsumed.count == 0 || calculateCurrentBAC() == 0.0 {
//            return "You're sober!"
//        }
//
//        let now = drinksConsumed.last!.timeBeganConsumption + 60
//        var prevBAC = calculateBAC(at: Date(timeIntervalSince1970: now))
//        var currBAC = calculateBAC(at: Date(timeIntervalSince1970: now + 60))
//        var minutes = 1
//        while prevBAC - currBAC > 25e-5 {
//            prevBAC = currBAC
//            currBAC = calculateBAC(at: Date(timeIntervalSince1970: now + 60.0 * Double(minutes)))
//            minutes += 1
//        }
//        let total_mins = (currBAC / 25e-5) + Double(minutes)
//        return Date().addingTimeInterval(total_mins * 60.0).getElapsedInterval()
//    }
    
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
            return "N/A"
        }
        let timeOfLastDrink = Date(timeIntervalSince1970: (self.drinksConsumed.last?.timeBeganConsumption!)!)
  
        return timeOfLastDrink.getElapsedInterval()
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
    
}
