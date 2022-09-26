//
//  OffsetModifier.swift
//  UI-680
//
//  Created by nyannyan0328 on 2022/09/26.
//

import SwiftUI

extension View{
    
    @ViewBuilder
    func offset(competion : @escaping(CGRect) -> ()) -> some View{
        self
            .overlay {
                
                GeometryReader{proxy in
                    
                    let  rect = proxy.frame(in: .named("SCROLLER"))
                    
                    Color.clear
                        .preference(key :offsetKey.self, value: rect)
                        .onPreferenceChange(offsetKey.self) { value in
                            competion(value)
                        }
                    
                }
            }
        
        
        
    }
    
    
}
struct offsetKey : PreferenceKey{
    
    static var defaultValue: CGRect = .zero
    
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
