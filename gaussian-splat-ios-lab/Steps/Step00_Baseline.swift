//
//  Step00_Baseline.swift
//  gaussian-splat-ios-lab
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  0단계 · 기준선. 스플랫이 안 보일 때 «RealityView 자체가 안 뜬 건지» 를
//  가르기 위한 대조군을 만들어 둔다. 큐브가 보이면 끝.
//
//  Step00_Baseline (View)
//    ├ gpuNote : String        기기의 GPU 패밀리 확인 결과. 화면에 띄운다
//    ├ body                    RealityView 하나 + 그 위에 gpuNote 겹치기
//    │   └ makeCube()          큐브 엔티티를 만들어 돌려준다
//    └ checkGPUFamily()        Apple7 이상인지 확인해 한 줄 문장으로
//
//  메시지 경로
//    body 가 뜰 때 → checkGPUFamily() → gpuNote 에 담김 → 화면에 표시
//    RealityView 클로저 → makeCube() → content 에 add
//
//  ⚠️ iOS 는 클로저가 받는 타입이 visionOS 와 다르다. 그리고 그냥 두면
//     카메라 화면 위에 그리는 모드로 뜬다. 둘 다 Docs 에 적어 뒀다.
//
//  📖 자세한 설명 → Docs/Step00_Baseline.md
//  ─────────────────────────────────────────────────────────────────────

// 코드 작성: import 세 줄 (SwiftUI · RealityKit · Metal)


/// 0단계 화면. RealityKit 이 뜨는지 확인하는 대조군.
///
/// 스플랫은 나오지 않는다. 여기서 큐브가 보였다는 사실이
/// 3단계에서 스플랫이 안 보일 때 «렌더링은 되고 있다» 는 근거가 된다.
// 코드 작성: struct Step00_Baseline: View


    /// 이 기기의 GPU 패밀리 확인 결과를 담는 한 줄 문장.
    ///
    /// 스플랫에는 Apple7 패밀리 이상이 필요하다. 여기서 미리 확인해 두지 않으면
    /// 3단계에서 «코드가 틀린 건지 기기가 안 되는 건지» 를 가릴 수 없다.
    // 코드 작성: gpuNote


    /// 화면. RealityView 를 깔고 그 위에 gpuNote 를 겹친다.
    ///
    /// RealityView 의 클로저 안에서 할 일은 둘이다 —
    /// 카메라 모드를 정하는 것과, 큐브를 넣는 것.
    // 코드 작성: body


    /// 흰 큐브 엔티티 하나를 만들어 돌려준다.
    ///
    /// 크기 감각은 ⭐️ 즉흥 실험에서 직접 찾는다.
    /// 여기서 정한 숫자가 3단계에서 첫 스플랫의 크기를 잡을 때 잣대가 된다.
    // 코드 작성: makeCube()


    /// Apple7 패밀리 이상인지 확인해 화면에 띄울 문장을 만든다.
    ///
    /// Metal 의 기기 객체에게 «이 패밀리를 지원하느냐» 고 물으면 된다.
    // 코드 작성: checkGPUFamily()


// 코드 작성: struct 를 닫는 중괄호와 #Preview
