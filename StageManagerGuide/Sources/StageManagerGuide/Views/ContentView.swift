import SwiftUI

@MainActor
struct ContentView: View {
    @State private var selection: AppSection? = .home

    var body: some View {
        NavigationSplitView {
            List(AppSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.icon)
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
        } detail: {
            switch selection ?? .home {
            case .home: HomeView(selection: $selection)
            case .explanation: ExplanationView()
            case .remedies: RemediesView()
            case .alternatives: AlternativesView()
            case .diagnosis: DiagnosisView(selection: $selection)
            }
        }
    }
}
