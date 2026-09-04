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
//    ├ splats     : [Splat]    셋. 하나로는 그려지지 않는다 (PROBLEMS P4)
//    ├ note       : String     몇 개 · 어떤 값 · 실패했으면 왜
//    ├ deviceNote : String     GPU · apple7 · iOS — 조용히 실패할 때의 첫 용의자
//    ├ body                    RealityView + 아래쪽 두 줄
//    └ makeSplatEntity()       1️⃣~5️⃣ 전부. throws
//
//  ⚠️ 여기서 터질 뻔한 함정 — 버퍼는 (r,x,y,z), simd_quatf 는 (ix,iy,iz,r).
//     SplatBufferLayout 의 floats 가 이미 자리를 바꿔 내보내 막았다.
//
//  📖 자세한 설명 → Docs/Step03_FirstSplat.md
//  ─────────────────────────────────────────────────────────────────────

import SwiftUI
import RealityKit
import Metal
import simd
import UIKit

/// 3단계 화면. 뿌연 타원체 셋.
struct Step03_FirstSplat: View {
    
    /// 넣을 스플랫 셋. **하나로는 그려지지 않는다** (PROBLEMS P4)
    /// 세 축으로 벌려 두어야 색·자리·깊이를 한 화면에서 가릴 수 있다
    let splats: [Splat] = [
        Splat(position: SIMD3(-0.25, -0.25, -0.25), scale: SIMD3(0.16, 0.04, 0.04),
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
              opacity: 1.0, sh: SIMD3(2.0, -0.5, -0.5)),

        Splat(position: SIMD3( 0.25,  0.25, 0.25), scale: SIMD3(0.16, 0.04, 0.04),
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
              opacity: 1.0, sh: SIMD3(-0.5, -0.5, 2.0)),
        
        Splat(position: SIMD3(0.25, 0, 0), scale: SIMD3(0.16, 0.04, 0.04),
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
              opacity: 1.0, sh: SIMD3(-0.5, 2.0, -0.5))
    ]
    
    @State private var note = "준비 중"
    
    /// GPU · apple7 · iOS. 스플랫이 «조용히» 안 나올 때의 첫 용의자다
    ///
    /// `let` 이라 한 번만 계산된다 — 계산 프로퍼티로 두면 화면을 다시 그릴 때마다
    /// MTLDevice 를 새로 만든다
    let deviceNote: String = {
        let device = MTLCreateSystemDefaultDevice()
        let apple7 = device?.supportsFamily(.apple7) ?? false
        return "\(device?.name ?? "GPU 없음") · apple7 \(apple7 ? "O" : "X") · iOS \(UIDevice.current.systemVersion)"
    }()
    
    /// RealityView 하나 + 아래쪽에 두 줄짜리 상태 표시
    var body: some View {
        
        RealityView { content in
            content.camera = .spatialTracking

            do {
                content.add(try makeSplatEntity())
                note = "스플랫 \(splats.count)개 · scale(0.16, 0.04, 0.04)"
            } catch {
                note = "실패 - \(error)"
            }
        }
        .overlay(alignment: .bottom) {
            // ⚠️ .overlay 의 내용물은 ZStack 이다 — 뷰를 둘 넣으면 «겹친다».
            //    나란히 놓으려면 VStack 으로 직접 묶어야 한다
            VStack(spacing: 2) {
                Text(note)
                Text(deviceNote)
            }
            .font(.caption)
            .padding(8)
            .background(.black.opacity(0.5))
            .foregroundStyle(.white)
        }
        .background(.black)
    }
    
    func makeSplatEntity() throws -> Entity {
        
        let t0 = CFAbsoluteTimeGetCurrent()
        defer { print("⏱ makeSplatEntity \((CFAbsoluteTimeGetCurrent() - t0) * 1000) ms") }
        
        for c in [16, 32, 40, 48, 56, 57, 60, 64, 72, 88, 100, 112, 168, 176] {
            do {
                _ = try LowLevelBuffer(descriptor: .init(capacity: c, sizeMultiple: 1))
                print("✅ capacity \(c)")
            } catch {
                print("❌ capacity \(c)")
            }
        }
        
        // 1️⃣ 버퍼 — 2단계의 «쓰기» 와 똑같다. 읽는 쪽이 GPU 로 바뀌었을 뿐
        let stride = SplatBufferLayout.bytesPerSplat
        let total = stride * splats.count
        let capacity = (total + 15) & ~0xF
        let buffer = try LowLevelBuffer(
            descriptor: .init(capacity: capacity, sizeMultiple: stride))
        
        buffer.withUnsafeMutableBytes { raw in
            for (index, splat) in splats.enumerated() {
                let base = index * stride
                for (i, value) in splat.floats.enumerated() {
                    raw.storeBytes(of:value,
                                   toByteOffset: base + i * MemoryLayout<Float>.stride,
                                   as: Float.self
                    )
                }
            }
        }
        
        buffer.bytesUsed = total
        
        // 2️⃣ descriptor 다섯 — 같은 버퍼, 같은 stride, offset 만 다르다
        func descriptor(_ format: MTLAttributeFormat,
                        _ offset: Int) -> GaussianSplatResource.BufferDescriptor {
            .init(buffer: buffer, format: format, stride: stride, offset: offset)
        }
        
        // 3️⃣ 다섯을 묶는다. 개수를 여기서 말한다 · throws
        let bufferResource = try GaussianSplatResource.BufferResource(
            count: splats.count,
            position: descriptor(.float3, SplatBufferLayout.positionOffset),
            scale: descriptor(.float3, SplatBufferLayout.scaleOffset),
            rotation: descriptor(.float4, SplatBufferLayout.rotationOffset),
            opacity: descriptor(.float,  SplatBufferLayout.opacityOffset),
            sphericalHarmonics: (descriptor(.float3, SplatBufferLayout.shOffset), .zero))
        
        // 4️⃣ 옵션 — 우리 값은 이미 최종값이라 되돌릴 것이 없다 (STUDY Q7)
        let resource = GaussianSplatResource(bufferResource)
        resource.scaleActivation = .identity
        resource.opacityActivation = .identity
        resource.projectionMode = .tangential   // 문서상 «아티팩트를 줄인다». 눈에 띄는 차이는 못 봤음
        
        // 5️⃣ 엔티티에 달아 돌려준다
        let entity = Entity()
        
        entity.components.set(GaussianSplatComponent(resource))
        return entity
    }
}

#Preview {
    Step03_FirstSplat()
}
