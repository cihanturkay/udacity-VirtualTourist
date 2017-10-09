//
//  DetailViewController.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 06.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {
    
    var selectedPin: Pin!
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            fetchedResultsController.delegate = self
            executeSearch()
            if fetchedResultsController.fetchedObjects?.count == 0 {
                getPhotosFromFlicker()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [self.selectedPin])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func getPhotosFromFlicker(){
        let oldPhotos = fetchedResultsController.fetchedObjects as! [Photo]
        for photo in oldPhotos {
            stack.context.delete(photo)
        }
        selectedPin.page = selectedPin.page + 1
        stack.save()
        FlickerClient.sharedInstance().getImagesFromFlicker(selectedPin) { (photos, error) in
            if let error = error {
                print(error)
            } else {
                print("succesfuly get the images")
            }
        }
    }
    
    
    
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO Add collection view
        return collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        self.stack.context.delete(photo)
        stack.save()
    }
    
}

extension DetailViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
}
