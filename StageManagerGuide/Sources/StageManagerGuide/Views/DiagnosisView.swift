import SwiftUI

@MainActor
struct DiagnosisView: View {
    @EnvironmentObject private var status: StatusModel
    @Binding var selection: AppSection?

    @State private var step = 0
    @State private var answers: [String: Bool] = [:]

    private var symptoms: [Symptom] { DiagnosisContent.symptoms }
    private var isFinished: Bool { step >= symptoms.count }
    private var yesSet: Set<String> { Set(answers.filter { $0.value }.map(\.key)) }

    var body: some View {
        Page(title: "診断", subtitle: "質問に答えると、今の使い方に合った対処が分かります") {
            if isFinished {
                results
            } else {
                questionCard(symptoms[step])
            }
        }
    }

    // MARK: 質問

    private func questionCard(_ symptom: Symptom) -> some View {
        Card {
            ProgressView(value: Double(step), total: Double(symptoms.count)) {
                Text("質問 \(step + 1) / \(symptoms.count)").font(.caption).foregroundStyle(.secondary)
            }
            Text(symptom.question)
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
            Text(symptom.hint).foregroundStyle(.secondary)
            HStack {
                Button("戻る") { step -= 1 }
                    .disabled(step == 0)
                Spacer()
                Button("いいえ") { answer(symptom, false) }
                    .keyboardShortcut("n", modifiers: [])
                Button("はい") { answer(symptom, true) }
                    .keyboardShortcut("y", modifiers: [])
                    .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
            Text("キーボード: Y = はい / N = いいえ").font(.caption).foregroundStyle(.secondary)
        }
    }

    private func answer(_ symptom: Symptom, _ value: Bool) {
        answers[symptom.id] = value
        step += 1
    }

    // MARK: 結果

    private var results: some View {
        let recs = DiagnosisContent.recommendations(for: yesSet)
        return VStack(alignment: .leading, spacing: 20) {
            Card(title: "診断結果", systemImage: "stethoscope") {
                Text(DiagnosisContent.summary(for: yesSet))
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)
                let selected = symptoms.filter { yesSet.contains($0.id) }
                if !selected.isEmpty {
                    Divider()
                    Text("あてはまった症状").font(.subheadline.bold())
                    ForEach(selected) { s in
                        Label(s.question, systemImage: "checkmark.circle")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            ForEach(Array(recs.enumerated()), id: \.element.id) { index, rec in
                recommendationCard(rec, rank: index + 1)
            }

            HStack {
                Button("もう一度診断する") {
                    answers = [:]
                    step = 0
                }
                Button("回答を見直す") { step = symptoms.count - 1 }
            }
        }
    }

    private func recommendationCard(_ rec: Recommendation, rank: Int) -> some View {
        Card {
            HStack(alignment: .firstTextBaseline) {
                Text("\(rank)").font(.title2.bold()).foregroundStyle(Color.accentColor)
                Text(rec.title).font(.headline)
            }
            Text(rec.detail).fixedSize(horizontal: false, vertical: true)
            HStack {
                if let action = rec.action, !isAlreadyApplied(action) {
                    Button(action.label) { action.perform(with: status) }
                        .buttonStyle(.borderedProminent)
                }
                if let section = rec.section {
                    Button("「\(section.title)」を開く") { selection = section }
                }
            }
        }
    }

    private func isAlreadyApplied(_ action: QuickAction) -> Bool {
        switch action {
        case .disableStageManager: return !status.stageManagerEnabled
        case .enableStageManager: return status.stageManagerEnabled
        case .hideStrip: return status.stripHidden || !status.stageManagerEnabled
        default: return false
        }
    }
}
