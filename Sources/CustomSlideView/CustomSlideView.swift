// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
public struct ViewStates {
    public var offset: CGFloat
    public var description: String
    public var isExpanded: Bool
    public var cornerRadius: CGFloat
    public init(offset: CGFloat = 0, description: String = "", isExpanded: Bool = false, cornerRadius: CGFloat = 0) {
        self.offset = offset
        self.description = description
        self.isExpanded = isExpanded
        self.cornerRadius = cornerRadius
    }
}
@available(iOS 13.0, *)
public struct CustomSlideView<Content: View>: View {
    @Binding var viewState: ViewStates
    @GestureState private var dragOffset: CGFloat = 0
    @State private var viewHeight: CGFloat = 0.0
    public var content: () -> Content
    public init(viewState: Binding<ViewStates>, viewHeight: CGFloat, content: @escaping () -> Content) {
        self._viewState = viewState
        self.viewHeight = viewHeight
        self.content = content
    }
    public var body: some View {
        content()
        .padding(.horizontal, 25)
        .padding(.vertical, 50)
        .background(
            ZStack(alignment: .top) {
                Color.yellow
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ViewHeightKey.self, value: proxy.size.height)
                }
            }
        )
        .onPreferenceChange(ViewHeightKey.self) { height in
            print("height ....\(height)")
                viewHeight = height
        }
        .cornerRadius(viewState.cornerRadius)
        .frame(width: UIScreen.main.bounds.width)
        .offset(y: viewState.offset + dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation.height
                    } else {
                        state = 0
                    }
                }
                .onEnded { value in
                    viewState.offset += value.translation.height

                    if value.translation.height > viewHeight/2 {
                        withAnimation() {
                            viewState.offset = viewHeight
                        }
                    } else {
                        withAnimation() {
                            viewState.offset = 0
                        }
                    }
                }
        )
    }
}

public struct ViewHeightKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

