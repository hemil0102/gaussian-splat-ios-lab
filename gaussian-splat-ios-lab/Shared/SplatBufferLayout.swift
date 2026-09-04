//
//  SplatBufferLayout.swift
//  gaussian-splat-ios-lab / Shared
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  Splat(80바이트) ↔ Float 열넷(56바이트) 을 오가는 «자와 변환기».
//  실제로 버퍼에 «옮기는» 일은 여기서 하지 않는다 — Step02 의 roundTrip() 이 한다.
//
//  SplatBufferLayout   floatsPerSplat · bytesPerSplat · fieldNames
//  extension Splat     floats(펴기) · init(floats:)(되돌리기)
//
//  ⚠️ 왕복이 통과해도 «Apple 이 원하는 순서» 라는 뜻은 아니다. 순서는 3단계가 답한다.
//
//  📖 자세한 설명 → Docs/Step02_BufferRoundTrip.md
//  ─────────────────────────────────────────────────────────────────────

import SwiftUI
import simd

/// 스플랫 하나를 «버퍼에 넣을 모양» 으로 재는 자.
///
/// ⭐️GUIDE⭐️ case 가 없는 `enum` 은 인스턴스를 만들 수 없어 «상수 서랍» 으로 쓴다.
// [SRP] Splat 은 «읽기 좋은 모양», 이 타입은 «저장할 모양»
enum SplatBufferLayout {

    /// 스플랫 하나가 Float 몇 개인가
    static let floatsPerSplat = 14

    /// 그 Float 들이 차지하는 바이트. 14 × 4 = 56
    static let bytesPerSplat = floatsPerSplat * MemoryLayout<Float>.stride

    /// 화면 표에 찍을 이름. ⚠️ 이 순서가 곧 버퍼 안의 순서다 — `floats` 와 같아야 한다
    static let fieldNames: [String] = [
        "position.x", "position.y", "position.z",
        "scale.x", "scale.y", "scale.z",
        "rotation.r", "rotation.x", "rotation.y", "rotation.z",
        "opacity",
        "sh.r", "sh.g", "sh.b"
    ]
    
    static let positionOffset = 0 * MemoryLayout<Float>.stride // 0
    static let scaleOffset = 3 * MemoryLayout<Float>.stride // 12
    static let rotationOffset = 6 * MemoryLayout<Float>.stride // 24
    static let opacityOffset = 10 * MemoryLayout<Float>.stride // 40
    static let shOffset = 11 * MemoryLayout<Float>.stride // 44
}

/// 펴기와 되돌리기.
///
/// ⭐️GUIDE⭐️ `extension` — 원본 파일을 고치지 않고 기능만 덧붙이는 문법.
// [OCP] Splat 을 건드리지 않는다 — 8단계에서 PLY 용 변환이 하나 더 붙을 자리
extension Splat {

    /// 펴기 · 입력 self → 과정 값을 순서대로 늘어놓음 → 출력 `[Float]` 14개
    var floats: [Float] {
        [
            position.x, position.y, position.z,
            scale.x, scale.y, scale.z,
            rotation.real, rotation.imag.x, rotation.imag.y, rotation.imag.z,
            opacity,
            sh.x, sh.y, sh.z
        ]
    }

    /// 되돌리기 · 입력 `[Float]` 14개 → 과정 `floats` 의 역순으로 꺼냄 → 출력 Splat
    ///
    /// ⚠️ rotation 만 자리를 바꿔 받는다 — 버퍼는 (r,x,y,z), `simd_quatf` 는 (ix,iy,iz,r)
    init(floats f: [Float]) {
        // 조건이 틀리면 즉시 강제 종료. 내 코드가 내 코드에 넘기는 값이라 이게 맞다
        // (8단계에서 «파일» 에서 읽은 값을 넘길 때는 init?(floats:) 로 바꾼다)
        precondition(f.count == SplatBufferLayout.floatsPerSplat,
                     "Float 이 \(SplatBufferLayout.floatsPerSplat)개여야 합니다.")

        self.init(
            position: SIMD3(f[0], f[1], f[2]),
            scale: SIMD3(f[3], f[4], f[5]),
            rotation: simd_quatf(ix: f[7], iy: f[8], iz: f[9], r: f[6]),
            opacity: f[10],
            sh: SIMD3(f[11], f[12], f[13])
        )
    }
}
