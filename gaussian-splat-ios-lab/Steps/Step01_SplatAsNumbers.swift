//
//  Step01_SplatAsNumbers.swift
//  gaussian-splat-ios-lab / Steps
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  1단계 · 스플랫 하나를 «숫자로» 본다. 3D 는 안 나온다.
//  Shared/Splat.swift 의 값 열넷을 화면에 표로 찍고, 크기를 재서 비교한다.
//
//  Step01_SplatAsNumbers (View)
//    ├ splat : Splat                  Splat.sample 을 그대로 씀
//    ├ body                           List 하나. 아래 세 Section
//    │   ├ valueRows                  값 열넷 — 이름 · 값 · 몇 개
//    │   ├ quaternionOrder            rotation 의 실제 메모리 순서
//    │   └ sizeRows                   손으로 센 56 vs MemoryLayout 이 말하는 값
//    └ row(_:_:)                      한 줄을 그리는 작은 도우미
//
//  메시지 경로
//    Splat.sample → splat → valueRows / quaternionOrder → 화면
//    MemoryLayout<Splat> → sizeRows → 화면
//
//  이 단계의 수확은 «숫자가 예쁘게 찍히는 것» 이 아니라
//  «손으로 센 것과 기계가 잰 것이 다르다» 를 화면에서 보는 것이다.
//
//  📖 자세한 설명 → Docs/Step01_SplatAsNumbers.md
//  ─────────────────────────────────────────────────────────────────────

// 코드 작성: import 두 줄


/// 1단계 화면. 스플랫 하나의 값과 크기를 표로 보여 준다.
// 코드 작성: struct Step01_SplatAsNumbers: View


    /// 화면에 찍을 스플랫 하나.
    // 코드 작성: splat


    /// 화면. List 안에 Section 셋.
    // 코드 작성: body


    /// 값 열넷을 이름·값·개수로 보여 주는 Section.
    ///
    /// position 3 · scale 3 · rotation 4 · opacity 1 · sh 3 = 14
    // 코드 작성: valueRows


    /// rotation 이 «메모리에 어떤 순서로» 담겨 있는지 보여 주는 Section.
    ///
    /// simd_quatf 의 vector 속성을 꺼내 네 값을 그대로 찍으면 된다.
    /// 만들 때 넣은 값과 찍힌 순서를 비교하는 것이 목적이다.
    // 코드 작성: quaternionOrder


    /// 크기를 재서 비교하는 Section.
    ///
    /// 손으로 센 것 : Float 14개 × 4바이트 = 56
    /// 기계가 잰 것 : MemoryLayout<Splat> 의 size · stride · alignment
    /// 둘이 다르면 그 차이가 이 단계의 수확이다.
    // 코드 작성: sizeRows


    /// 「이름 ─── 값」 한 줄을 그리는 도우미.
    ///
    /// 같은 모양이 열몇 번 반복되므로 한 곳에 모아 둔다. [SRP]
    // 코드 작성: row(_:_:)


// 코드 작성: struct 를 닫는 중괄호와 #Preview
