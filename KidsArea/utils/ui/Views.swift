import SwiftUI
import Combine

extension View {
    
    @inlinable public func padding(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil
    ) -> some View {
        return padding(
            EdgeInsets(
                top: top ?? 0,
                leading: leading ?? 0,
                bottom: bottom ?? 0,
                trailing: trailing ?? 0
            )
        )
    }
    
    @inlinable public func padding(
        all: CGFloat
    ) -> some View {
        return padding(
            EdgeInsets(
                top: all,
                leading: all,
                bottom: all,
                trailing: all
            )
        )
    }
    
    @inlinable public func onStart() -> some View {
        return HStack {
            self
            Spacer(minLength: 0)
        }
    }
    
    @inlinable public func onEnd() -> some View {
        return HStack {
            Spacer(minLength: 0)
            self
        }
    }
    
    @inlinable public func onCenter() -> some View {
        return HStack {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
    
    @inlinable public func onTop() -> some View {
        return VStack {
            self
            Spacer(minLength: 0)
        }
    }
    
    @inlinable public func onBottomEnd() -> some View {
        return HStack {
            Spacer(minLength: 0)
            VStack(alignment: .center) {
                Spacer(minLength: 0)
                self
            }
        }
    }
    
    @inlinable public func onBottom() -> some View {
        return VStack {
            Spacer(minLength: 0)
            self
        }
    }
    
    @inlinable func width(_ w: CGFloat) -> some View {
        return frame(width: w)
    }
    
    @inlinable func height(_ h: CGFloat) -> some View {
        return frame(height: h)
    }
    
    @inlinable func frame(size: CGSize) -> some View {
        return frame(width: size.width, height: size.height)
    }
    
    @inlinable func frame(size: CGFloat) -> some View {
        return frame(width: size, height: size)
    }
    
    
    @inlinable func safeArea() -> some View {
        if #available(iOS 17.0, *) {
            return safeAreaPadding()
        } else {
            return self
        }
    }
    
    func onChange<T: Equatable>(_ it: T,_ action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return onChange(of: it) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: it) { newValue in
                action(newValue)
            }
        }
    }
    
    func onChangeNil<T: Equatable>(_ it: T?,_ action: @escaping (T?) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            return onChange(of: it) { oldValue, newValue in
                action(newValue)
            }
        } else {
            return onChange(of: it) { newValue in
                action(newValue)
            }
        }
    }
    
    
    func onAppearTask(delay: TimeInterval, perform: @escaping () async -> Void) -> some View {
        if delay == 0 {
            task {
                await perform()
            }
        } else {
            task {
                do {
                    try await Task.sleep(delay)
                } catch {
                    return
                }
                await perform()
            }
        }
    }
    
    
    func dismissKeyboard() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.endEditing(true) // Resign first responder
        }
    }
    
    func onAppeared(_ perform: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppearModifier(action: perform))
    }
}



struct OnFirstAppearModifier: ViewModifier {
    @State private var isAppeared = false
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                if isAppeared {
                    return
                }
                isAppeared = true
                action()
            }
    }
}

extension UIImage {
    func imageWith(width: CGFloat, height: CGFloat) -> UIImage {
        let newSize = CGSize(width: width, height: height)
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}

extension TimeInterval {
    var nanoseconds: UInt64 {
        return UInt64((self * 1_000_000_000).rounded())
    }
}

@available(iOS 13.0, macOS 10.15, *)
public extension Task where Success == Never, Failure == Never {
    static func sleep(_ duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: duration.nanoseconds)
    }
    
    static func afterSeconds(_ seconds: Float) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}


struct ImageSystem : View {
    
    let systemIcon: String
    let tint: Color
    
    var body: some View {
        Image(
            uiImage: UIImage(
                systemName: systemIcon
            )?.withTintColor(UIColor(tint), renderingMode: .alwaysOriginal) ?? UIImage()
        ).resizable()
            .renderingMode(.template)
            .foregroundColor(tint)
            .tint(tint)
            .background(Color.clear)
            .imageScale(.medium)
            .aspectRatio(contentMode: .fill)
            .scaledToFit()
    }
}
