//
//  MKPointAnnotation-ObservableObject.swift
//  Remember The Car
//
//  Created by Alfonso Cartes on 15/12/2019.
//  Copyright © 2019 Alfonso Cartes. All rights reserved.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }

        set {
            title = newValue
        }
    }

    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }

        set {
            subtitle = newValue
        }
    }
}
