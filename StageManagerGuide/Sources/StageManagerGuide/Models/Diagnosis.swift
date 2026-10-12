import Foundation

struct Recommendation: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    var section: AppSection?
    var action: QuickAction?
}

struct Symptom: Identifiable {
    let id: String
    let question: String
    let hint: String
    let recommendations: [Recommendation]
}

enum Recommendations {
    static let turnOff = Recommendation(
        id: "turnOff",
        title: "ステージマネージャをいったんオフにする",
        detail: "不安定さの多くは、オフにしてタイル表示や分割ツールに切り替えるだけで解消します。必要な時だけオンにする運用でも十分です。",
        section: .remedies, action: .disableStageManager)
    static let nativeTiling = Recommendation(
        id: "nativeTiling",
        title: "標準のタイル表示で左右分割する",
        detail: "macOS 15以降なら fn + Control + ← / → で即座に左右分割できます。追加アプリ不要です。",
        section: .remedies)
    static let rectangle = Recommendation(
        id: "rectangle",
        title: "Rectangleを導入する",
        detail: "無料で、ショートカット一発で半分・1/3・4分割に配置できます。macOS 14以前でも使えます。",
        section: .alternatives, action: .openURL("https://rectangleapp.com"))
    static let spaces = Recommendation(
        id: "spaces",
        title: "作業ごとにデスクトップ（操作スペース）を分ける",
        detail: "「資料作成」「連絡」などのセットをデスクトップ単位で分けると、ステージマネージャなしでも作業切替ができます。自動並べ替えはオフにしておくと迷いません。",
        section: .remedies, action: .openMissionControl)
    static let hideStrip = Recommendation(
        id: "hideStrip",
        title: "左のアプリ一覧（ストリップ）を隠す",
        detail: "ステージマネージャは使いつつ、画面の左端を広く使えます。ポインタを左端に寄せると一覧が出ます。",
        section: .home, action: .hideStrip)
    static let fixSpacesOrder = Recommendation(
        id: "fixSpacesOrder",
        title: "操作スペースの自動並べ替えをオフにする",
        detail: "「デスクトップとDock」>「Mission Control」で設定。デスクトップの順番が勝手に変わるのを防ぎ、Mission Controlとの混乱を減らします。",
        section: .remedies, action: .openDesktopSettings)
    static let separateDisplays = Recommendation(
        id: "separateDisplays",
        title: "ディスプレイ接続後は一度ステージマネージャを切り替え直す",
        detail: "外部ディスプレイ接続やスリープ復帰で崩れた場合、オフ→オンで再配置されることがあります（効果は環境次第）。",
        section: .home)
    static let keyboardTool = Recommendation(
        id: "keyboardTool",
        title: "キーボード中心ならRectangleかRaycast",
        detail: "どちらもショートカットで配置できます。ランチャーも使いたいならRaycast、分割だけならRectangleが軽量です。",
        section: .alternatives)
}

enum DiagnosisContent {
    static let symptoms: [Symptom] = [
        Symptom(
            id: "groupsBreak",
            question: "アプリを切り替えると、まとめていたウインドウのグループが崩れますか？",
            hint: "Command+Tabやクリックで切り替えた時に、ウインドウが別のステージに分かれる・勝手に合流する",
            recommendations: [Recommendations.turnOff, Recommendations.spaces]),
        Symptom(
            id: "lag",
            question: "ステージ切替のアニメーションが遅い・カクつきますか？",
            hint: "切り替えのたびに一瞬待たされる感覚がある",
            recommendations: [Recommendations.turnOff, Recommendations.nativeTiling]),
        Symptom(
            id: "missionControl",
            question: "Mission Controlやデスクトップ移動の後に表示がおかしくなりますか？",
            hint: "ステージの並びが乱れる、ウインドウが見つからなくなる",
            recommendations: [Recommendations.fixSpacesOrder, Recommendations.turnOff]),
        Symptom(
            id: "externalDisplay",
            question: "外部ディスプレイの接続やスリープ復帰の後にレイアウトが崩れますか？",
            hint: "ウインドウ位置やグループがリセットされる",
            recommendations: [Recommendations.separateDisplays, Recommendations.rectangle]),
        Symptom(
            id: "splitOnly",
            question: "本当にやりたいのは「2つのアプリを左右に並べる」ことですか？",
            hint: "例：電子カルテの横に資料、ブラウザの横にメモ",
            recommendations: [Recommendations.nativeTiling, Recommendations.rectangle]),
        Symptom(
            id: "stripSpace",
            question: "左側のアプリ一覧が邪魔、または画面が狭く感じますか？",
            hint: "ノートPCの画面で特に気になる",
            recommendations: [Recommendations.hideStrip]),
        Symptom(
            id: "keyboard",
            question: "マウスよりキーボードで素早く操作したいですか？",
            hint: "ショートカットで配置を完結させたい",
            recommendations: [Recommendations.keyboardTool, Recommendations.nativeTiling]),
    ]

    /// 回答から推奨アクションを重複なく、出現回数の多い順に並べる。
    static func recommendations(for yes: Set<String>) -> [Recommendation] {
        var score: [String: Int] = [:]
        var order: [Recommendation] = []
        for symptom in symptoms where yes.contains(symptom.id) {
            for (index, rec) in symptom.recommendations.enumerated() {
                if score[rec.id] == nil { order.append(rec) }
                // 各症状の先頭の推奨ほど重みを高くする
                score[rec.id, default: 0] += symptom.recommendations.count - index
            }
        }
        return order.enumerated()
            .sorted { lhs, rhs in
                let l = score[lhs.element.id] ?? 0
                let r = score[rhs.element.id] ?? 0
                return l == r ? lhs.offset < rhs.offset : l > r
            }
            .map(\.element)
    }

    static func summary(for yes: Set<String>) -> String {
        if yes.isEmpty {
            return "大きな問題は見つかりませんでした。今の使い方を続けて、気になる症状が出たら再診断してください。"
        }
        let unstable: Set<String> = ["groupsBreak", "lag", "missionControl", "externalDisplay"]
        let unstableCount = yes.intersection(unstable).count
        if yes.contains("splitOnly") && unstableCount > 0 {
            return "目的が「左右分割」で、不安定さも出ています。ステージマネージャをオフにして、タイル表示またはRectangleに切り替えるのが最短です。"
        }
        if unstableCount >= 2 {
            return "不安定さの症状が複数あります。まずステージマネージャをオフにし、作業の切り替えはデスクトップ（操作スペース）で行う運用を試してください。"
        }
        if yes.contains("splitOnly") {
            return "ステージマネージャより、分割配置の仕組みの方が目的に合っています。"
        }
        return "症状に合わせた対処を上から順に試してください。"
    }
}
