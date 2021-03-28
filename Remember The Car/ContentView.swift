//
//  ContentView.swift
//  Remember The Car
//
//  Created by Alfonso on 21/05/2020.
//  Copyright © 2020 cartes.dev. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var userCoordinate = CLLocationCoordinate2D()
    @State private var location = CodableMKPointAnnotation()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    @State private var satelliteView = false
    @State private var showingAlertLocationDenied = false
    
    @State private var inputImage: UIImage?
    
    let locationManager = CLLocationManager()
    
    
    var body: some View {
        ZStack {
            MapView(centerCoordinate: $centerCoordinate,
                    selectedPlace: $selectedPlace,
                    showingPlaceDetails: $showingPlaceDetails,
                    showingEditScreen: $showingEditScreen,
                    satelliteView: $satelliteView,
                    userCoordinate: $userCoordinate,
                    annotation: location
            )
                .edgesIgnoringSafeArea(.all)
            if satelliteView {
                Image(systemName: "car")
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white.opacity(0.50))
                    .clipShape(Circle())
            } else {
                Image(systemName: "car")
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.secondary.opacity(0.30))
                    .clipShape(Circle())
            }
            VStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.satelliteView.toggle()
                        }) {
                            if satelliteView {
                                Image(systemName: "map.fill")
                                    .padding()
                                    .font(.title)
                                    .background(Color.white.opacity(0.75))
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "map")
                                    .padding()
                                    .font(.title)
                                    .background(Color.white.opacity(0.75))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            // center the map in the user's location
                            if let userLocation = self.getUserLocation() {
                                self.userCoordinate = userLocation
                                self.centerCoordinate = userLocation
                            }
                        }) {
                            Image(systemName: "location.fill")
                                .padding(.top, 4)
                                .padding(.trailing, 4)
                                .padding()
                                .font(.title)
                                .background(Color.white.opacity(0.75))
                                .clipShape(Circle())
                        }
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.title = "Parked Car"
                            newLocation.subtitle = ""
                            newLocation.coordinate = self.centerCoordinate
                            self.location = newLocation
                            self.selectedPlace = newLocation
                            self.saveData()
                            self.deleteSavedImage()
                            self.centerCoordinate = newLocation.coordinate
                            
                        }) {
                            Image(systemName: "p.circle")
                                .padding()
                                .background(Color.blue.opacity(0.75))
                                .foregroundColor(.white)
                                .font(.largeTitle)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                //BannerView()
                .padding(.bottom, 30)
            } // VStack for Banner View
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!, inputImage: self.$inputImage)
            }
        }
        .alert(isPresented: $showingAlertLocationDenied) {
            Alert(title: Text("Location Access Disabled"),
                  message: Text("In order to center the map on your location, please open this app's settings and set location access to 'While Using the App'."),
                  primaryButton: .default(Text("Cancel")),
                  secondaryButton: .default(Text("Open Settings")){
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                })
        }
        .onAppear() {
            self.loadData()
        }
    }
    
    func getUserLocation() -> CLLocationCoordinate2D? {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            let locations = [CLLocation]()
            return locationManager(locationManager, didUpdateLocations: locations)
        case .restricted,.denied:
            showingAlertLocationDenied = true
        default:
            showingAlertLocationDenied = true
        }
        return nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> CLLocationCoordinate2D {
        let locValue: CLLocationCoordinate2D = manager.location?.coordinate ?? CLLocationCoordinate2D()
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        return locValue
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        do {
            let data = try Data(contentsOf: filename)
            location = try JSONDecoder().decode(CodableMKPointAnnotation.self, from: data)
            print("Data loaded successfully.")
        } catch {
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.location)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("Data saved successfully.")
        } catch {
            print("Unable to save data.")
        }
    }
    
    func deleteSavedImage() {
        let fileManager = FileManager.default
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("parkedcar.png")
        
        if fileManager.fileExists(atPath: imagePath) {
            do {
                try fileManager.removeItem(atPath: imagePath)
                print("Image deleted successfully.")
            } catch {
                print("Unable to delete image.")
            }
        } else {
            print("Image does not exist")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
