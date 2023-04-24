//
//  Views.swift
//  Chat Game
//
//  Created by Anupam Godbole on 4/13/23.
//

import Foundation
import SwiftUI

struct ButtonWithRoundedCornerBackground<Content: View>: View {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    private(set) var borderColor = Color.clear
    let selectedStatebackgroundColor: Color
    private(set) var selectedStateBorderColor = Color.clear
    @Binding var isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    
    private static var borderWidth: CGFloat { 1.0 }
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            action()
        }, label: content)
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(isSelected ? selectedStatebackgroundColor : backgroundColor)
            )
            .overlay(
                GeometryReader { reader in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .inset(by: Self.borderWidth / 2)
                        .stroke(isSelected ? selectedStateBorderColor : borderColor, lineWidth: Self.borderWidth)
                }
            )
    }
}

struct ViewWithRoundedCornerBackground<Content: View>: View {
    let cornerRadius: CGFloat
    let backgroundColor: Color
    private(set) var borderColor = Color.clear
    @ViewBuilder let content: () -> Content
    
    private static var borderWidth: CGFloat { 1.0 }

    var body: some View {
        content()
            //.frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(backgroundColor)
            )
            .overlay(
                GeometryReader { reader in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .inset(by: Self.borderWidth / 2)
                        .stroke(borderColor, lineWidth: Self.borderWidth)
                }
            )
    }
}

struct SelectableCellContent<Content: View>: View {
    @Binding var isSelected: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ViewWithRoundedCornerBackground(cornerRadius: 7, backgroundColor: Asset.Colors.Grayscale._90.swiftUIColor, borderColor: isSelected ? Asset.Colors.primary.swiftUIColor : Color(hex: "#404040")!) {
            HStack(spacing: 0) {
                Image("selected_cell_inward_arrow")
                    .opacity(isSelected ? 1 : 0)
                
                Spacer()
                
                content()
                
                Spacer()
                
                Image("selected_cell_outward_arrow")
                    .opacity(isSelected ? 1 : 0)
            }
        }
    }
}
