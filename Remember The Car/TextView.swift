//
//  TextView.swift
//  Remember The Car
//
//  Created by Alfonso Cartes on 15/12/2019.
//  Copyright © 2019 Alfonso Cartes. All rights reserved.
//

// This wraps UITextView because SwiftUI does not support UITextView

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 17)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        //myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0)

        return myTextView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            print("text now: \(String(describing: textView.text!))")
            self.parent.text = textView.text
        }
    }
}
/*
struct TextView_Previews: PreviewProvider {
    
    let multilineStringExample = """
    Very long line 1
    Very long line 2
    Very long line 3
    Very long line 4
    """
    
    static var previews: some View {
        TextView(text: multilineStringExample)
    }
}
*/
