//
//  Step03_FirstSplat.swift
//  gaussian-splat-ios-lab / Steps
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  3단계 · ★ 첫 타원체. 2단계 버퍼에 «어느 바이트가 무슨 속성인지» 를 알려 준다.
//
//  1️⃣ 버퍼        2단계 roundTrip 의 쓰기 부분과 같다 (읽기는 이제 GPU 가 한다)
//  2️⃣ descriptor  다섯. stride 는 모두 56, offset 만 다르다
//  3️⃣ BufferResource   다섯을 묶는다. count 를 여기서 말한다 · throws
//  4️⃣ Resource    활성화 함수·정렬·투영 옵션이 여기 붙는다
//  5️⃣ Entity      GaussianSplatComponent 를 달아 content 에 add
//
//  Step03_FirstSplat (View)
//    ├ splats : [Splat]        하나. 0단계 큐브(0.1m)를 잣대로 크기를 잡았다
//    ├ note   : String         화면에 띄울 «몇 개 · 어떤 값 · 실패했으면 왜»
//    ├ body                    RealityView + 아래쪽에 note
//    └ makeSplatEntity()       1️⃣~5️⃣ 전부. throws
//
//  ⚠️ 여기서 순서 함정이 터진다 — 버퍼는 (r,x,y,z), simd_quatf 는 (ix,iy,iz,r).
//     SplatBufferLayout 의 floats 가 이미 자리를 바꿔 내보내고 있다.
//
//  📖 자세한 설명 → Docs/Step03_FirstSplat.md
//  ─────────────────────────────────────────────────────────────────────

import SwiftUI
import RealityKit
import Metal
import simd

/// 3단계 화면. 뿌연 타원체 하나.
// 코드 작성: struct Step03_FirstSplat: View


/// 넣을 스플랫. **하나로 시작한다** — 안 보일 때 의심할 곳을 줄이려고.
/// 0단계 큐브가 0.1m 였고 그때 보였으므로, 그 언저리로 잡는다.
// 코드 작성: let splats


/// 화면 아래에 띄울 문장. 「보이는가」만으로는 확인이 안 된다 (규칙 13)
// 코드 작성: @State private var note


/// RealityView 하나 + 아래쪽에 note.
/// 0단계와 같은 모양이다 — 다른 것은 add 하는 엔티티뿐
// 코드 작성: var body


/// 1️⃣~5️⃣ 전부. 버퍼를 만들어 값을 넣고, 다섯 descriptor 로 «읽는 법» 을 알려 주고,
/// 리소스와 컴포넌트를 달아 엔티티로 돌려준다.
///
/// 입력  splats (프로퍼티)
/// 출력  GaussianSplatComponent 가 달린 Entity
/// 실패  버퍼 만들기 · BufferResource 만들기 둘 다 throws → 부르는 쪽에서 note 로
// [SRP] 화면은 add 만 하고, 버퍼·리소스 조립은 전부 여기
// 코드 작성: func makeSplatEntity() throws -> Entity
