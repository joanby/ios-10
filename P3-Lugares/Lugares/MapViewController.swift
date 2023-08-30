//
//  MapViewController.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 12/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place: Place!
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.mapView.showsTraffic = true
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        
        
        print("El mapa debe mostrar "+place.name)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(place.location) { [unowned self] (placemarks, error) in
            if error == nil {
                //Procesar los posibles lugares
                for placemark in placemarks! {
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = self.place.name
                    annotation.subtitle = self.place.type
                    annotation.coordinate = (placemark.location?.coordinate)!
                    
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                    
                    
                }
            } else {
                print("Ha habido un error: \(error?.localizedDescription)")
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        
        
        var annotationView : MKPinAnnotationView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        imageView.image = UIImage(data: self.place.image! as Data)
        annotationView?.leftCalloutAccessoryView = imageView
        
        annotationView?.pinTintColor = UIColor.green
        
        
        return annotationView
    }
}

