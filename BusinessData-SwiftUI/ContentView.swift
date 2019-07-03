//
//  ContentView.swift
//  BusinessData-SwiftUI
//
//  Created by synup on 03/07/19.
//  Copyright © 2019 synup. All rights reserved.
//

import SwiftUI
import Combine
import Foundation


struct Course : Codable{
    let title : String
    let id : Int
    let url : String
}


class NetworkManager : BindableObject {
    var didChange = PassthroughSubject<NetworkManager,Never>()
    
    var courses = [Course](){
        didSet{
            didChange.send(self)
        }
    }
    
    init() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/photos?_page=1") else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            let cousrs = try! JSONDecoder().decode([Course].self,from : data)
            
            // trigger a state modification
            DispatchQueue.main.async {
                self.courses = cousrs
            }
            }.resume()
        
        
    }
}


class ImageLoader : BindableObject {
    var didChange = PassthroughSubject<Data,Never>()
    var data = Data() {
        didSet{
            didChange.send(data)
        }
    }
    
    init(imageUrl : String) {
        // fetch image with URLSession Here
        guard let url = URL(string: imageUrl) else { return}
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {return}
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
    }
    
}



struct ImageWidget : View {
    @ObjectBinding var imageLoader : ImageLoader
    
    init(imageUrl : String) {
        imageLoader = ImageLoader(imageUrl: imageUrl)
    }
    
    var body : some View {
        Image(uiImage: (imageLoader.data.count == 0 ? UIImage(named: "brandLogo") :  UIImage(data: imageLoader.data)!)!)
        .resizable()
        .aspectRatio(contentMode: .fit)
    }
}







struct ContentView : View {
    
    @State var networkMaager =  NetworkManager()
    
    var body: some View {
        NavigationView{
            List(networkMaager.courses.identified(by: \.id)) { course in
                VStack{
                    ImageWidget(imageUrl: course.url)
                }
                
                }.navigationBarTitle(Text("Courses"))
        }
    }
    
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
