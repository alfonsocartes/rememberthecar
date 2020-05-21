//
//  MapView.swift
//  Remember The Car
//
//  Created by Alfonso Cartes on 15/12/2019.
//  Copyright © 2019 Alfonso Cartes. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var showingEditScreen: Bool
    @Binding var satelliteView: Bool
    
    @Binding var userCoordinate: CLLocationCoordinate2D

    var annotation: MKPointAnnotation
    @State private var lastAnnotation = MKPointAnnotation()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        
        if (mapView.mapType == MKMapType.standard && satelliteView) {
            mapView.mapType = MKMapType.hybrid
        }
        
        if (mapView.mapType == MKMapType.hybrid && !satelliteView) {
            mapView.mapType = MKMapType.standard
        }
        
        let centerInUserCoordinate =
            centerCoordinate.latitude != 0 &&
            centerCoordinate.longitude != 0 &&
            centerCoordinate.latitude == userCoordinate.latitude &&
            centerCoordinate.longitude == userCoordinate.longitude
        
        if centerInUserCoordinate {
            centerMap(mapView: mapView, coordinate: userCoordinate)
        }
        
        let annotationCoordinateHasChanged =
            annotation.coordinate.latitude != 0 &&
            annotation.coordinate.longitude != 0 &&
            annotation.coordinate.latitude != lastAnnotation.coordinate.latitude &&
            annotation.coordinate.longitude != lastAnnotation.coordinate.longitude
        
        /*
        print("annotationCoordinateHasChanged \(annotationCoordinateHasChanged)")
        print("annotation \(annotation.coordinate)")
        print("lastAnnotation \(lastAnnotation.coordinate)")
        print("mapView.annotations.count \(mapView.annotations.count)")
         */
        
        if annotationCoordinateHasChanged {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
            lastAnnotation.coordinate.latitude = annotation.coordinate.latitude
            lastAnnotation.coordinate.longitude = annotation.coordinate.longitude
        }
        
        
        if annotationCoordinateHasChanged {
            centerMap(mapView: mapView, coordinate: annotation.coordinate)
        }
    }
    
    func centerMap(mapView: MKMapView, coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            
            if annotation is MKUserLocation {
                return nil
            }
            
            // this is our unique identifier for view reuse
            let identifier = "Placemark"
            
            // attempt to find a cell we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                // we didn't find one; make a new one
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                // custom image icon
                //annotationView?.image = UIImage(systemName: "car")
                
                // allow this to show pop up information
                annotationView?.canShowCallout = true
                
                // attach an information button to the view
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            } else {
                // we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            }
            
            // whether it's a new view or a recycled one, send it back
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            
            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
            parent.showingEditScreen = true
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "My Parked car example"
        annotation.subtitle = "This is an example of a note that details the place where I parked my car\n\nAlso, it's multiline"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}

/*
 struct MapView_Previews: PreviewProvider {
 static var previews: some View {
 MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate),
 selectedPlace: .constant(MKPointAnnotation.example),
 showingPlaceDetails: .constant(false),
 showingEditScreen: .constant(false),
 centerInUserCoordinate: .constant(false),
 satelliteView: .constant(false),
 annotation: MKPointAnnotation.example,
 userCoordinate: MKPointAnnotation.example.coordinate)
 }
 }
 */
