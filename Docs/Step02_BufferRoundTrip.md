# 2단계 · 버퍼에 넣고 다시 꺼내기

`Shared/SplatBufferLayout.swift` 와 `Steps/Step02_BufferRoundTrip.swift` 의 설명서입니다.

**⏱ 30분. 아직 3D 는 안 나옵니다.** 표가 두 열로 늘어나는 게 전부예요.

---

## 핵심

**바이트를 처음 만지는 자리입니다. 그래서 «그리기» 를 일부러 뺐습니다.**

3D 렌더링까지 한꺼번에 하면 화면이 비었을 때 «변환이 틀렸나 · 버퍼가 틀렸나 · 렌더가 틀렸나» 를 가릴 수 없습니다. **「넣은 값 == 꺼낸 값」 을 먼저 통과시켜 두면 3단계에서 의심할 곳이 절반으로 줍니다.**

그리고 이 단계는 **1단계에서 본 어긋남을 해결하는 자리**이기도 합니다.

| | 바이트 |
|---|---|
| 우리 `Splat` (기계가 잰 값) | **80** |
| Apple 이 요구하는 스플랫 하나 | **56** |
| 차이 | **24** |

간격이 다르므로 `Splat` 배열을 통째로 복사(`memcpy`)할 수 없습니다. **값을 하나씩 옮기는 변환 함수**가 필요한 이유입니다.

---

## 만들 파일 둘 (+ 고칠 파일 하나)

| 파일 | 무엇 |
|---|---|
| `Shared/SplatBufferLayout.swift` | `Splat` ↔ `[Float]` 변환. **8·9단계 파서까지 그대로 씁니다** |
| `Steps/Step02_BufferRoundTrip.swift` | 두 열을 나란히 놓는 화면 |
| `ContentView.swift` | 「숫자와 친해지기」 Section 에 항목 하나 더 |

**순서를 지키세요.** `Shared/` 를 먼저 만들어야 화면 코드에서 자동완성이 도와줍니다.

---

## 설계 대화에서 정한 것 — 「C · 변환 함수」

셋 중에서 골랐습니다.

| | 방식 | 왜 안 골랐나 / 골랐나 |
|---|---|---|
| A | 화면 안에서 값을 한 개씩 버퍼에 넣기 | 화면이 바이트 배치까지 아는 게 됩니다. 3단계에서 그대로 복사해야 하고요 |
| B | `Splat` 을 전부 `Float` 로 풀어 **정확히 56바이트**로 다시 만들기 | **틀린 답이 아니었습니다.** `memcpy` 가 가능해집니다. 다만 ① `SIMD3`·`simd_quatf` 의 벡터 연산을 잃고 ② 8단계부터 PLY 는 필드 순서가 다르고 활성화 함수가 필요해 **어차피 값별 변환이 생깁니다** — 그러면 memcpy 이점이 사라집니다 |
| **C** | 구조체는 «읽기용» 으로 두고 **변환 함수를 따로** | **골랐습니다.** 「읽기용 표현 / 저장용 표현」을 나누는 흔한 패턴이고, 그 변환 함수가 8·9단계 파서에 그대로 들어갑니다 |

> `Splat` 구조체 자체는 **9단계쯤에서 버립니다.** 실무는 PLY → GPU 버퍼 직행이고 구조체는 선택 사항입니다(50만 개면 40MB 를 만들었다 버리는 셈). 지금 만드는 이유는 하나 — **«내가 정한 배치 vs GPU 가 원하는 배치» 를 몸으로 알기 위해서**입니다.

---

## ⚠️ 막힐 요소 다섯

**정답은 여기 안 적습니다. 대신 «무엇을 해야 하는지» 는 분명히 적습니다** (규칙 1 ⓑ).

### ① 버퍼를 얼마나 크게 잡나

**할 일** — `LowLevelBuffer.Descriptor` 를 만들어 버퍼를 하나 만드는 것.

**왜 문제인가** — 이 서술자가 받는 값은 둘인데, 이름만 보고 뜻을 알기 어렵습니다.

| | Apple 문서의 설명 |
|---|---|
| `capacity` | Length of the buffer in bytes |
| `sizeMultiple` | For variable length buffers, `bytesUsed` needs to be a multiple of this value |

**힌트** — `capacity` 는 «개수» 가 아니라 **바이트**입니다. 스플랫 N 개면 얼마인지 손으로 계산할 수 있습니다. `sizeMultiple` 은 «앞으로 이 버퍼의 사용량이 항상 무엇의 배수일 것인가» 를 말합니다 — 우리 경우 아주 자연스러운 숫자가 하나 있습니다.

**그리고** — 이니셜라이저는 **`throws`** 입니다. `try!` 를 쓰지 마세요. 7단계에서 개수 상한을 알아낼 유일한 통로가 그 에러입니다.

### ② 「쓰기」 — raw 포인터에 Float 을 놓는 법

**할 일** — `withUnsafeMutableBytes(_:)` 가 주는 포인터에 Float 열넷을, 스플랫마다, 정해진 자리에 놓는 것.

**왜 문제인가** — 받는 것이 `UnsafeMutableRawBufferPointer` 입니다. **raw = 타입이 없는 «그냥 바이트 더미»** 라는 뜻입니다. `pointer[0] = 1.5` 처럼 쓸 수 없어요. 배열이 아니라 바이트 나열이니까요.

**힌트** — 방법이 크게 둘입니다. ⓐ 「이 바이트 자리에 이 타입으로 놓아라」 하고 **한 값씩** 넣는 메서드가 있습니다 ⓑ 바이트 더미를 「여기부터는 Float 배열이라고 치자」고 **타입을 붙여** 쓰는 방법도 있습니다. 문서에서 `UnsafeMutableRawBufferPointer` 의 메서드 목록을 훑어보세요 — `store` 로 시작하는 것과 `bind` 로 시작하는 것이 눈에 띌 겁니다.

**둘째 스플랫은 어디서 시작하나** — 이것이 이 단계의 진짜 문제입니다. 답을 적지 않겠습니다. 1단계에서 잰 세 값 중 **어느 것**이 이 계산에 쓰이는지 생각해 보세요.

### ③ 「읽기」 — 클로저 밖으로 들고 나갈 수 없다

**할 일** — `withUnsafeBytes(_:)` 로 같은 자리에서 값을 꺼내 `readBack` 에 담는 것.

**왜 문제인가** — 문서에 이렇게 적혀 있습니다.

> The buffer provided is only valid for the lifetime of the callback.

**클로저가 끝나면 그 포인터는 죽습니다.** 포인터를 밖의 변수에 넣어 두고 나중에 읽으면 «어제 이사 간 집 주소로 편지 보내기» 가 됩니다. 운이 좋으면 옛날 값이 나오고, 나쁘면 크래시입니다. **클로저 «안에서» 값을 복사해 나와야** 합니다.

### ④ 클로저가 값을 돌려주지 않는다

**할 일** — ③ 에서 꺼낸 값을 함수 밖으로 가져오는 것.

**왜 문제인가** — 선언을 보세요.

```swift
final func withUnsafeBytes(_ callback: (UnsafeRawBufferPointer) -> Void)
```

클로저의 반환 타입이 **`Void`** 입니다. 그래서 이렇게 쓸 수 없습니다.

```swift
let 값들 = buffer.withUnsafeBytes { ... }   // ❌ 아무것도 안 돌려줍니다
```

Swift 표준 라이브러리의 `withUnsafeBytes` 는 결과를 돌려주는데 **이건 다릅니다.** 익숙한 모양이라 오히려 걸리기 쉬운 자리입니다.

**힌트** — 클로저는 자기 바깥의 변수를 «붙잡아» 쓸 수 있습니다. 미리 `var` 를 하나 만들어 두고 클로저 안에서 거기에 담으면 됩니다.

### ⑤ 언제 부르나

**할 일** — `roundTrip()` 을 화면이 뜰 때 **한 번만** 부르는 것.

**왜 문제인가** — `body` 는 화면을 다시 그릴 때마다 통째로 다시 실행됩니다. 스크롤만 해도 버퍼를 새로 만드는 일이 벌어질 수 있어요. 그리고 `body` 안에서는 `@State` 를 바꾸면 안 됩니다 — 「그리는 중에 그릴 내용을 바꾸는」 꼴이라 SwiftUI 가 경고를 냅니다.

**힌트** — 뷰에 붙이는 수식어(modifier) 중에 「나타났을 때」 를 뜻하는 것이 있습니다. 두 종류가 있고 하나는 `async` 를 위한 것입니다.

**그리고 하나 더** — 버퍼에 쓴 다음, 버퍼에게 **실제로 몇 바이트를 썼는지 알려 주는** 프로퍼티가 하나 있습니다(`get set` 입니다). 안 알려 주면 어떻게 되는지는 화면에서 확인해 보세요.

---

## 눈으로 확인하는 법

빌드 성공은 성공이 아닙니다 (규칙 13).

1. **스플랫마다 열네 줄**, 「넣은 값 / 꺼낸 값」 두 열이 **한 줄도 빠짐없이** 같다
2. **둘째 스플랫도** 같다 — 첫째 값이 둘째 자리에 겹쳐 나오지 않는다
3. **`capacity` 가 56 × N** 이다 (스플랫 둘이면 112)
4. **`bytesUsed` 도** 기대한 값이다
5. 한 줄이라도 다르면 **어느 줄인지 화면에서 바로 읽힌다** (✓/✗ 표시)

**2번이 이 단계의 핵심입니다.** 첫째만 맞고 둘째가 어긋나면 «간격(stride)» 을 잘못 잡은 것이고, 그게 3단계에서 화면이 비는 가장 흔한 이유입니다.

### ⭐️ 즉흥 실험 — 읽는 자리를 4바이트만 밀어 보세요

읽을 때의 시작 위치에 **`+ 4`** 를 더해 보세요. 한 글자짜리 수정입니다.

**표가 어떻게 어긋나나요?** 몇 줄이 어긋나나요? 마지막 줄에는 무엇이 나오나요?

그리고 **왜 하필 그렇게** 어긋나는지 생각해 보세요. 답은 적지 않겠습니다.

> 이 장면은 5단계에서 다시 나옵니다. PLY 파일의 헤더 길이를 한 바이트 잘못 세면 정확히 이 모양이 됩니다.

---

## 이 단계가 확인해 주지 «않는» 것

**왕복이 통과해도 순서가 맞다는 뜻은 아닙니다.**

내가 넣은 순서로 내가 꺼내면, 무엇을 넣든 언제나 같습니다. 이 표가 증명하는 것은 **«내 펴기와 내 되돌리기가 서로 짝이 맞는다»** 까지예요.

그 자리가 **Apple 이 원하는 자리인가**는 3단계에서 화면이 답합니다 — 뿌연 타원체가 나오거나, 안 나오거나로요. 미리 걱정하지 말고 지금은 짝만 맞추세요.

---

## 연결

| | |
|---|---|
| 기대는 것 | `Shared/Splat.swift` (1단계) · RealityKit (`LowLevelBuffer`) · simd |
| 불러 쓰는 곳 | `ContentView` 의 「숫자와 친해지기」 Section |
| 준비물 | 없음. 시뮬레이터로도 확인됩니다 (아직 GPU 를 안 씁니다) |
| 다음 단계 | 3단계에서 이 버퍼에 **«어느 바이트가 무슨 속성인지»** 를 알려 줍니다 (`BufferDescriptor` 다섯). 여기서 계산한 자리 값이 그대로 들어갑니다 |

---

## 참고한 Apple 문서

- [LowLevelBuffer](https://developer.apple.com/documentation/realitykit/lowlevelbuffer) — iOS **26** 부터 (다른 스플랫 API 는 27)
- [LowLevelBuffer.Descriptor](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/descriptor-swift.struct) · [init(capacity:sizeMultiple:)](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/descriptor-swift.struct/init(capacity:sizemultiple:))
- [init(descriptor:)](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/init(descriptor:)) — **`throws`**
- [withUnsafeMutableBytes(_:)](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/withunsafemutablebytes(_:)) · [withUnsafeBytes(_:)](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/withunsafebytes(_:)) — 둘 다 클로저 반환 타입이 **`Void`**
- [bytesUsed](https://developer.apple.com/documentation/realitykit/lowlevelbuffer/bytesused) — `get set`
- [UnsafeMutableRawBufferPointer](https://developer.apple.com/documentation/swift/unsafemutablerawbufferpointer) · [UnsafeRawBufferPointer](https://developer.apple.com/documentation/swift/unsaferawbufferpointer)
- [State](https://developer.apple.com/documentation/swiftui/state) · [onAppear(perform:)](https://developer.apple.com/documentation/swiftui/view/onappear(perform:)) · [task(priority:_:)](https://developer.apple.com/documentation/swiftui/view/task(priority:_:))

---

# 따라 칠 코드

> 사용자가 「바로 답 주세요」 라고 하여 채웠습니다 (규칙 1 ⓓ).
>
> ⚠️ **주석은 이 문서보다 `.swift` 쪽이 최신입니다.** 2026-09-04 에 흐름 번호(1️⃣~6️⃣)로 다시 정리했습니다 — 코드 자체는 같습니다.

## 1) `Shared/SplatBufferLayout.swift`

```swift
import SwiftUI
import simd

enum SplatBufferLayout {

    /// 스플랫 하나가 Float 몇 개인가
    static let floatsPerSplat = 14

    /// 그 Float 들이 차지하는 바이트. 14 × 4 = 56
    static let bytesPerSplat = floatsPerSplat * MemoryLayout<Float>.stride

    /// 이 순서가 곧 버퍼 안의 순서다.
    static let fieldNames: [String] = [
        "position.x", "position.y", "position.z",
        "scale.x",    "scale.y",    "scale.z",
        "rotation.r", "rotation.x", "rotation.y", "rotation.z",
        "opacity",
        "sh.r",       "sh.g",       "sh.b",
    ]
}

extension Splat {

    /// Splat → Float 열넷
    var floats: [Float] {
        [
            position.x, position.y, position.z,
            scale.x,    scale.y,    scale.z,
            rotation.real, rotation.imag.x, rotation.imag.y, rotation.imag.z,
            opacity,
            sh.x, sh.y, sh.z,
        ]
    }

    /// Float 열넷 → Splat. `floats` 와 정확히 반대로 꺼낸다.
    init(floats f: [Float]) {
        precondition(f.count == SplatBufferLayout.floatsPerSplat,
                     "Float 이 \(SplatBufferLayout.floatsPerSplat)개여야 합니다")
        self.init(
            position: SIMD3(f[0], f[1], f[2]),
            scale:    SIMD3(f[3], f[4], f[5]),
            rotation: simd_quatf(ix: f[7], iy: f[8], iz: f[9], r: f[6]),
            opacity:  f[10],
            sh:       SIMD3(f[11], f[12], f[13])
        )
    }
}
```

### 여기서 짚을 것 셋

**① `rotation` 의 순서 — 이 다섯 줄이 3단계 함정의 정체입니다**

`simd_quatf` 는 메모리에 **(ix, iy, iz, r)** 순으로 들어 있습니다. 그런데 Apple 버퍼는 **(r, x, y, z)** 를 원해요. 그래서 위 코드는 일부러 **`rotation.real` 을 먼저** 내보내고, 되돌릴 때는 `r: f[6]` 으로 **자리를 바꿔** 받습니다.

`simd_quatf` 의 `.vector` 를 그대로 네 개 쏟아부었다면 왕복은 여전히 통과합니다 — 내가 넣은 순서로 내가 꺼내니까요. **3단계에서 화면이 비었을 때에야** 알게 됩니다. 원래 그 순서로 겪게 하려던 자리였는데, 답을 먼저 드리는 것으로 바꿨으니 여기 적어 둡니다.

**② `bytesPerSplat` 을 56 이라고 안 쓰고 계산한 이유**

`MemoryLayout<Float>.stride` 로 재면 «왜 56인가» 가 코드에 남습니다. 상수 56 은 나중에 half precision(2바이트)으로 바꿀 때 조용히 거짓말이 됩니다.

**③ `init(floats:)` 가 개수를 어떻게 다루나**

`precondition` 은 **틀리면 크래시**입니다. 지금은 내 코드가 내 코드에 넘기는 값이라 이게 맞습니다 — 어긋났다면 그건 버그지 «있을 수 있는 입력» 이 아니니까요. 8단계에서 **파일** 에서 읽은 값을 넘길 때는 `init?(floats:)` (실패할 수 있는 이니셜라이저)로 바꿉니다. 파일은 언제든 깨져 있을 수 있거든요.

---

## 2) `Steps/Step02_BufferRoundTrip.swift`

```swift
import SwiftUI
import simd
import RealityKit

struct Step02_BufferRoundTrip: View {

    /// 값을 눈에 띄게 다르게 — 섞이면 바로 보이도록
    let splats: [Splat] = [
        Splat(position: SIMD3( 0.10,  0.20,  0.30),
              scale:    SIMD3( 0.01,  0.02,  0.03),
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),
              opacity:  0.90,
              sh:       SIMD3(1.00, 0.00, 0.00)),

        Splat(position: SIMD3(-1.50,  2.50, -0.75),
              scale:    SIMD3( 0.40,  0.05,  0.25),
              rotation: simd_quatf(ix: 0.5, iy: -0.5, iz: 0.5, r: 0.5),
              opacity:  0.25,
              sh:       SIMD3(0.00, 0.50, 1.00)),
    ]

    @State private var readBack: [[Float]] = []
    @State private var capacity = 0
    @State private var bytesUsed = 0
    @State private var errorText: String?

    var body: some View {
        List {
            if let errorText {
                Section("에러") {
                    Text(errorText).foregroundStyle(.red)
                }
            }

            ForEach(Array(splats.enumerated()), id: \.offset) { index, splat in
                Section("splat[\(index)] — \(index * SplatBufferLayout.bytesPerSplat)바이트부터") {
                    let put = splat.floats
                    let got = index < readBack.count ? readBack[index] : []

                    ForEach(0 ..< SplatBufferLayout.floatsPerSplat, id: \.self) { i in
                        comparisonRow(SplatBufferLayout.fieldNames[i],
                                      put[i],
                                      i < got.count ? got[i] : nil)
                    }
                }
            }

            Section("버퍼 크기") {
                infoRow("capacity", "\(capacity)")
                infoRow("bytesUsed", "\(bytesUsed)")
                infoRow("기대값 56 × \(splats.count)",
                        "\(SplatBufferLayout.bytesPerSplat * splats.count)")
            }
        }
        .onAppear { roundTrip() }
    }

    /// 이름 · 넣은 값 · 꺼낸 값 · 같은가
    func comparisonRow(_ name: String, _ put: Float, _ got: Float?) -> some View {
        HStack {
            Text(name)
                .font(.system(.caption, design: .monospaced))
            Spacer()
            Text(String(format: "%.3f", put))
            Text("→").foregroundStyle(.secondary)
            Text(got.map { String(format: "%.3f", $0) } ?? "—")
            Image(systemName: got == put ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(got == put ? .green : .red)
        }
        .font(.caption)
        .monospacedDigit()
    }

    func infoRow(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value).monospacedDigit()
        }
    }

    /// 버퍼를 만들고, 써넣고, 다시 읽는다.
    func roundTrip() {
        let stride = SplatBufferLayout.bytesPerSplat      // 56
        let total  = stride * splats.count                // 112

        // ① 버퍼 만들기 — 실패할 수 있다
        let descriptor = LowLevelBuffer.Descriptor(capacity: total, sizeMultiple: stride)

        let buffer: LowLevelBuffer
        do {
            buffer = try LowLevelBuffer(descriptor: descriptor)
        } catch {
            errorText = "버퍼를 만들지 못했습니다 — \(error)"
            return
        }

        // ② 쓰기
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

        // ③ 실제로 쓴 바이트를 알려 준다
        buffer.bytesUsed = total

        // ④ 읽기 — 클로저 «안에서» 담아 나온다
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

        readBack  = got
        capacity  = descriptor.capacity
        bytesUsed = buffer.bytesUsed
    }
}

#Preview {
    Step02_BufferRoundTrip()
}
```

---

## 3) `ContentView.swift` 에 한 줄

```swift
NavigationLink("버퍼에 넣고 다시 꺼내기") {
    Step02_BufferRoundTrip()
}
```

---

## 왜 이렇게 썼나 — 막힐 요소 다섯의 답

### ① `Descriptor(capacity:sizeMultiple:)`

```swift
init(capacity: Int, sizeMultiple: Int = 1)
```

`capacity` 는 **바이트**라서 `56 × 개수`. `sizeMultiple` 은 기본값이 `1` 이라 **안 써도 되지만**, `56` 을 넣어 두면 「이 버퍼의 사용량은 항상 스플랫 단위」라는 뜻이 코드에 남고, 실수로 어중간한 `bytesUsed` 를 넣으면 걸립니다.

### ② `storeBytes(of:toByteOffset:as:)`

`UnsafeMutableRawBufferPointer` 는 **타입이 없는 바이트 더미**라 `raw[0] = 1.5` 가 안 됩니다. 「몇 번째 바이트에, 이 타입으로 놓아라」라고 말해 주는 것이 `storeBytes` 입니다.

**둘째 스플랫의 자리** — `index * 56` 입니다. 1단계에서 잰 셋 중 **`stride`** 를 쓰는 자리예요. `size` 가 아닙니다. 「다음 것이 시작할 수 있는 최소 간격」이 곧 이 계산이니까요. (여기서는 `Float` 이라 `size` 와 `stride` 가 둘 다 4 라 티가 안 나지만, 습관을 `stride` 로 들이는 게 맞습니다)

> `bindMemory(to:)` 로 「여기부터는 `Float` 배열이라 치자」 하고 쓰는 방법도 있습니다. 더 짧아지지만, **이 버퍼의 메모리 타입을 영구히 바꾸는** 동작이라 처음 배울 때는 `storeBytes` 가 안전합니다.

### ③ 포인터를 밖으로 못 들고 나간다

`var got: [[Float]] = []` 를 **클로저 밖에** 만들어 두고, 클로저 **안에서** `got.append(...)` 로 값을 복사해 나옵니다. 포인터 자체는 클로저가 끝나면 죽으니까요.

### ④ 클로저가 `Void` 를 돌려준다

그래서 `let x = buffer.withUnsafeBytes { ... }` 가 아니라 ③ 처럼 **바깥 변수를 붙잡아** 씁니다. Swift 표준 라이브러리의 `withUnsafeBytes` 는 결과를 돌려주는데 이건 다릅니다 — 익숙해서 더 잘 걸리는 자리입니다.

### ⑤ `.onAppear` 와 `bytesUsed`

`body` 안에 계산을 두면 화면을 다시 그릴 때마다 돕니다. `.onAppear { roundTrip() }` 로 «나타났을 때 한 번». (`async` 가 필요하면 `.task` 를 씁니다 — 여기서는 전부 동기라 `.onAppear` 로 충분합니다)

`buffer.bytesUsed = total` 을 빼면 `bytesUsed` 가 `0` 으로 찍힙니다. **값은 멀쩡히 읽힙니다** — 우리가 직접 offset 을 계산해 꺼내니까요. 3단계에서 `BufferResource` 에게 이 버퍼를 넘길 때 비로소 문제가 됩니다. 프레임워크는 「몇 바이트가 유효한가」를 이 값으로 판단하거든요.

### `==` 로 비교해도 되나

**됩니다.** 이번에는 계산을 하지 않고 **바이트를 그대로 넣었다 꺼내기만** 했으니 비트가 한 개도 안 바뀝니다. 부동소수점을 `==` 로 비교하지 말라는 경고는 «계산을 거친 값» 이야기예요. 6단계에서 활성화 함수(`exp`·`sigmoid`)를 돌리기 시작하면 그때부터는 오차 범위로 비교해야 합니다.
