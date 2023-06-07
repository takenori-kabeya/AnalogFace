//
//  ContentView.swift
//  AnalogFace Watch App
//
//  Created by Takenori Kabeya on 2023/06/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutSession: WorkoutSession
    let calendar: Calendar = Calendar(identifier: .gregorian)
    var isPreview: Bool

    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        hide(clock: true, indicators: true)
    }
    
    var body: some View {
        ZStack {
            Image("cat")
                .resizable(capInsets: EdgeInsets(top: -10, leading: -10, bottom: -10, trailing: -10), resizingMode: .stretch)
                .aspectRatio(contentMode: .fit)
                .padding(-10.0)
                .imageScale(.large)
                .foregroundColor(.accentColor)
                .clipShape(Circle()
                    .inset(by: -10))
            TimelineView(.periodic(from: Date.now, by: 1.0)) { context in
                let angles = getAngles(date: context.date)
                ZStack {
                    ShortHand(angle: angles.short)
                    LongHand(angle: angles.long)
                    ScondHand(angle: angles.second)
                    Circle()
                        .fill(Color(red: 0.6, green: 0.2, blue: 0.2))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(.black)
                        .frame(width: 2, height: 2)
                }
            }
        }
        .onAppear {
            if !isPreview {
                workoutSession.start()
            }
        }
    }
    
    func getAngles(date: Date) -> (long: Angle, short: Angle, second: Angle) {
        let components = self.calendar.dateComponents([.hour, .minute, .second], from: date)
        let totalSeconds = components.minute! * 60 + components.second!

        let secondDegree = Double(components.second!) / 60 * 360
        let longDegree = Double(totalSeconds) / 3600 * 360
        let hourDegree = Double(components.hour! % 12) / 12 * 360
        let secondsDegree = longDegree / 12
        let shortDegree = hourDegree + secondsDegree
        return (long: Angle(degrees: longDegree), short: Angle(degrees: shortDegree), second: Angle(degrees: secondDegree))
    }

    func LongHand(angle: Angle) -> some View {
        HandTriangle(width: 8, height: 80)
            .fill(.black)
            .frame(width: 8, height: 80)
            .offset(x: 4, y: 46)
            .rotationEffect(angle)
    }
    func ShortHand(angle: Angle) -> some View {
        HandTriangle(width: 10, height: 60)
            .fill(.black)
            .frame(width: 12, height: 40)
            .offset(x: 6, y: 26)
            .rotationEffect(angle)
    }
    func ScondHand(angle: Angle) -> some View {
        HandTriangle(width: 4, height: 76)
            .fill(Color(red: 0.6, green: 0.2, blue: 0.2))
            .frame(width: 12, height: 40)
            .offset(x: 6, y: 32)
            .rotationEffect(angle)
    }

    func HandTriangle(width: CGFloat, height: CGFloat) -> some Shape {
        Path { path in
            path.move(to: CGPointZero)
            path.addLine(to: CGPoint(x: -width/2, y: 0))
            path.addLine(to: CGPoint(x: -2, y: -height))
            path.addLine(to: CGPoint(x: 2, y: -height))
            path.addLine(to: CGPoint(x: width/2, y: 0))
            path.closeSubpath()
        }
    }

    func hide(clock: Bool, indicators: Bool) {
         guard let appClass: AnyClass = NSClassFromString("PUICApplication") else {
             return
         }
         let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
         guard let sharedApplicationMethod = class_getClassMethod(appClass, sharedApplicationSelector) else {
             return
         }
         let sharedApplicationMethodImp = method_getImplementation(sharedApplicationMethod)
         let sharedApplication = unsafeBitCast(sharedApplicationMethodImp, to: (@convention(c) (AnyClass?, Selector) -> Any).self)

         let app = sharedApplication(appClass, sharedApplicationSelector)

         if (clock) {
             let setStatusBarTimeHiddenSelector = NSSelectorFromString("_setStatusBarTimeHidden:animated:completion:")
             guard let setStatusBarTimeHiddenMethod = class_getInstanceMethod(appClass, setStatusBarTimeHiddenSelector) else {
                 return
             }
             let setStatusBarTimeHiddenMethodImp = method_getImplementation(setStatusBarTimeHiddenMethod)
             let setStatusBarTimeHidden = unsafeBitCast(setStatusBarTimeHiddenMethodImp, to: (@convention(c) (Any, Selector, ObjCBool, ObjCBool, OpaquePointer?) -> Void).self)

             setStatusBarTimeHidden(app, setStatusBarTimeHiddenSelector, ObjCBool(true), ObjCBool(false), nil)
         }
         if (indicators) {
             let setStatusBarIndicatorsHiddenSelector = NSSelectorFromString("_setStatusBarIndicatorsHidden:animated:completion:")
             guard let setStatusBarIndicatorsHiddenMethod = class_getInstanceMethod(appClass, setStatusBarIndicatorsHiddenSelector) else {
                 return
             }
             let setStatusBarIndicatorsHiddenMethodImp = method_getImplementation(setStatusBarIndicatorsHiddenMethod)
             let setStatusBarIndicatorsHidden = unsafeBitCast(setStatusBarIndicatorsHiddenMethodImp, to: (@convention(c) (Any, Selector, ObjCBool, ObjCBool, OpaquePointer?) -> Void).self)

             setStatusBarIndicatorsHidden(app, setStatusBarIndicatorsHiddenSelector, ObjCBool(true), ObjCBool(false), nil)
         }
     }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isPreview: true)
    }
}
