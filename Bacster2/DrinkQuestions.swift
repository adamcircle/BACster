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
    var percentAcohol: Float?
    var timeBeganConsumption: Date?
    var timeAdded: Date?
    var consumptionDuration: DateInterval?
    var drinkClass: String?
    var containerSize: Float? // units of mL
    var drinkUnits: String?
    var drinkFullLife: Date?
    var drinkHalfLife: Date?
    var hunger: Float?
    
    // Beer Specific Data
    var beerStrength: Float?  // lo: .027, med: .035, full: .048, dub: .0675, trip: .085, quad: .115
    var sipOrShotgun: String?
    var beerContainer: String?
    
    // Wine Specific Data
    var wineColor: String?
    var wineContainer: String?
    
    // Spirit Specific Data
    var spiritType: String?
    var whiskeyContainer: String?
    var sakeContainer: String?
    var cordialType: String?
    
    // Cocktail Specific Data
    var cocktailType: String?
    var cocktailSize: Float?
    
    private func getGramsAlcohol() {
        self.gramsAlcohol = 4.0
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
                 answers: ["Full Solo Cup", "Half Solo Cup", "Standard Can", "Tall Can", "Pint", "Half Pint", "Custom"],
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
                 answers: ["Glass", "Flute", "Half bottle", "Bottle", "Solo Cup", "Half Solo Cup"],
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
                 answers: [ "Tokkuri (small flask)", "Masu (wooden box)", "2-go", "3-go", "4-go", "Standard shot (1oz)", "Tall shot (1.5oz)", "Double shot (2oz)"],
                 pushTo: [0: "timeBeganConsumption"]),
    "cordialType":
        Question(questionString: "What are you drinking?",
                 answers: ["Amaretto", "Baileys", "Jägermeister", "Kahlúa", "Schnapps", "Amarula", "Pavan", "Licor 43", "Strega", "Custom"],
                 pushTo: [0: "spiritContainer"]),
    "cocktailType":
        Question(questionString: "What are you drinking?", answers: ["Bloody Mary", "Jack & Coke", "Gin & Tonic", "Rum & Coke", "Manhattan", "Margarita", "Mimosa", "Mai Tai", "Mojito", "Daquiri", "Piña Colada", "Martini", "Aviation", "Sidecar"], pushTo: [0: "cocktailSize"]),
    "cocktailSize":
        Question(questionString: "How big is the cocktail?",
                 answers: ["About standard size", "A drink and a half", "Double", "Triple"],
                 pushTo: [0: "timeBeganConsumption"])
]
