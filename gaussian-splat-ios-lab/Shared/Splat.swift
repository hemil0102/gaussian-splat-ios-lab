//
//  Splat.swift
//  gaussian-splat-ios-lab / Shared
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  스플랫 «하나» 를 담는 값 타입. 1단계에서 만들어 3단계까지 쓴다.
//
//  Splat (struct)
//    ├ position : SIMD3<Float>   어디에 떠 있나          (x, y, z)
//    ├ scale    : SIMD3<Float>   세 축으로 얼마나 퍼졌나  (x, y, z)
//    ├ rotation : simd_quatf     그 퍼진 방향이 어느 쪽    (ix, iy, iz, r)
//    ├ opacity  : Float          얼마나 진한가            0…1
//    ├ sh       : SIMD3<Float>   무슨 색인가 (SH 0차)     r, g, b
//    └ sample                    화면에 찍어 볼 기본값 하나
//
//  ⚠️ 이 구조체는 «읽기 편하려고» 만든 것이지 «GPU 가 원하는 모양» 이 아니다.
//     Apple 이 요구하는 스플랫 하나는 56바이트인데 이것은 그보다 크다.
//     그 차이를 1단계에서 눈으로 확인하고, 2단계에서 해결한다.
//
//  📖 자세한 설명 → Docs/Step01_SplatAsNumbers.md
//  ─────────────────────────────────────────────────────────────────────

import SwiftUI
import simd

/// 스플랫 하나가 갖는 값 열넷.
///
/// 「뿌연 타원체 하나」 를 만드는 데 필요한 전부다.
/// 중심에서 멀어질수록 옅어지는 3D 얼룩이고, 세 축의 퍼짐이 다르면 타원이 된다.
struct Splat {
    var position: SIMD3<Float>
    var scale: SIMD3<Float>
    var rotation: simd_quatf
    var opacity: Float
    var sh: SIMD3<Float>
}
