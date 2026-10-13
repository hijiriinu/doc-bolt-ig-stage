import SwiftUI

/// 各ページ共通のスクロール枠と見出し。
struct Page<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.largeTitle.bold())
                    Text(subtitle).font(.title3).foregroundStyle(.secondary)
                }
                content()
            }
            .padding(28)
            .frame(maxWidth: 820, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct Card<Content: View>: View {
    var title: String?
    var systemImage: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                if let systemImage {
                    Label(title, systemImage: systemImage).font(.headline)
                } else {
                    Text(title).font(.headline)
                }
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(nsColor: .separatorColor)))
    }
}

@MainActor
struct ConfidenceBadge: View {
    let confidence: Confidence

    var body: some View {
        Text(confidence.rawValue)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .foregroundStyle(confidence.color)
            .background(confidence.color.opacity(0.15), in: Capsule())
            .help(confidence.help)
    }
}

@MainActor
struct InfoItemRow: View {
    let item: InfoItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                ConfidenceBadge(confidence: item.confidence)
                Text(item.title).font(.body.bold())
            }
            Text(item.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

@MainActor
struct StepList: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .frame(width: 20, height: 20)
                        .background(Color.accentColor.opacity(0.15), in: Circle())
                    Text(step).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

@MainActor
struct ShortcutTable: View {
    let shortcuts: [Shortcut]

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            ForEach(shortcuts) { shortcut in
                GridRow {
                    Text(shortcut.keys)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
                    Text(shortcut.action)
                }
            }
        }
    }
}

@MainActor
struct ConfidenceLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            ForEach([Confidence.established, .likely, .speculation], id: \.self) { c in
                HStack(spacing: 6) {
                    ConfidenceBadge(confidence: c)
                    Text(c.help).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}
