//
//  NavigateModifier.swift
//  rockapp
//
//  Created by Benjie on 11/19/24.
//


import SwiftUI

struct NavigateModifier<Destination: View>: ViewModifier {
    @Binding var isActive: Bool
    let destination: Destination

    func body(content: Content) -> some View {
        ZStack {
            content
            if isActive {
                destination
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

extension View {
    func navigate<Destination: View>(to destination: Destination, when isActive: Binding<Bool>) -> some View {
        self.modifier(NavigateModifier(isActive: isActive, destination: destination))
    }
}
