//
//  EditView.swift
//  Remember The Car
//
//  Created by Alfonso Cartes on 15/12/2019.
//  Copyright © 2019 Alfonso Cartes. All rights reserved.
//

import SwiftUI
import MapKit
import UserNotifications

struct EditView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var placemark: MKPointAnnotation
    
    @State private var image: Image?
    
    // Image importing
    @State private var showingImagePicker = false
    @Binding var inputImage: UIImage?
    
    static var defaultNotificationTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var notificationTime = defaultNotificationTime
    @State private var notificationSet = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Form {
                        Section (header: Text("Place note")) {
                            TextField("Place note", text: self.$placemark.wrappedTitle)
                        }
                        /*
                        Section (header: Text("Notes")) {
                            /*
                            TextField("Description", text: self.$placemark.wrappedSubtitle)
                                .multilineTextAlignment(.leading)
                                .frame(minHeight: 150, maxHeight: .infinity, alignment: .topLeading)
                                .lineLimit(4)
                            */
                            TextView(text: self.$placemark.wrappedSubtitle)
                                .frame(minHeight: 150, maxHeight: .infinity, alignment: .topLeading)
                        }
                        */
                        Section (header: Text("Photo")) {
                            VStack {
                                Button(action: {
                                    self.showingImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Add photo")
                                    }
                                }
                                //.padding()
                                if self.image != nil {
                                    self.image?
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                        
                        Section (header: Text("Remind me")) {
                             DatePicker("Please enter a time",
                                        selection: self.$notificationTime,
                                        displayedComponents: .hourAndMinute)
                               .labelsHidden()
                               .datePickerStyle(WheelDatePickerStyle())
                            VStack (alignment: .center) {
                                Button(action: {
                                    self.addNotification()
                                }) {
                                    HStack  {
                                        if self.notificationSet {
                                            HStack {
                                                Image(systemName: "checkmark")
                                                Text("Reminder set")
                                                .bold()
                                            }
                                            .foregroundColor(.red)
                                            
                                        } else {
                                            Image(systemName: "timer")
                                            Text("Add notification")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    BannerView()
                    HStack {
                        Image(systemName: "map")
                            .font(.headline)
                        Text("Walking directions")
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: 200)
                    .padding(15)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(40)
                    .onTapGesture {
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.placemark.coordinate, addressDictionary:nil))
                        mapItem.name = "\(self.placemark.wrappedTitle)"
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
                    }
                }
            }
            .navigationBarTitle("Edit place")
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
                self.saveImage()
            })
                .onAppear(perform: loadSavedImage)
                .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
                        .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    func loadImage() {
        guard let pickedImage = inputImage else { return }
        image = Image(uiImage: pickedImage)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func loadSavedImage() {
        let filename = getDocumentsDirectory().appendingPathComponent("parkedcar.png")
        let savedImage    = UIImage(contentsOfFile: filename.path)
        guard let inputImage = savedImage else { return }
        image = Image(uiImage: inputImage)
         print("Image loaded successfully.")
    }
    
    func saveImage() {
        if let image = inputImage {
            if let data = image.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent("parkedcar.png")
                try? data.write(to: filename)
                print("Image saved successfully.")
            }
        }
         
    }
    
    func addNotification() {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Remember The Car"
            content.subtitle = "Your parking time is up!"
            content.sound = UNNotificationSound.default

            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: self.notificationTime)
            
            var dateComponents = DateComponents()
            dateComponents = components
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
                self.notificationSet.toggle()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                        self.notificationSet.toggle()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

/*
struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(
            placemark: MKPointAnnotation.example
        )
    }
}
*/
