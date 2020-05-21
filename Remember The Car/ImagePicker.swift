//
//  ImagePicker.swift
//  Remember The Car
//
//  Created by Alfonso Cartes on 15/12/2019.
//  Copyright © 2019 Alfonso Cartes. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let rotatedImage = imageOrientation(uiImage)
                parent.image = rotatedImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // This functions corrects the image orientation
        func imageOrientation(_ src:UIImage) -> UIImage {
            if src.imageOrientation == UIImage.Orientation.up {
                return src
            }
            var transform: CGAffineTransform = CGAffineTransform.identity
            switch src.imageOrientation {
            case UIImageOrientation.down, UIImageOrientation.downMirrored:
                transform = transform.translatedBy(x: src.size.width, y: src.size.height)
                transform = transform.rotated(by: .pi)
                break
            case UIImageOrientation.left, UIImageOrientation.leftMirrored:
                transform = transform.translatedBy(x: src.size.width, y: 0)
                transform = transform.rotated(by: .pi / 2)
                break
            case UIImageOrientation.right, UIImageOrientation.rightMirrored:
                transform = transform.translatedBy(x: 0, y: src.size.height)
                transform = transform.rotated(by: -.pi / 2)
                break
            case UIImageOrientation.up, UIImageOrientation.upMirrored:
                break
            @unknown default:
                fatalError()
            }

            switch src.imageOrientation {
            case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
                transform.translatedBy(x: src.size.width, y: 0)
                transform.scaledBy(x: -1, y: 1)
                break
            case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
                transform.translatedBy(x: src.size.height, y: 0)
                transform.scaledBy(x: -1, y: 1)
            case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
                break
            @unknown default:
                fatalError()
            }

            let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

            ctx.concatenate(transform)

            switch src.imageOrientation {
            case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
                ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
                break
            default:
                ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
                break
            }

            let cgimg:CGImage = ctx.makeImage()!
            let img:UIImage = UIImage(cgImage: cgimg)

            return img
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = .camera
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
