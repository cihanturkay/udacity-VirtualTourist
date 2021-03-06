//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 06.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteAlert: UIView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    fileprivate var isDeleting: Bool = false
    fileprivate var longPressRecogniser: UILongPressGestureRecognizer!
    fileprivate let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    fileprivate var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the map
            fetchedResultsController.delegate = self
            executeSearch()
            fetchAllPins()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        isDeleting = false
        setUpGestureRecogniser()
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        if isDeleting {
            hideDeleteAlert()
            self.editButton.title = "Edit"
        } else {
            showDeleteAlert()
            self.editButton.title = "Done"
        }
    }
    
    
    func showDeleteAlert() {
        isDeleting = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.deleteAlert.frame.origin.y -= self.deleteAlert.frame.height
            self.mapView.frame.origin.y -= self.deleteAlert.frame.height
        }, completion: nil)
    }
    
    func hideDeleteAlert() {
        isDeleting = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.deleteAlert.frame.origin.y += self.deleteAlert.frame.height
            self.mapView.frame.origin.y += self.deleteAlert.frame.height
        }, completion: nil)
    }
    
    func fetchAllPins() {
        //clear annotations
        mapView.removeAnnotations(mapView.annotations)
        for pin in fetchedResultsController.fetchedObjects as! [Pin] {
            print("pin found lat \(pin.latitude) long \(pin.longitude) page \(pin.page)")
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
            annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func findPinFromAnnotation(annotation: MKAnnotation) -> Pin? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "longitude == %lf AND latitude == %lf", Double(annotation.coordinate.longitude), Double(annotation.coordinate.latitude))
        let tempFetchController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try tempFetchController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(tempFetchController)")
        }
        return tempFetchController.fetchedObjects?.first as? Pin
    }
}

extension MainViewController: MKMapViewDelegate {
    
    func setUpGestureRecogniser() {
        longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        guard !isDeleting else {
            return
        }
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            addAnnotationToCoreData(point: annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            if isDeleting , let toDelete = findPinFromAnnotation(annotation: annotation){
                self.stack.context.delete(toDelete)
                mapView.removeAnnotation(annotation)
                stack.save()
            } else if !isDeleting {
                print("annotation \(annotation.coordinate)")
                if let pin = findPinFromAnnotation(annotation: annotation) {
                    let albumController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                    albumController.selectedPin = pin
                    navigationController!.pushViewController(albumController, animated: true)
                }
                
            }
            
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }
    
    //add animations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
    func addAnnotationToCoreData(point: MKPointAnnotation){
        _ = Pin.init(Double(point.coordinate.latitude), Double(point.coordinate.longitude), 0, context: self.stack.context)
        stack.save()
    }
    
    
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    
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

