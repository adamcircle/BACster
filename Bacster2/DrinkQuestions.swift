//
//  DrinkQuestions.swift
//  Bacster2
//
//  Created by Adam Circle on 2/12/21.
//

import Foundation
import UIKit

class Drink {
    var gramsAlcohol: Float?
    var percentAlcohol: Float?
    public var timeBeganConsumption: Date?
    public var timeAdded: Date?
    public var timeFullyAbsorbed: Date?
    var drinkClass: String?
    var volumeML: Int?
    var drinkUnits: String?
    var fullLife: Int?
    var halfLife: Int?
    
    // Beer Specific Data
    var beerStrength: Float?  // lo: .027, med: .035, full: .048, dub: .0675, trip: .085, quad: .115
    var sipOrShotgun: String?
    var beerContainer: String?
    
    // Wine Specific Data
    var wineColor: String?
    var wineContainer: String?
    
    // Spirit Specific Data
    var spiritType: String?
    var spiritContainer: String?
    var cordialType: String?
    
    // Cocktail Specific Data
    var cocktailType: String?
    var cocktailMultiplier: Float?
    
    
    private func computeGramsAlcohol() {
        var percentAlcohol: Float = 0
        var volumeML: Int = 0
        switch drinkClass {
        case "Beer":
            switch beerContainer {
            case "Full Solo Cup":
                volumeML = 355
            case "Half Solo Cup":
                volumeML = 178
            case "Standard Can/Bottle (12oz)":
                volumeML = 355
            case "Double Can/Bottle (24oz)":
                volumeML = 355 * 2
            case "Pint":
                volumeML = 473
            case "Half Pint":
                volumeML = 237
            default:
                NSLog("Invalid beer container.")
            }
            percentAlcohol = beerStrength!
        case "Wine":
            switch wineContainer {
            case "Glass":
                volumeML = 148
            case "Flute":
                volumeML = 177
            case "Half bottle":
                volumeML = 375
            case "Bottle":
                volumeML = 750
            case "Full Solo Cup":
                volumeML = 355
            case "Half Solo Cup":
                volumeML = 178
            default:
                NSLog("Invalid wine container.")
            }
            
            switch wineColor {
            case "Red":
                percentAlcohol = 0.135
            case "White":
                percentAlcohol = 0.10
            case "Champagne":
                percentAlcohol = 0.12
            default: // Champagne
                NSLog("Invalid wine color.")
            }
        case "Spirits":
            switch spiritContainer {
            case "Standard shot (1oz)":
                volumeML = 30
            case "Tall shot (1.5oz)":
                volumeML = 45
            case "Double shot (2oz)":
                volumeML = 60
            case "Quarter Solo Cup":
                volumeML = 89
            case "Half Solo Cup":
                volumeML = 178
            case "Glencairn":
                volumeML = 50
            case "Tokkuri (small flask)":
                volumeML = 360
            case "Masu (wooden box)":
                volumeML = 180
            case "2-go":
                volumeML = 180 * 2
            case "3-go":
                volumeML = 180 * 3
            case "4-go":
                volumeML = 180 * 4
            default:
                NSLog("Invalid spirit container.")
            }
            
            switch spiritType {
            case "Vodka":
                percentAlcohol = 0.4
            case "Rum":
                percentAlcohol = 0.4
            case "Tequila":
                percentAlcohol = 0.4
            case "Gin":
                percentAlcohol = 0.4
            case "Whiskey":
                percentAlcohol = 0.4
            case "Sake":
                percentAlcohol = 0.15
            case "Cordials":
                switch cordialType {
                case "Disaronno":
                    percentAlcohol = 0.28
                case "Baileys":
                    percentAlcohol = 0.17
                case "Jägermeister":
                    percentAlcohol = 0.35
                case "Kahlúa":
                    percentAlcohol = 0.2
                case "Schnapps":
                    percentAlcohol = 0.15
                case "Amarula":
                    percentAlcohol = 0.17
                case "Pavan":
                    percentAlcohol = 0.18
                case "Licor 43":
                    percentAlcohol = 0.31
                case "Strega":
                    percentAlcohol = 0.4
                default:
                    NSLog("Invalid cordial.")
                }
            default:
                NSLog("Invalid spirit type.")
            }
        case "Cocktail":
            switch cocktailType {
            case "Bloody Mary":
                percentAlcohol = 0.133
                volumeML = 177
            case "Jack & Coke":
                percentAlcohol = 0.114
                volumeML = 207
            case "Gin & Tonic":
                percentAlcohol = 0.133
                volumeML = 207
            case "Rum & Coke":
                percentAlcohol = 0.114
                volumeML = 207
            case "Manhattan":
                percentAlcohol = 0.317
                volumeML = 89
            case "Margarita":
                percentAlcohol = 0.333
                volumeML = 89
            case "Mimosa":
                percentAlcohol = 0.06
                volumeML = 177
            case "Mai Tai":
                percentAlcohol = 0.224
                volumeML = 133
            case "Mojito":
                percentAlcohol = 0.133
                volumeML = 177
            case "Daiquiri":
                percentAlcohol = 0.213
                volumeML = 111
            case "Piña Colada":
                percentAlcohol = 0.133
                volumeML = 266
            case "Martini":
                percentAlcohol = 0.373
                volumeML = 67
            case "Aviation":
                percentAlcohol = 0.289
                volumeML = 104
            case "Sidecar":
                percentAlcohol = 0.245
                volumeML = 81
            default:
                NSLog("Invalid cocktail.")
            }
        default:
            NSLog("Invalid drink class.")
        }
        
        self.percentAlcohol = percentAlcohol
        self.volumeML = volumeML
        self.gramsAlcohol = percentAlcohol * Float(volumeML) * 0.789
    }
    /*
    private func computeConsumptionDuration() {
        if self.sipOrShotgun == "Sipping" {
            self.consumptionDuration = 1
        } else if self.sipOrShotgun == "Shotgunning" {
            self.consumptionDuration = 1
        }
        
        self.consumptionDuration
    } */
    
    private func computeFullLife() {
        self.fullLife = Int(round(6.66 * Float(self.halfLife!)))
    }
    
    private func getTimeFullyAbsorbed() {
        self.timeFullyAbsorbed = self.timeBeganConsumption?.addingTimeInterval(TimeInterval(self.fullLife! * 60))
    }
    
    private func truncateSeconds(fromDate: Date) -> Date {
        let calendar = Calendar.current
        let fromDateComponents: DateComponents = calendar.dateComponents([.era , .year , .month , .day , .hour , .minute], from: fromDate)
        return calendar.date(from: fromDateComponents)! as Date
    }
    
    func computeDerivedValues() {
        computeGramsAlcohol()
        // computeConsumptionDuration()
        computeFullLife()
        self.timeBeganConsumption = truncateSeconds(fromDate: self.timeBeganConsumption!)
        self.timeAdded = truncateSeconds(fromDate: self.timeAdded!)
        getTimeFullyAbsorbed()
    }
    
}


struct Question {
    var questionString: String
    var answers: [String]
    var pushTo: [Int:String]
}

let questionsDict: [String:Question] = [
    "drinkClass":
        Question(questionString: "What are you drinking?",
                 answers: ["Beer", "Wine", "Spirits", "Cocktail", "Custom"],
                 pushTo: [0: "beerStrength", 1: "wineColor", 2: "spiritType", 3: "cocktailType", 4: "hunger"]),
    "beerStrength":
        Question(questionString: "What is the strength of your beer? (most beers are 'Full')",
                 answers: ["Low (2.7%)", "Medium (3.5%)", "Full (4.8%)", "Dubbel (6.8%)", "Trippel (8.5%)", "Quadruppel (11.5%)", "Custom"],
                 pushTo: [0: "beerContainer"]),
    "beerContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Full Solo Cup", "Half Solo Cup", "Standard Can/Bottle (12oz)", "Double Can/Bottle (24oz)", "Pint", "Half Pint"],
                 pushTo: [0: "sipOrShotgun"]),
    "sipOrShotgun":
        Question(questionString: "Are you sipping or shotgunning?",
                 answers: ["Sipping", "Shotgunning"],
                 pushTo: [0: "timeBeganConsumption"]),
    "timeBeganConsumption":
        Question(questionString: "When did you start drinking?",
                 answers: ["Now", "15 minutes ago", "30 minutes ago", "45 minutes ago", "1 hour ago", "1.5 hour ago"],
                 pushTo: [0: "hunger"]),
    "hunger":
        Question(questionString: "How hungry are you right now?",
                 answers: ["Full", "Not Hungry", "Hungry", "Very Hungry"],
                 pushTo: [0: "done"]),
    "wineColor":
        Question(questionString: "Red, white, or bubbly?",
                 answers: ["Red", "White", "Champagne"],
                 pushTo: [0: "wineContainer"]),
    "wineContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Standard glass", "Flute", "Half bottle", "Bottle", "Full Solo Cup", "Half Solo Cup"],
                 pushTo: [0: "timeBeganConsumption"]),
    "spiritType":
        Question(questionString: "What are you drinking?",
                 answers: ["Vodka", "Rum", "Tequila", "Gin", "Whiskey", "Sake", "Cordials"],
                 pushTo: [0: "spiritContainer", 1: "spiritContainer", 2: "spiritContainer", 3: "spiritContainer", 4: "whiskeyContainer", 5: "sakeContainer", 6: "cordialType"]),
    "spiritContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)", "Quarter Solo Cup", "Half Solo Cup"],
                 pushTo: [0: "timeBeganConsumption"]),
    "whiskeyContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)", "Glencairn"],
                 pushTo: [0: "timeBeganConsumption"]),
    "sakeContainer":
        Question(questionString: "How much are you drinking?",
                 answers: ["Tokkuri (small flask)", "Masu (wooden box)", "2-go", "3-go", "4-go", "Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)"],
                 pushTo: [0: "timeBeganConsumption"]),
    "cordialType":
        Question(questionString: "What are you drinking?",
                 answers: ["Amaretto", "Baileys", "Jägermeister", "Kahlúa", "Schnapps", "Amarula", "Pavan", "Licor 43", "Strega"],
                 pushTo: [0: "spiritContainer"]),
    "cocktailType":
        Question(questionString: "What are you drinking?", answers: ["Bloody Mary", "Jack & Coke", "Gin & Tonic", "Rum & Coke", "Manhattan", "Margarita", "Mimosa", "Mai Tai", "Mojito", "Daiquiri", "Piña Colada", "Martini", "Aviation", "Sidecar"], pushTo: [0: "cocktailSize"]),
    "cocktailSize":
        Question(questionString: "How big is the cocktail?",
                 answers: ["About standard size", "A drink and a half", "Double", "Triple"],
                 pushTo: [0: "timeBeganConsumption"])
]
