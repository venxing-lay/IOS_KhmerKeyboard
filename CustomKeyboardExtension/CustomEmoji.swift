//
//import SwiftUI
//
//@available(iOSApplicationExtension 13.0, *)
//struct EmojiView : View {
//    
//    @Binding var show : Bool
//    @Binding var txt : String
//    
//    var body : some View{
//        var emojis: [String] = Constants.emoSmiley
//        ZStack(alignment: .topLeading) {
//            
//            
//            ScrollView(.vertical, showsIndicators: false) {
//                
//                VStack(spacing: 15){
//                    
//                    ForEach(self.emojis ,id: \.self){i in
//                        
//                        HStack(spacing: 25){
//                            
//                            ForEach(i,id: \.self){j in
//                                
//                                Button(action: {
//                                    
//                                    self.txt += String(UnicodeScalar(j)!)
//                                    
//                                }) {
//                                    
//                                    if (UnicodeScalar(j)?.properties.isEmoji)!{
//                                        
//                                        Text(String(UnicodeScalar(j)!)).font(.system(size: 55))
//                                    }
//                                    else{
//                                        
//                                        Text("")
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(.top)
//                
//                
//            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)
//            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
//            .background(Color.white)
//            .cornerRadius(25)
//
//        }
//    }
//    
//}
