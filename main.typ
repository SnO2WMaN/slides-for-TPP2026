#import "template.typ": *
#import "notation.typ": *

#let Gentzen(L) = $bold(sans("G"))_#L$
#let G3(L) = $bold(sans("G3"))_#L$

#show: slides-theme.with(
  config-info(
    title: [Vibe-formalizing and Formalized Conjectures for Mathematical Logic],
    subtitle: [AI援用による数理論理学の形式化と未解決問題集の作成に関する報告],
    author: [野口 真柊],
    date: [2026/11/16 @ TPP2026],
    url: "https://sno2wman.github.io/slides-for-TPP2026/main.pdf",
    institution: [
      神戸大学システム情報学研究科 M2
    ],
  ),
)

#title-slide()

= はじめに

== 要旨

以下の2点を手短に報告します．
1. AI/LLMを援用した数理論理学のLeanによる形式化の進捗
2. 形式化された未解決問題集の作成について

#grid(
  columns: (1fr, auto),
  column-gutter: 12pt,
  inset: (x: 32pt),
  [
    - FormalizedFormalLogic: #link("https://formalizedformallogic.org/")
    - FFL/Foundation: #link("https://github.com/FormalizedFormalLogic/Foundation")
    - FFL/AlphaCentauri: #link("https://github.com/FormalizedFormalLogic/AlphaCentauri")
  ],
  [
    #qr-code("https://sno2wman.github.io/slides-for-TPP2026/main.pdf", width: 180pt)
  ],
)
#pagebreak()

= AI援用形式化

== Formalized Formal Logic

#text(size: 1.25em)[Formalized Formal Logic (FFL)]
- #link("https://formalizedformallogic.org/")

Lean4での数理論理学の形式化を目的としたプロジェクト．
基本的に自分と齋藤彰悟氏の２人でメンテナンスしています．

- 一階算術
  - Gödelの不完全性定理
- 証明可能性論理
  - Solovayの算術的完全性定理
  - Beklemishevの分類定理 *(AI-assisted!)*
- 集合論
- 様相論理
- etc.

#pagebreak()

算術上のGödelの第1，第2不完全性定理の形式化：

#leancode(links: (
  ("Foundation", "Foundation/FirstOrder/Incompleteness/First.lean"),
  ("Foundation", "Foundation/FirstOrder/Incompleteness/Second.lean"),
))[
  ```lean
  variables (T : ArithmeticTheory) 

  -- Gödel's 1st Incompleteness Theorem
  theorem incomplete [T.Δ₁] [𝗥₀ ⪯ T] [T.SoundOnHierarchy 𝚺 1] : Incomplete T

  -- Gödel's 2nd Incompleteness Theorem
  theorem consistent_unprovable [T.Δ₁] [𝗜𝚺₁ ⪯ T] [Consistent T] : T ⊬ T.consistent.val
  ```
]

詳細やさらなる系は #cite(<SN26>, form: "full") に書いています．
- arXiv: #link("https://arxiv.org/abs/2609.13780")
- 概略のスライド(日本語): #link("https://sno2wman.github.io/slides-for-MGITaPL/main.pdf")

== Beklemishevの分類定理

2026年7月に以下の定理を*AI援用で*形式化した．

#theorem[@Bek90 @Kik16[第6章参照]][
  証明可能性論理は様相論理 $Logic("GL"), Logic("S"), Logic("D")$ の適当な拡張による4つの族で尽くされる．
]


#leancode(links: (
  ("Foundation", "Foundation/FirstOrder/Arithmetic/Bootstrapping/PartialTruth/General.lean"),
))[
  ```lean
  theorem provabilityLogic_classification :
    letI L := T.provabilityLogicRelativeTo U (α := α);
    L = 𝐆𝐋α L.trace ∨
    ∃ hL : L.traceᶜ.Finite, L = 𝐆𝐋β _ hL ∨ L = 𝐃 ∩ 𝐆𝐋β _ hL ∨ L = 𝐒 ∩ 𝐆𝐋β _ hL := by
  ```
]

証明にはKripke意味論と算術上の操作が重要．

#pagebreak()

Kripkeモデルの幾何的な議論をどうLeanで書くのか？*（絵で書いたらほとんど自明）*

#grid(
  columns: (1fr, 30%),
  column-gutter: 1em,
  align: horizon,
  [
    #example[
      モデル $M$ の適当な点 $a$ の前に $k <= omega$ 個の点列を追加する操作を考える．
      このとき，新しいモデル $M'$ について以下が成り立つ．
      - 逆整礎（無限遷移列 $x_1 prec x_2 prec dots.c$ は存在しない）
      - 高さ $height(M')$ は有限個の追加ならせいぜい $height(M) + k$．
      - 論理式の真理値をいい感じに保つ．
    ]
  ],
  {
    let accent = rgb("#d6336c")
    let added = rgb("#2f9e44")
    let arrow-style = (mark: (end: ">", size: .2, fill: black), stroke: .6pt)

    fit-to-width({
      set text(12pt)
      canvas({
        import draw: *

        let pt(name, x, y, color: black) = circle((x, y), radius: .1, name: name, stroke: .7pt + color)
        let arr(a, b, color: black) = line(
          a + ".north",
          b + ".south",
          mark: (end: ">", size: .2, fill: color),
          stroke: .6pt + color,
        )
        // 頂点 `apex` から上に開く三角形で，残りのモデルを表す
        let rest(apex, height, half) = {
          let (x, y) = apex
          line((x, y), (x + half, y + height), (x - half, y + height), close: true, stroke: .7pt)
        }
        let label-a(name) = content(name + ".east", text(fill: accent, $a$), anchor: "west", padding: .12)

        // 左: 高さ h のモデル M（遷移先が上）
        let x = 0
        pt("m0", x, 0)
        pt("m1", x, 1)
        pt("ma", x, 2, color: accent)
        label-a("ma")
        pt("m3", x, 3)
        arr("m0", "m1")
        arr("m1", "ma")
        arr("ma", "m3")
        line("m3.north", (x, 3.35), stroke: .6pt)
        rest((x, 3.35), 1.6, .8)
        content((x, -.7), $M$)

        // 中央: 操作
        content((2.5, 2.9), text(size: 16pt, $arrow.r.double$))

        // 右: a の前に k 個の点の鎖を挿入したモデル M'
        let x = 5.4
        pt("n0", x, 0)
        pt("n1", x, 1)
        pt("k0", x, 2, color: added)
        content((x, 2.9), text(fill: added, $dots.v$))
        pt("k1", x, 3.8, color: added)
        pt("na", x, 4.8, color: accent)
        label-a("na")
        pt("n3", x, 5.8)
        arr("n0", "n1")
        arr("n1", "k0")
        line("k0.north", (x, 2.5), mark: (end: ">", size: .2, fill: added), stroke: .6pt + added)
        line((x, 3.3), "k1.south", mark: (end: ">", size: .2, fill: added), stroke: .6pt + added)
        arr("k1", "na")
        arr("na", "n3")
        line("n3.north", (x, 6.15), stroke: .6pt)
        rest((x, 6.15), 1.2, .6)
        content((x, -.7), $M'$)

        decorations.brace((x + .5, 3.9), (x + .5, 1.9), stroke: .6pt + added)
        content((x + .8, 2.9), text(fill: added, $k$), anchor: "west")
      })
    })
  },
)

これらの操作を形式化するのは地味に面倒（特に整礎性の扱いなど）．
AIが登場するまで難航していた．

== 部分真理定義述語

#proposition[
  1. 任意の算術文 $sigma$ について $PA proves upright("True")(godelize(sigma)) <-> sigma$ となる真理定義述語 $upright("True")(x)$ は定義出来ない．*(Tarski)*
  2. 算術的階層 $Gamma = Sigma_n, Pi_n colon n >= 0$ について，任意の $Gamma$-文 $sigma$ について $PA proves upright("True")_Gamma (godelize(sigma)) <-> sigma$ となる $Gamma$-部分真理定義述語 $upright("True")_Gamma (x)$ は定義出来る．
]

部分真理定義述語 $upright("True")_Gamma (x)$ は応用上の重要な役割を果たすため実際に構成したい．
しかし．．．

#quote(block: true, attribution: [@Kay91])[
  This is the chapter that no one wanted to have to write: the material here is technical and difficult to describe clearly, yet it is very necessary for later work.
]

#pagebreak()

不完全性定理で重要な役割を果たす*証明可能性述語*の構成と同じように，細かいGödel数の操作が要求される．
例えばこれらを地道に構成していき，補題を示していく：

- 有界論理式な論理式のGödel数が与えられたときその形によって真理値モドキ#footnote[対象の論理式のGödel数でない場合は真理値としてどちらでもない値：例えば2とかを割り当てる．]を割り当てていく関数（とそれを表現する論理式）
- 入力が $Gamma$-文のGödel数か？を判定する述語

非常にデリケートな作業ではあるが，やることの方針自体は単純．
ここを手動でコーディングする意義はあまり感じられないので，AIを援用して実際に構成した．

#leancode(links: (
  ("Foundation", "Foundation/FirstOrder/Arithmetic/Bootstrapping/PartialTruth/General.lean"),
))[
  ```lean
  theorem provable_partialTrue_iff_of_hierarchy (T : ArithmeticTheory) (h : ℬ[<, ℒₒᵣ].Hierarchy Γ s σ)  
    : 𝗣𝗔 ⊢ (partialTrue Γ s).val/[⌜h.prenex.val⌝] 🡘 σ
  ```
]

== AlphaCentauri

FormalizedFormalLogicでももう少し積極的に（実験的に）AIを使っていきたい．

#text(size: 1.25em)[FFL/AlphaCentauri]#footnote[@TauCeti にあやかっています．]
- #link("https://github.com/FormalizedFormalLogic/AlphaCentauri")

一階算術に関する諸成果や道具立てを #link("https://github.com/FormalizedFormalLogic/Foundation")[FFL/Foundation] のフレームワークに沿ってまずはAI/LLM援用で形式化するための*実験場*としてのリポジトリ．
- 2026年11月時点，現状のLeanコードは約80k行（うち実際のコードは60k）．

/*
- #cite(<HP93>, form: "full")
- #cite(<Lin97>, form: "full")
*/

== AlphaCentauriのワークフロー

#align(center, block(width: 65%, fit-to-width({
  set text(14pt)
  canvas({
    import draw: *

    let box-style = (stroke: 1pt, radius: .15)

    // 左: AlphaCentauri（Claude などで AI 援用形式化）
    rect((0, 0), (5.6, 2), name: "alpha", ..box-style)
    content("alpha", [FFL/AlphaCentauri])
    content((2.8, -.6), text(size: .8em)[beta version])

    // 形式化に使う AI（Claude，GPT，Gemini など）
    let logo(path) = image(path, height: 1.6em)
    let cy = 3.1
    content((0.4, cy), logo("assets/logos/claude.svg"), anchor: "west")
    content((1.5, cy), logo("assets/logos/chatgpt.svg"), anchor: "west")
    content((2.6, cy), logo("assets/logos/gemini.svg"), anchor: "west")
    content((3.6, cy), text(size: .8em)[or else…], anchor: "west")

    // 矢印
    line((6, 1), (7.7, 1), mark: (end: ">", size: .3, fill: black), stroke: 1.2pt)

    // 右: Foundation（人間がレビュー）
    rect((8.1, 0), (13.7, 2), name: "found", ..box-style)
    content("found", [FFL/Foundation])
    content((10.9, -.6), text(size: .8em)[production-ready])

    // 人間によるレビュー（Material Symbols の visibility）
    content((8.2, cy), text(font: "Material Symbols Outlined", size: 2em, "\u{e8f4}"), anchor: "west")
    content((9.3, cy), text(size: .85em)[Human writing/reviewed], anchor: "west")
  })
})))

// 図は固定し，下のテキストだけを切り替える（図が動かないよう高さを固定）
#block(
  width: 100%,
  height: 6em,
  alternatives[
    AI/LLM製のコードを野放図にFFL/Foundationに入れるのは避けたい．
    - AI製のポン出しのコードには数学的・コード的に余計・冗長な補題や定義，実装などがまだ多い．
    - ライブラリとしての品質や，将来的なリファクタリングのメンテナンスコストが際限無く増えてしまう．
  ][
    AlphaCentauriでは人間半分，AI半分で自動証明
    - 人間の担当箇所: 問題設定，証明の方針や議論全体の設計や切り分け，PRの簡単なレビュー
    - AIの担当箇所: 方針を基に実際にコード量の見積もりや形式証明を書く．

    コードの品質やレビューとかは緩めにやる・やらせている．
  ][
    FFL/AlphaCentauriでの作業を踏まえて，FFL/Foundationに入れても良い(=本番投入)と思ったタイミングでPRを提出．
    人間のちゃんとしたレビューを踏まえてマージする．
  ],
)

== AlphaCentauriの結果

AlphaCentauriによって行われた現在の結果の例：一部はFoundationに移植済み．

- *部分真理定義述語の実際の構成．*
- Parikhの定理: $Arith("I"Sigma_0)$-可証再帰関数の値はせいぜい入力の多項式レベルで抑えられる．
- Parsonの定理: $Arith("I"Sigma_1)$-可証再帰関数のクラスは原始再帰的関数のクラスと等しい．
- Ryll-Nardzewskiの定理: $PA$ は有限公理化不可能．
- 帰納法を制限した算術 $Arith("I"Sigma_n)$: $n >= 1$ は有限公理化可能．
- その他数学的原理を制限した弱い算術 $Arith("I"Sigma_n), Arith("B"Sigma_n), Arith("L"Sigma_n)$ などに関する分析．
- $Arith("IE"_1)$ で $n = 3$ のときのFermatの最終定理が成立するか？*(未解決問題)*#footnote[この問題自体は #link("https://mathbench.ai/en/items/MB15-T4S-P053")[MathBench] ではOpus 5.5とかで解けた & 形式化出来たと主張しているが，実際にコードを提出してないので勝手に解いて置いておいた．MathBenchでは多分Mathlibのフレームワークを使っている．]

= 未解決問題集

== Formal Conjectures

先行研究として，@FormalConjectures．

- https://github.com/google-deepmind/formal-conjectures
- #link(
    "https://google-deepmind.github.io/formal-conjectures/browse/?subject=Mathematical%20logic%20and%20foundations&category=research%20open",
  )[Mathematical Logic and Foundation (Open)]

数理論理学の分野でFormal Conjecturesに収録されている未解決問題は *28件*．
- 比較: 数論は1248件，組合せ論は523件．
- ただし収録されている問題も計算複雑性，ビジービーバーの問題，集合論的な組合せ論の問題が大半．
  - 一階算術や不完全性定理の未解決問題は無い．

#pagebreak()

余談：なぜこのような状況になっているのか？の推察

1. 数理論理学・形式体系の議論はそもそも形式化にあんまり向いていない．
  - 言語，証明体系，Gödel数のコーディングなどはどう選定するかに大きく依存して非常にデリケート．
    - 汎用的なライブラリとして提供出来ない．
    - 我々のFFLプロジェクトをMathlibに移管しない理由の一つでもある．
2. 数理論理学 $union$ 定理証明支援系のユーザー・専門家がそんなにいない．
  - いたとしても型理論といった方向を向いていて，いわゆる伝統的なロジックをやっている人があまりいない（個人的なイメージ）．
    - 例: Mathlibのメンテナ#footnote[#link("https://github.com/leanprover-community/mathlib4#maintainers")]にもロジックの人はいない（モデル理論の人はいる）．

とはいえこの状況を是正したい．

== AlphaCentauri/Open Problems

#text(size: 1.25em)[FFL/AlphaCentauri/OpenProblems]
- #link("https://formalizedformallogic.org/AlphaCentauri/open-problems")

AlphaCentauriで用意された定義や補題を用いてまだ証明されていない命題を `Prop` の形で置いておく．

#image(height: 60%, "assets/open_problems.png")

#pagebreak()

例えばこのような問題が形式化されて置いてある．

- $Arith("I"Sigma_0)$ は有限公理化可能か？
  #leancode[
    ```lean
    open_problem ISigma0_finiteAxiomatizable := FiniteAxiomatizable 𝗜𝚺₀
    ```
  ]
- Wilkieの問題: $Arith("I"Sigma_0)$ で素数は無限に存在することを証明できるか？
  #leancode[
    ```lean
    open_problem provable_infinitudeOfPrimes_ISigma0 := 𝗜𝚺₀ ⊢ infinitudeOfPrimes
    ```
  ]

#pagebreak()



モチベーション
- そもそも別に形式化されていない未解決問題集もあんまり無い．
- 未解決問題を述べるための定義を整備すること自体もそれなりに大きな作業であるから，意義のある作業だと感じる．

使われ方としての想定
- 正統的な使われ方：実際，数学者がこれらの問題を解いたときにちゃんと自分の証明を形式化して検証したいときに．
- AI/LLM的な使われ方：現行のモデルで解ける可能性の模索．
  - 数論・組合せ論的の問題は計算機のパワープレイで解けてしまう可能性がある．
    - 「難しい」の方向性が新規性よりも計算的膨大さとか厳密性にある類の問題の検証はまさに定理証明支援系に向いている．
  - *研究姿勢としてどうなの？*という議論はあるが．．．
    - 逆説的にパワープレイで解けない問題は本当に難しく取り組む価値がある．．．と言える？

= おわりに

== まとめと所感

以下のことを話しました．
1. AI/LLMを援用した数理論理学のLeanによる形式化の進捗
2. 形式化された未解決問題集の作成について

AI/LLMはMathlibの全てのコードを学習しており(おそらく)，自分が知らなかったようなタクティクや方法の形式証明を書いてくれる．

個人的には，来年(2027年)にはもうそれほど人力で形式証明を書かなくても良い時代が来るのかなとは思う．
- *便利なキーボードとしてのAI/LLM．*
- もちろん*全体的な議論や実装の筋の良さ*みたいなものはまだ人が評価するべきだとは思う．

== 展望

- 数理論理学のLeanでの形式化のデファクトなフレームワークとしてFFLが使われたらうれしい．
- 現状のAI-assistedなワークフローや未解決問題集の作成を算術以外にも横展開できたら良さそう．
  - 様相論理，集合論，直観主義論理/算術，etc.

ロジックの形式化をしている人や資産が*本当に*足りてないので，知的資源およびソフトウェア的な資源で協力してくれる人がいたら助かります．

== 参考文献

#show bibliography: set text(size: 0.75em)
#bibliography(title: none, "references.yml", style: "elsevier-harvard")
