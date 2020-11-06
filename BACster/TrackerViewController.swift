//
//  SecondViewController.swift
//  BACster
//
//  Created by Adam Circle on 11/2/20.
//  Copyright © 2020 Adam Circle. All rights reserved.
//

import UIKit

class TrackerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    let drinkTypes = ["Beer", "Wine", "Cocktail", "Spirits"//, "Custom"
    ]
    
    let drinkTypeImages: [UIImage] = [
        UIImage(named: "Beer")!,
        UIImage(named: "Wine")!,
        UIImage(named: "Cocktail")!,
        UIImage(named: "Spirit")! // ,
        // UIImage(named: "Custom")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DrinkTypeCell")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinkTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrinkTypeCell", for: indexPath) as? DrinkTypeCell else {
            fatalError("Unable to dequeue a DrinkTypeCell.")
        }
        
        cell.DrinkTypeLabel.text = drinkTypes[indexPath.item]
        cell.DrinkTypeSprite.image = drinkTypeImages[indexPath.item]
        
        return cell
    }

}

