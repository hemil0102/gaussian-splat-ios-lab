//
//  Step02_BufferRoundTrip.swift
//  gaussian-splat-ios-lab / Steps
//
//  ─── 지도 ────────────────────────────────────────────────────────────
//
//  2단계 · LowLevelBuffer 에 써넣고 그대로 꺼낸다. 아직 그리지 않는다.
//
//  ★ 버퍼를 «옮기는» 일은 전부 roundTrip() 안에 있다. body 는 결과만 그린다.
//
//  1️⃣ splats        [Splat] 2개          사람이 읽는 모양 · 하나가 80바이트
//  2️⃣ .floats       Splat → [Float] 14   편다 (SplatBufferLayout)
//  3️⃣ storeBytes    [Float] → 버퍼       ★ 옮기는 자리. base + i×4 에 한 값씩
//  4️⃣ bytesUsed     쓴 만큼을 알린다      112
//  5️⃣ load          버퍼 → [Float] 14    ★ 되가져오는 자리. 같은 계산으로 꺼낸다
//  6️⃣ readBack      화면 표의 오른쪽 열   1️⃣ 과 나란히 놓고 ✓/✗
//
//  상태값
//    splats · readBack · capacity · bytesUsed · errorText
//
//  ⚠️ 확인되는 것 — 내가 의도한 자리에 놓고 같은 자리에서 꺼냈다
//     안 되는 것  — 그 자리가 «Apple 이 원하는 자리» 인가. 3단계 화면이 답한다
//
//  📖 자세한 설명 → Docs/Step02_BufferRoundTrip.md
//  ─────────────────────────────────────────────────────────────────────

import SwiftUI
import simd
import RealityKit

/// 2단계 화면. 버퍼 왕복을 표로 확인한다.
struct Step02_BufferRoundTrip: View {

    /// 1️⃣ 넣을 것. **둘 이상** — 하나만 넣으면 «둘째가 어디서 시작하는가» 를 못 본다
    let splats: [Splat] = [
        Splat(position: SIMD3( 0.10, 0.20, 0.30),
              scale: SIMD3( 0.01, 0.02, 0.03),
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
              opacity: 0.90,
              sh: SIMD3(1.00, 0.00, 0.00)),

        Splat(position: SIMD3( -1.50, 2.50, -0.75),
              scale: SIMD3( 0.40, 0.05, 0.25),
              rotation: simd_quatf(ix: 0.5, iy: -0.5, iz: 0.5, r: 0.5),
              opacity: 0.25,
              sh: SIMD3(0.00, 0.50, 1.00)),
    ]

    /// 6️⃣ 버퍼에서 꺼낸 값. `readBack[스플랫번호][필드번호]` — 표의 «꺼낸 값» 열이 이것
    ///
    /// ⭐️GUIDE⭐️ `@State` — 화면이 «뜬 뒤에» 채워지는 값. 바뀌면 SwiftUI 가 다시 그린다
    @State private var readBack: [[Float]] = []

    /// 버퍼가 잡은 바이트 · 그중 쓴다고 알린 바이트
    @State private var capacity = 0
    @State private var bytesUsed = 0

    /// 버퍼 만들기 실패 메시지. `try!` 를 쓰지 않는 이유가 이 한 줄이다
    @State private var errorText: String?

    /// 화면. 그리기만 한다 — 바이트는 만지지 않는다
    var body: some View {
        List {
            if let errorText {
                Section("에러") {
                    Text(errorText).foregroundStyle(.red)
                }
            }

            // 스플랫마다 Section 하나. 제목의 숫자가 «이 스플랫이 버퍼의 몇 바이트째부터인가»
            ForEach(Array(splats.enumerated()), id: \.offset) { index, splat in
                Section("splat[\(index)] - \(index * SplatBufferLayout.bytesPerSplat)바이트 부터") {
                    let put = splat.floats                                   // 넣은 값 (2️⃣)
                    let got = index < readBack.count ? readBack[index] : []  // 꺼낸 값 (6️⃣, 아직 비었을 수 있음)

                    ForEach(0 ..< SplatBufferLayout.floatsPerSplat, id: \.self) { i in
                        comparisonRow(SplatBufferLayout.fieldNames[i], put[i], i < got.count ? got[i] : nil)
                    }
                }
            }

            Section("버퍼 크기") {
                infoRow("capacity", "\(capacity)")
                infoRow("bytesUsed", "\(bytesUsed)")
                infoRow("기대값 56 × \(splats.count)", "\(SplatBufferLayout.bytesPerSplat * splats.count)")
            }
        }
        .onAppear() { roundTrip() }
    }

    /// 한 줄 · 입력 이름·넣은 값·꺼낸 값 → 출력 HStack 한 줄 + ✓/✗
    ///
    /// `==` 로 비교해도 된다 — 계산 없이 바이트를 그대로 넣었다 꺼내기만 했기 때문
    func comparisonRow(_ name: String, _ put: Float, _ got: Float?) -> some View {
        HStack {
            Text(name)
                .font(.system(.caption, design: .monospaced))
            Spacer()
            Text(String(format: "%.3f", put))
            Text("->").foregroundStyle(.secondary)
            Text(got.map { String(format: "%.3f", $0) } ?? "_")
            Image(systemName: got == put ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(got == put ? .green : .red)

        }
        .font(.caption)
        .monospacedDigit()
    }

    /// 크기 표의 한 줄
    func infoRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value).monospacedDigit()
        }
    }

    /// ★ 이 단계의 전부. 버퍼를 만들고 · 옮겨 넣고 · 되가져온다
    ///
    /// 입력  splats (프로퍼티)
    /// 출력  readBack · capacity · bytesUsed · errorText (@State 넷)
    func roundTrip() {
        let stride = SplatBufferLayout.bytesPerSplat      // 56 — 스플랫 하나의 간격
        let total  = stride * splats.count                // 112 — 버퍼 전체

        // 1️⃣ 버퍼 만들기
        //    입력 total(112) · sizeMultiple(56) → 출력 LowLevelBuffer, 또는 에러
        let descriptor = LowLevelBuffer.Descriptor(capacity: total, sizeMultiple: stride)

        let buffer: LowLevelBuffer
        do {
            buffer = try LowLevelBuffer(descriptor: descriptor)
        } catch {
            errorText = "버퍼를 만들지 못했습니다 — \(error)"
            return
        }

        // 2️⃣3️⃣ ★ 옮겨 넣기 — 여기가 «버퍼로 옮기는» 자리다
        //    실제로 예약된 메모리 공간에 데이터 내용물이 채워진다.
        //    입력 splats
        //    과정 스플랫마다 floats 로 펴고(2️⃣), 열넷을 base + i×4 자리에 한 값씩 놓는다(3️⃣)
        //         base = index × 56 → splat[0] 은 0바이트, splat[1] 은 56바이트부터
        //    출력 버퍼 안의 바이트 112개
        buffer.withUnsafeMutableBytes { raw in
            for (index, splat) in splats.enumerated() {
                let base = index * stride
                for (i, value) in splat.floats.enumerated() {
                    raw.storeBytes(of: value,
                                   toByteOffset: base + i * MemoryLayout<Float>.stride,
                                   as: Float.self)
                }
            }
        }

        // 4️⃣ 쓴 만큼 알리기 — 3단계에서 프레임워크가 «몇 바이트가 유효한가» 를 이 값으로 판단한다
        buffer.bytesUsed = total

        // 5️⃣ ★ 되가져오기 — 3️⃣ 과 «똑같은 계산» 으로 꺼낸다. 계산이 어긋나면 표가 어긋난다
        //    입력 버퍼 안의 바이트
        //    출력 got — [[Float]] (스플랫마다 열넷)
        //    ⚠️ raw 는 클로저가 끝나면 죽는다. 그래서 밖의 got 에 «복사해» 나온다
        var got: [[Float]] = []
        buffer.withUnsafeBytes { raw in
            for index in splats.indices {
                let base = index * stride
                var one: [Float] = []
                for i in 0 ..< SplatBufferLayout.floatsPerSplat {
                    one.append(raw.load(fromByteOffset: base + i * MemoryLayout<Float>.stride,
                                        as: Float.self))
                }
                got.append(one)
            }
        }

        // 6️⃣ 화면으로. @State 가 바뀌므로 여기서 body 가 다시 그려진다
        readBack  = got
        capacity  = descriptor.capacity
        bytesUsed = buffer.bytesUsed
    }
}

#Preview {
    Step02_BufferRoundTrip()
}
