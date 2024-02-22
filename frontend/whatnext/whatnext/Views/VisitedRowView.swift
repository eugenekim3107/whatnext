//
//  VisitedRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/21/24.
//

import SwiftUI

struct VisitedRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String
    let userId: String
    @State private var scrollIndex = 0
    @State private var timer: Timer?
    @State private var isManuallyScrolling = false
    
    init(viewModel: LocationRowViewModel, title: String, userId: String) {
        self.viewModel = viewModel
        self.title = title
        self.userId = userId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack (spacing: 5) {
                Image("visited.pin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
            }.padding(.leading)
            if viewModel.isLoading {
                PlaceholderView()
            } else {
                ScrollViewReader { scrollView in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(viewModel.visitedInfo, id: \.businessId) { location in
                                LocationRowSimpleView(location: location)
                            }
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                isManuallyScrolling = true
                                timer?.invalidate()
                            }
                                .onEnded { _ in
                                    isManuallyScrolling = false
                                    startTimer(scrollView: scrollView)
                                }
                        )
                    }
                    .padding([.leading, .trailing])
                    .onAppear {
                        startTimer(scrollView: scrollView)
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchVisitedInfo(userId: userId)
        }
    }
    
    private func startTimer(scrollView: ScrollViewProxy) {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                guard !isManuallyScrolling, viewModel.visitedInfo.count > 0 else { return }
                scrollIndex = (scrollIndex + 1) % viewModel.visitedInfo.count
                scrollView.scrollTo(viewModel.visitedInfo[scrollIndex].businessId, anchor: .leading)
            }
        }
    }
}

struct VisitedRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return VisitedRowView(
            viewModel: viewModel,
            title: "Visited",
            userId: "eugenekim"
        )
    }
}
