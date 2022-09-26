//
//  Home.swift
//  UI-680
//
//  Created by nyannyan0328 on 2022/09/26.
//

import SwiftUI

struct Home: View {
    @State var characters : [Character] = []
    @GestureState var isDragging : Bool = false
    
    @State var offsetY : CGFloat = 0
    @State var currentActiveIndex : Int = 0
    @State var isDrag : Bool = false
    
    @State var startOffset : CGFloat = 0
    var body: some View {
        NavigationStack{
            
            ScrollViewReader { proxy in
                
                ScrollView(.vertical,showsIndicators: false){
                    
                    VStack(spacing: 0) {
                        
                        
                        ForEach(characters){character in
                            
                            ContactForCharacter(character: character)
                                .id(character.index)
                            
                        }
                        
                    }
                    .padding(.top,15)
                    .padding(.trailing,100)
            
                    
                    
                }
                .onChange(of: currentActiveIndex) { newValue in
                    
                    if isDrag{
                        
                        withAnimation(.easeInOut(duration: 0.15)){
                            
                            proxy.scrollTo(currentActiveIndex,anchor: .top)
                        }
                    }
                }
                
            }
            .navigationTitle("Contacts")
            .offset(competion: { offsetRect in
                if offsetRect.minY != startOffset{
                    
                    startOffset = offsetRect.minY
                }
                
            })
          
            
        
          
        }
        .overlay(alignment: .trailing, content: {
            
            CustomScroller()
                .padding(.top,35)
        })
        .onAppear{
            
            characters = fetchCharacters()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                
                
                CharacterElevation()
            }
        }
    }
    func VerifyAndUpdated(index : Int,offset : CGFloat)->Bool{
        
        if characters.indices.contains(index){
            
            characters[index].pusOffset = offset
            characters[index].isCurrent = false
            return true
        }
        
        return false
        
    }
    @ViewBuilder
    func CustomScroller ()->some View{
        
        GeometryReader{proxy in
            
            let rect = proxy.frame(in: .named("SCROLLER"))
            
            VStack(spacing:0){
                
                ForEach($characters){$character in
                    
                    
                    HStack(spacing:15){
                        
                        
                        GeometryReader{innner in
                            
                            let origin = innner.frame(in: .named("SCROLLER"))
                            
                            Text(character.value)
                                .fontWeight(character.isCurrent ? .bold : .semibold)
                                .foregroundColor(character.isCurrent ? .black : .gray)
                                .scaleEffect(character.isCurrent ? 1.5 : 0.8)
                                .contentTransition(.interpolate)
                                .frame(width: origin.size.width,height: origin.size.height,alignment: .trailing)
                                .overlay {
                                    Rectangle()
                                    .fill(.black)
                                     .frame(width:15 ,height:1)
                                     .offset(x:36)
                                }
                                .offset(x:character.pusOffset)
                                .animation(.easeInOut(duration: 0.2), value: character.pusOffset)
                                .animation(.easeInOut(duration: 0.2), value: character.isCurrent)
                                .onAppear{
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                        
                                        character.rect = origin
                                    }
                                }
                            
                            
                        }
                        .frame(width:20)
                        
                        ZStack{
                            
                            if characters.first?.id == character.id{
                               
                                Scrollerknob(character: $character, rect: rect)
                                
                            }
                            
                        }
                         .frame(width: 22,height: 22)
                       
                        
                        
                        
                    }
                    
                }
            }
            
            
            
        }
        .frame(width:55)
        .padding(.trailing,10)
        .coordinateSpace(name: "SCROLLER")
        .padding(.vertical,25)
        
        
    }
    func CharacterElevation(){
        
        if let index = characters.firstIndex(where: { character in
            
            character.rect.contains(CGPoint(x: 0, y: offsetY))
        }){
            
            updateEleavation(index: index)
            
            
            
            
            
        }
        
    }
    
    
    func updateEleavation (index : Int){
        characters[index].pusOffset = -35
        characters[index].isCurrent = true
        
        var modiiedIndicies : [Int] = []
        
        currentActiveIndex = index
        modiiedIndicies.append(index)
        
        let otherOffsets : [CGFloat] = [-25,-15,-5]
        
        
        for _index in otherOffsets.indices{
            
            let newIndex = index + (_index + 1)
            
            
            let newIndexNagative = index - (_index + 1)
            
            if VerifyAndUpdated(index: newIndex, offset: otherOffsets[_index]){
                
                modiiedIndicies.append(newIndex)
            }
            
            if VerifyAndUpdated(index: newIndexNagative, offset: otherOffsets[_index]){
                
                modiiedIndicies.append(newIndexNagative)
            }
            
            
        }
        
        
        
        
        for index_ in characters.indices{
            
            
            if !modiiedIndicies.contains(index_){
                
                characters[index_].pusOffset = 0
                characters[index_].isCurrent = false
                
            }
            
        }
        
        
    }
    @ViewBuilder
    func Scrollerknob (character : Binding<Character>,rect : CGRect)->some View{
        
        
        Circle()
            .fill(.black)
            .overlay {
                
                Circle()
                    .fill(.white)
                    .scaleEffect(isDragging ? 0.8 : 0.001)
            }
            .scaleEffect(isDragging ? 1.35 : 1)
            .animation(.easeIn(duration: 0.3), value: isDragging)
            .offset(y:offsetY)
            .gesture(
            
                DragGesture(minimumDistance:5).updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    
                    isDrag = true
                    
                    var location = value.location.y - 20
                    
                    location = min(location, (rect.maxY - 20))
                    location = max(location, rect.minY)
                
                    
                    offsetY = location
                    
                    CharacterElevation()
                })
                .onEnded({ value in
                    
                    
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                     
                        isDrag = false
                        
                    }
                    
                    
                    if characters.indices.contains(currentActiveIndex){
                        
                        withAnimation(.easeInOut(duration: 0.2)){
                            
                            offsetY = characters[currentActiveIndex].rect.minY
                        }
                    }
                    
                })
            
            )
        
    }
    @ViewBuilder
    func ContactForCharacter (character : Character)->some View{
        
        
        VStack(alignment:.leading,spacing: 10){
            
            
            Text(character.value)
                .font(.largeTitle.bold())
            
            
            ForEach(1...4 ,id:\.self){index in
                
                HStack(spacing:15){
                    
                    
                    Circle()
                        .fill(character.color.gradient)
                     .frame(width: 50,height: 50)
                    
                    VStack(alignment:.leading,spacing: 10){
                        
                     
                       RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(character.color.gradient.opacity(0.3))
                            .frame(height:20)
                        
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                             .fill(character.color.gradient.opacity(0.3))
                             .frame(height:20)
                             .padding(.trailing,160)
                        
                    }
                    
                        
                }
                
            }
            
        }
        .padding(15)
        .offset { offsetRect in
            
            let minY = offsetRect.minY
            let index = character.index
            
            if minY > 0 && minY < startOffset && !isDrag{
                updateEleavation(index: index)
                
                withAnimation(.easeOut(duration: 0.2)){
                    
                    offsetY = characters[index].rect.minY
                }
                
            }
        }
        
    }
    func fetchCharacters()->[Character]{
        
        let alphabets : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var characters : [Character] = []
        characters = alphabets.compactMap({ character ->Character? in
            
            return Character(value: String(character))
            
        })
        
    let colors : [Color] = [.red,.yellow,.gray,.green,.orange,.purple,.indigo,.blue,.pink]
        
        for index in characters.indices{
            
            characters[index].index = index
            characters[index].color = colors.randomElement()!
        }
        return characters
        
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
