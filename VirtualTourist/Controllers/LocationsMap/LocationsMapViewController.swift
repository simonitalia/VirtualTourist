//
//  LocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class LocationsMapViewController: UIViewController {
    
    //MARK:- Data Persistence Properties
    //Core Data
    var dataController: DataController? {
        return DataController.shared
    }
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    //User defaults
    private var region: MKCoordinateRegion? {
        return AppDelegate.region
    }
    
    
    //MARK:- Class Properties
    enum SegueIdentifier {
        static let segueToPhotoAlbumViewController = "LocationsMapVCToPhotoAlbumVC"
    }
    
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //actions
    @IBAction func locationsMapLongPressed(_ sender: Any) {
        if let sender = sender as? UILongPressGestureRecognizer {
            if sender.state == .ended {
                let mapCoordinate = getMapCoordinatesFrom(longPressGestureRecognizer: sender)
                let annotation = mapView.createMapPointAnnotation(from: mapCoordinate) //get new annotation
                createNewCoreDataPin(with: annotation) //create new pin with annotation
            }
        }
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureVC()
        configureCoreData() //load core data annotations
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.annotations.forEach{ mapView.removeAnnotation($0) }
        mapView.delegate = nil
    }
    
    
    //MARK:- Core Data Setup
    private func configureCoreData() {
        congifureFetchedResultsController()
    }
    
    
    //MARK:- VC Setup
    private func configureVC() {
        configureMapView()
    }
    
    
    private func configureMapView() {
        mapView.delegate = self
        
        //set region (if saved)
        if let region = region {
            mapView.region = region
        }
    }
}


//MARK: - Helpers
extension LocationsMapViewController {
    
    private func getMapCoordinatesFrom(longPressGestureRecognizer touchPoint: UILongPressGestureRecognizer) -> CLLocationCoordinate2D {
        let touchPoint: CGPoint = touchPoint.location(in: mapView)
        let mapCoordinates: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        return mapCoordinates
    }
    
    
    //updateUI with annotations
      private func updateUI(with annotations: [MKAnnotation]) {
          mapView.updateMapView(with: annotations)
      }
    
    
    //Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    
}


//MARK:- MKMAPView Delegate
extension LocationsMapViewController  {
    
    //track annotation view taps
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //set destination VC annotation property
        PhotoAlbumViewController.annotation = view.annotation
        
        //trigger save of map region
        UserSettingsDataPersistenceManager.shared.saveMapRegion()
        
        //trigger segue
        performSegue(withIdentifier: SegueIdentifier.segueToPhotoAlbumViewController, sender: self)
    }
    
    //track when the user moves the map and save the region
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        AppDelegate.region = mapView.region //set current region
    }
}


//MARK:- Core Data Delegate
extension LocationsMapViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func congifureFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "locationName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController!.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        
            if let pins = fetchedResultsController.fetchedObjects {
                print("\(pins.count) pins loaded from core data.")
                let annotations = mapView.createMapPointAnnotations(from: pins)
                self.updateUI(with: annotations)
            }

        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    

    private func createNewCoreDataPin(with annotation: MKAnnotation) {
        guard let context = dataController?.container.viewContext else { return }
        let pin = Pin.createPin(with: annotation, in: context)
        let annotation = self.mapView.createMapPointAnnotation(from: pin)
        self.updateUI(with: [annotation])
        
        try? context.save()
        self.printCoreDataStatistics(context: context)
    }
}





