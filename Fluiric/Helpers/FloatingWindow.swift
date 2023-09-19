import SwiftUI
// - Custom View Modifier for Floating Window (Like Sheets)
extension View{
    @ViewBuilder
    func floatingWindow<Content: View>(poition: CGPoint, show: Binding<Bool>, @ViewBuilder content: @escaping ()->Content)->some View{
        self
            .modifier(FloatingWindowModifier(windowView: content(), position: poition, show: show))
    }
}

fileprivate struct FloatingWindowModifier<WindowView: View>: ViewModifier{
    var windowView: WindowView
    var position: CGPoint
    @Binding var show: Bool
    @State private var panel: FloatingPanelHelper<WindowView>?
    
    func body(content: Content) -> some View {
        content
            .onAppear{
                panel = FloatingPanelHelper(position: position, show: $show, content: {
                    windowView
                })
            }
            .background(content: {
                ViewUpdater(content: windowView, panel: $panel)
            })
            .onChange(of: position) { newValue in
                panel?.updatePosition(newValue)
            }
            .onChange(of: show) { newValue in
                
               
                if newValue{
                    panel?.orderFront(nil)
                    panel?.makeKey()
                }
                
            }
    }
}

class FloatingPanelHelper<Content: View>: NSPanel{
    @Binding private var show: Bool
    
    init(position: CGPoint, show: Binding<Bool>, @ViewBuilder content: @escaping ()->Content){
        self._show = show
        super.init(contentRect: .zero, styleMask: [.resizable, .closable, .fullSizeContentView, .nonactivatingPanel, .borderless], backing: .buffered, defer: false)
        
        isFloatingPanel = true
        
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
        
        isMovableByWindowBackground = true
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        backgroundColor = NSColor.clear
        
        contentView = NSHostingView(rootView: content())
        
        
        
        makeKeyAndOrderFront(nil)
    }
    
    func updatePosition(_ to: CGPoint){
        let fittingSize = contentView?.fittingSize ?? .zero
        self.setFrame(.init(origin: to, size: fittingSize), display: true, animate: true)
    }
}

fileprivate struct ViewUpdater<Content: View>: NSViewRepresentable{
    var content: Content
    @Binding var panel: FloatingPanelHelper<Content>?
    func makeNSView(context: Context) -> some NSView {
        return NSView()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        if let hostingView = panel?.contentView as? NSHostingView<Content>{
            hostingView.rootView = content
        }
    }
}
