import SwiftUI

/// 情報の根拠の強さ。事実と推測を区別して表示するために使う。
enum Confidence: String {
    case established = "確立"
    case likely = "有力"
    case speculation = "推測"

    var color: Color {
        switch self {
        case .established: return .green
        case .likely: return .orange
        case .speculation: return .gray
        }
    }

    var help: String {
        switch self {
        case .established: return "Apple公式の情報や、誰でも再現できる仕様"
        case .likely: return "コミュニティで多数報告されているが、公式な説明はない"
        case .speculation: return "原因についての推測。確証はない"
        }
    }
}

struct InfoItem: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let confidence: Confidence
}

struct Shortcut: Identifiable {
    let id = UUID()
    let keys: String
    let action: String
}

struct AlternativeTool: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let summary: String
    let strengths: [String]
    let caveats: String
    let url: String
    let brew: String?
}

enum GuideContent {
    // MARK: 解説

    static let background: [InfoItem] = [
        InfoItem(
            title: "ステージマネージャは macOS Ventura（13）で登場",
            body: "作業中のウインドウを中央に、それ以外のアプリを左側に縮小表示して切り替える仕組み。コントロールセンターまたは「デスクトップとDock」からオン／オフできる。",
            confidence: .established),
        InfoItem(
            title: "操作スペース（Spaces）ごとに独立して動く",
            body: "ステージマネージャは各デスクトップ（操作スペース）の中でグループを管理する。Mission Controlとは別の仕組みが重なって動いている。",
            confidence: .established),
        InfoItem(
            title: "macOS Sequoia（15）で標準のタイル表示が追加",
            body: "ウインドウを画面端へドラッグする、Optionを押しながらドラッグする、メニューの「ウインドウ」>「移動とサイズ変更」などで左右分割・4分割ができるようになった。ステージマネージャとは別機能。",
            confidence: .established),
    ]

    static let commonIssues: [InfoItem] = [
        InfoItem(
            title: "グループが崩れる・勝手に分かれる",
            body: "Command+Tabやクリックでアプリを切り替えた際、まとめていたウインドウが別ステージに分かれる、または意図せず合流する。",
            confidence: .likely),
        InfoItem(
            title: "切り替え時のラグ・カクつき",
            body: "ステージ切替のアニメーションが遅い、外部ディスプレイや高解像度環境で引っかかる感覚がある。",
            confidence: .likely),
        InfoItem(
            title: "Mission Control・操作スペースとの競合",
            body: "Mission Controlを開いた後や、デスクトップ移動後にステージの並びや表示が乱れる。フルスクリーンアプリとの行き来で特に起きやすいと報告されている。",
            confidence: .likely),
        InfoItem(
            title: "外部ディスプレイ接続・スリープ復帰後のレイアウト崩れ",
            body: "ディスプレイの抜き差しやスリープ復帰で、ウインドウ位置やグループがリセットされる。",
            confidence: .likely),
        InfoItem(
            title: "タイル表示との相性",
            body: "macOS 15以降、画面端ドラッグのタイル表示とステージマネージャの挙動が重なり、ウインドウが想定外の位置に移動することがある。",
            confidence: .likely),
    ]

    static let causes: [InfoItem] = [
        InfoItem(
            title: "ウインドウ管理機能の追加が重なり、挙動が複雑になった",
            body: "ステージマネージャ・Mission Control・操作スペース・タイル表示という複数の仕組みが同じウインドウを扱うため、アップデートで一部の挙動が変わると相互作用で崩れやすい。",
            confidence: .speculation),
        InfoItem(
            title: "アニメーションと描画の負荷",
            body: "縮小サムネイルの常時更新やアニメーションが、外部ディスプレイや多数のウインドウ環境で負荷になっている可能性がある。",
            confidence: .speculation),
        InfoItem(
            title: "多くの人には「左右分割」で十分なケースが多い",
            body: "ステージマネージャの目的は「作業セットの切替」。2〜3アプリを並べるだけなら、タイル表示や分割ツールの方が操作数が少ない。",
            confidence: .speculation),
    ]

    // MARK: 対処法

    static let disableSteps: [String] = [
        "メニューバー右上のコントロールセンター（スイッチ型アイコン）をクリック",
        "「ステージマネージャ」のボタンをクリックしてオフにする",
        "または：アップルメニュー >「システム設定」>「デスクトップとDock」>「ステージマネージャ」をオフ",
        "このアプリのホーム画面・メニューバーからもワンクリックで切り替え可能",
    ]

    static let tilingSteps: [String] = [
        "ウインドウを画面の左端／右端までドラッグすると半分サイズで配置される",
        "Optionキーを押しながらドラッグすると、配置先のプレビューがすぐ表示される",
        "緑の全画面ボタンにポインタを乗せると、配置の候補メニューが出る",
        "メニューバーの「ウインドウ」>「移動とサイズ変更」からも選べる",
        "設定は「デスクトップとDock」>「ウインドウ」の項目で変更できる",
    ]

    static let tilingShortcuts: [Shortcut] = [
        Shortcut(keys: "fn(🌐) + Control + ← / →", action: "左半分／右半分に配置"),
        Shortcut(keys: "fn(🌐) + Control + ↑ / ↓", action: "上半分／下半分に配置"),
        Shortcut(keys: "fn(🌐) + Control + Shift + ← / →", action: "前面2つのウインドウを左右に並べる"),
        Shortcut(keys: "fn(🌐) + Control + F", action: "画面いっぱいに広げる（フルスクリーンではない）"),
        Shortcut(keys: "fn(🌐) + Control + C", action: "画面中央に配置"),
        Shortcut(keys: "fn(🌐) + Control + R", action: "元のサイズに戻す"),
    ]

    static let spacesSteps: [String] = [
        "Control + ↑（またはF3）でMission Controlを開く",
        "画面上部の「＋」で新しいデスクトップ（操作スペース）を追加",
        "Control + ← / → でデスクトップ間を移動、Control + 数字で直接移動（キーボード設定で有効化）",
        "Dockのアプリを右クリック >「オプション」>「割り当て先」で、アプリを特定のデスクトップに固定",
        "「デスクトップとDock」>「Mission Control」で「最新の使用状況に基づいて操作スペースを自動的に並べ替える」をオフにすると、並び順が固定され迷いにくい",
    ]

    static let spacesShortcuts: [Shortcut] = [
        Shortcut(keys: "Control + ↑", action: "Mission Control"),
        Shortcut(keys: "Control + ↓", action: "アプリケーションウインドウ（同じアプリの一覧）"),
        Shortcut(keys: "Control + ← / →", action: "前／次のデスクトップへ"),
        Shortcut(keys: "Command + Tab", action: "アプリ切替"),
        Shortcut(keys: "Command + `", action: "同じアプリ内のウインドウ切替"),
    ]

    // MARK: 代替ツール

    static let tools: [AlternativeTool] = [
        AlternativeTool(
            name: "Rectangle",
            price: "無料（オープンソース）",
            summary: "キーボードショートカットとドラッグで、ウインドウを半分・1/3・4分割などに配置する定番ツール。",
            strengths: ["無料で広く使われている", "Control + Option + 矢印など、覚えやすい既定ショートカット", "画面端ドラッグでのスナップにも対応"],
            caveats: "アクセシビリティ権限が必要（ウインドウを動かすため）。",
            url: "https://rectangleapp.com",
            brew: "brew install --cask rectangle"),
        AlternativeTool(
            name: "Magnet",
            price: "有料（Mac App Store）",
            summary: "Mac App Storeで買える分割ツール。設定が少なく、入れてすぐ使える。",
            strengths: ["App Store経由で導入・更新が簡単", "シンプルで迷わない"],
            caveats: "機能はRectangleとほぼ同等。アクセシビリティ権限が必要。",
            url: "https://magnet.crowdcafe.com",
            brew: nil),
        AlternativeTool(
            name: "BetterTouchTool",
            price: "有料（試用期間あり）",
            summary: "トラックパッドのジェスチャ、キーボード、マウスの操作を自由に割り当てられる多機能ツール。ウインドウ分割も可能。",
            strengths: ["ジェスチャで分割など、操作を自分好みに作り込める", "ウインドウ管理以外の自動化にも使える"],
            caveats: "機能が多く、設定に時間がかかる。",
            url: "https://folivora.ai",
            brew: "brew install --cask bettertouchtool"),
        AlternativeTool(
            name: "Raycast",
            price: "無料（一部有料プラン）",
            summary: "ランチャーアプリ。標準の「Window Management」コマンドで分割配置ができる。",
            strengths: ["ランチャー・クリップボード履歴などと一体で使える", "コマンド名で検索して配置できる"],
            caveats: "ウインドウ管理専用ではない。",
            url: "https://www.raycast.com",
            brew: "brew install --cask raycast"),
        AlternativeTool(
            name: "Amethyst",
            price: "無料（オープンソース）",
            summary: "ウインドウを自動でタイル状に並べるタイル型ウインドウマネージャ。",
            strengths: ["開いたウインドウが自動で整列", "キーボード中心の操作"],
            caveats: "自動配置に慣れが必要。上級者向け。",
            url: "https://github.com/ianyh/Amethyst",
            brew: "brew install --cask amethyst"),
    ]
}
