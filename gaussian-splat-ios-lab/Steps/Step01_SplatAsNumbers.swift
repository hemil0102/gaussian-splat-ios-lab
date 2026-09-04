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

import SwiftUI
import simd

/// 1단계 화면. 스플랫 하나의 값과 크기를 표로 보여 준다.
struct Step01_SplatAsNumbers: View {
    
    let splat = Splat(position: SIMD3(1, 1, 1), scale: SIMD3(1, 1, 1), rotation: simd_quatf(ix: 1, iy: 1, iz: 1, r: 0.5), opacity: 0.5, sh: SIMD3(1, 1, 1))
    
    var body: some View {
        List {
            Section("position · scale · rotation") {
                row("position.x", String(format: "%.3f", splat.position.x))
                row("position.y", String(format: "%.3f", splat.position.y))
                row("position.z", String(format: "%.3f", splat.position.z))
                row("scale.x", String(format: "%.3f", splat.scale.x))
                row("scale.y", String(format: "%.3f", splat.scale.y))
                row("scale.z", String(format: "%.3f", splat.scale.z))
                row("rotation.w", String(format: "%.3f", splat.rotation.vector.w))
                row("rotation.x", String(format: "%.3f", splat.rotation.vector.x))
                row("rotation.y", String(format: "%.3f", splat.rotation.vector.y))
                row("rotation.z", String(format: "%.3f", splat.rotation.vector.z))
                row("opacity", String(format: "%.3f", splat.opacity))
            }

            Section("spherical harmonics") {
                row("sh.x", String(format: "%.3f", splat.sh.x))
                row("sh.y", String(format: "%.3f", splat.sh.y))
                row("sh.z", String(format: "%.3f", splat.sh.z))

            }

            Section("sizeRows") {
                row("size", "\(MemoryLayout<Splat>.size)")
                row("stride", "\(MemoryLayout<Splat>.stride)")
                row("alignment", "\(MemoryLayout<Splat>.alignment)")
            }
        }
    }
    
    func row(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    Step01_SplatAsNumbers()
}
