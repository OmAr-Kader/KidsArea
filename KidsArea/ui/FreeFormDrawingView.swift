//
//  FreeFormDrawingView.swift
//  KidsArea
//
//  Created by OmAr Kader on 22/06/2025.
//

import SwiftUI
import PencilKit


// Based On => https://github.com/GetStream/stream-tutorial-projects/blob/main/visionOS/FreeFormDrawingView.swift

struct FreeFormDrawingView: View {
    
    @State private var canvas = PKCanvasView()
    @State private var isDrawing = true
    @State private var color: Color = .black
    @State private var pencilType: PKInkingTool.InkType = .pencil
    @State private var colorPicker = false
    @Environment(\.undoManager) private var undoManager
    
    @State private var isMessaging = false
    @State private var isVideoCalling = false
    @State private var isScreenSharing = false
    @State private var isRecording = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var isTopListOpen: Bool = false
    @State private var isLeftListOpen: Bool = false
    @State private var selectedTab: Tab? = .pencil

    var body: some View {
        ZStack {
            VStack {
                if isTopListOpen {
                    VStack {
                        HStack(spacing: 64) {
                            Button {
                                //
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "message")
                                    Text("Chat")
                                        .font(.caption2)
                                }
                            }
                            
                            Button {
                                //
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "video")
                                    Text("Call")
                                        .font(.caption2)
                                }
                            }
                            
                            // Screen sharing
                            Button {
                                //
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: isScreenSharing ? "shared.with.you.slash" : "shared.with.you")
                                    withAnimation {
                                        Text(isScreenSharing ? "Stop" : "Share")
                                            .font(.caption2)
                                    }
                                }
                            }
                            // Screen recording
                            Button {
                                isRecording.toggle()
                            } label: {
                                //Image(systemName: "rectangle.dashed.badge.record")
                                VStack(spacing: 8) {
                                    Image(systemName: isRecording ? "rectangle.inset.filled.badge.record" : "rectangle.dashed.badge.record")
                                    withAnimation {
                                        Text(isRecording ? "Stop" : "Record")
                                            .font(.caption2)
                                    }
                                }
                            }
                        }.padding(.horizontal)
                            .padding(12)
                            .buttonStyle(.plain)
                    }
                }
                HStack {
                    if isLeftListOpen {
                        VStack(spacing: 32) {
                            Button {
                                // Clear the canvas. Reset the drawing
                                canvas.drawing = PKDrawing()
                            } label: {
                                Image(systemName: "scissors")
                            }
                            
                            Button {
                                // Undo drawing
                                undoManager?.undo()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                            }
                            
                            Button {
                                // Redo drawing
                                undoManager?.redo()
                            } label: {
                                Image(systemName: "arrow.uturn.forward")
                            }
                            
                            Button {
                                selectedTab = nil
                                isDrawing = false
                            } label: {
                                Image(systemName: "eraser.line.dashed")
                            }
                            .foregroundStyle(
                                LinearGradient(gradient: Gradient(colors: [.white, Color(.main)]), startPoint: .leading, endPoint: .top)
                            )
                        } // Modify tools
                        .padding(12)
                        .buttonStyle(.plain)
                    }
                    DrawingView(canvas: $canvas, isDrawing: $isDrawing, pencilType: $pencilType, color: $color)
                }
            }.padding(.bottom, 40)
            if colorPicker {
                ColorPicker("Pick color", selection: $color)
                    .padding()
            }
            bottomBar
                .background(Color(.secondarySystemBackground))
                .height(40).onBottom()
        }.navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Drawing")
                        .foregroundStyle(.text)
                        .padding(.leading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isLeftListOpen.toggle()
                        }
                    } label: {
                        ImageSystem(systemIcon: isLeftListOpen ? "chevron.left" : "chevron.right", tint: .text)
                            .padding(2)
                            .frame(size: 30)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isTopListOpen.toggle()
                        }
                    } label: {
                        ImageSystem(systemIcon: isTopListOpen ? "chevron.down" : "chevron.up", tint: .text)
                            .padding(2)
                            .frame(size: 30)
                    }
                }
            }.tint(.text)
            .onChange(color) { newVlaue in
                colorPicker = false
            }
    }
    
    @ViewBuilder var bottomBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                Button {
                    canvas.isRulerActive.toggle()
                } label: {
                    CustomTabbedItem(imageName: Tab.ruler.icon, title: Tab.ruler.rawValue, isActive: false)
                }
                /*
                 Button {
                     @State var toolPicker = PKToolPicker()
                     toolPicker.setVisible(true, forFirstResponder: canvas)
                     toolPicker.addObserver(canvas)
                     canvas.becomeFirstResponder()
                 } label: {
                     CustomTabbedItem(imageName: Tab.canvasOptions.icon, title: Tab.canvasOptions.rawValue, isActive: false)
                 }
                 **/
                HStack {
                    ColorPicker(selection: $color) {
                    }
                    Spacer().width(7)
                }
                ForEach(Tab.allCasesPen, id: \.rawValue) { it in
                    let item = it as Tab
                    Button {
                        guard let pkTool = item.pkTool else {
                            return
                        }
                        pencilType = pkTool
                        isDrawing = true
                        withAnimation {
                            selectedTab = item
                        }
                    } label: {
                        CustomTabbedItem(imageName: item.icon, title: item.rawValue, isActive: selectedTab?.rawValue == item.rawValue)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    func saveDrawing() {
        // Get the drawing image from the canvas
        let drawingImage = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1.0)
        
        // Save drawings to the Photos Album
        UIImageWriteToSavedPhotosAlbum(drawingImage, nil, nil, nil)
    }
}


enum Tab: String, CaseIterable {
    case ruler = "Ruler"
    case canvasOptions = "Tools"
    case color = "Color"
    case pencil = "Pencil"
    case pen = "Pen"
    case marker = "Marker"
    case monoline = "Monoline"
    case fountain = "Fountain"
    case watercolor = "Watercolor"
    case crayon = "Crayon"
    var icon: String {
        switch self {
        case .ruler: return "pencil.and.ruler.fill"
        case .canvasOptions: return "pencil.tip.crop.circle.badge.plus"
        case .color: return "paintpalette"
        case .pencil: return "pencil"
        case .pen: return "pencil.tip"
        case .marker: return "paintbrush.pointed"
        case .monoline: return "pencil.line"
        case .fountain: return "paintbrush.pointed.fill"
        case .watercolor: return "eyedropper.halffull"
        case .crayon: return "pencil.tip"
        }
    }
    
    var pkTool: PKInkingTool.InkType? {
        if #available(iOS 17.0, *) {
            switch self {
            case .pencil: return .pencil
            case .pen: return .pen
            case .marker: return .marker
            case .monoline: return .monoline
            case .fountain: return .fountainPen
            case .watercolor: return .watercolor
            case .crayon: return .crayon
            default:  return nil
            }
        } else {
            switch self {
            case .pencil: return .pencil
            case .pen: return .pen
            case .marker: return .marker
            default:  return nil
            }
        }
    }
    
    static var allBaseCases: [Tab] {
        //return [.ruler, .canvasOptions, .color]
        return [.ruler, .color]
    }
    
    static var allCasesPen: [Tab] {
        if #available(iOS 17.0, *) {
            //.first, .second, .color,
            return [.pencil, .pen, .marker, .monoline, .fountain, .watercolor, .crayon]
        } else {
            return [.pencil, .pen, .marker]
        }
    }
}

struct CustomTabbedItem : View {
    
    let imageName: String
    let title: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12){
            Spacer()
            ImageSystem(systemIcon: imageName, tint: .text)
                .frame(width: 20, height: 20)

            if isActive {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(.text)

            }
            Spacer()
        }
        .frame(width: isActive ? 120 : 55, height: 55)
        .background(isActive ? .main.opacity(0.4) : .clear)
        .cornerRadius(30)
    }
}

struct DrawingView: UIViewRepresentable {
    // Capture drawings for saving in the photos library
    @Binding var canvas: PKCanvasView
    @Binding var isDrawing: Bool
    // Ability to switch a pencil
    @Binding var pencilType: PKInkingTool.InkType
    // Ability to change a pencil color
    @Binding var color: Color
    
    
    //let ink = PKInkingTool(.pencil, color: .black)
    // Update ink type
    var ink: PKInkingTool {
        PKInkingTool(pencilType, color: UIColor(color))
    }
    
    let eraser = PKEraserTool(.bitmap)
    
    func makeUIView(context: Context) -> PKCanvasView {
        // Allow finger and pencil drawing
        canvas.drawingPolicy = .anyInput
        
        canvas.tool = isDrawing ? ink : eraser
        canvas.isRulerActive = true
        //canvas.backgroundColor = .main.withAlphaComponent(0.1)

        
        // From Brian Advent: Show the default toolpicker
        canvas.alwaysBounceVertical = true
        canvas.isScrollEnabled = true
        
        let toolPicker = PKToolPicker.init()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas) // Notify when the picker configuration changes
        canvas.becomeFirstResponder()
        
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update tool whenever the main view updates
        uiView.tool = isDrawing ? ink : eraser
    }
}
