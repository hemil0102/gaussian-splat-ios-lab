# 3단계 · ★ 첫 타원체

`Steps/Step03_FirstSplat.swift` 의 설명서입니다. **⏱ 40분. 처음으로 화면에 무언가가 뜹니다.**

---

## 핵심

**2단계 버퍼는 그대로 둡니다. 「어느 바이트가 무슨 속성인지」를 알려 주는 표 다섯 개만 얹으면 그려집니다.**

문서에 한 문장으로 적혀 있습니다 — *"offset 에서 시작해 스플랫마다 stride 만큼 전진한다."* 그래서 **다섯 descriptor 가 같은 버퍼를 offset 만 달리해 공유**합니다.

```
LowLevelBuffer  →  BufferDescriptor × 5  →  BufferResource  →  GaussianSplatResource  →  GaussianSplatComponent
   (2단계)            어디를 읽나            묶고 개수 선언       옵션(활성화 함수 등)        Entity 에 달기
```

| 속성 | offset | format | stride |
|---|---:|---|---:|
| position | 0 | `.float3` | 56 |
| scale | 12 | `.float3` | 56 |
| rotation | 24 | `.float4` | 56 |
| opacity | 40 | `.float` | 56 |
| sphericalHarmonics | 44 | `.float3` | 56 |

우리가 `fieldNames` 로 정해 둔 순서가 그대로 offset 이 됐습니다. **stride 가 다섯 다 56인 것이 「한 버퍼에 인터리브」의 뜻**입니다.

---

## ⚠️ 준비물 — Xcode 27 beta

`GaussianSplatComponent` 는 **iOS 27 부터**입니다. `/Applications/Xcode.app`(26.6)으로 열면 심볼을 못 찾습니다. `~/Downloads/Xcode-beta.app` 으로 여세요.

---

## 설계 대화에서 정한 것 — 활성화 함수 둘 다 `.identity`

`GaussianSplatResource` 는 **활성화 함수** 스위치를 둘 들고 있습니다. 3DGS 는 학습으로 만들어지는데, `scale` 은 양수여야 하고 `opacity` 는 0~1 이어야 해서 **제한 없는 숫자로 저장하고 쓸 때 되돌립니다**(`log`→`exp`, `logit`→`sigmoid`). 그 되돌리기를 고르는 스위치입니다.

우리 값은 손으로 채운 **최종값**이라 되돌릴 것이 없습니다 → 둘 다 `.identity`.

> **8단계에서 정확히 뒤집힙니다.** PLY 원값을 그대로 넘길 때는 `.exponential`·`.sigmoid` 로 바꿔야 해요. 자세한 것은 [STUDY Q7](../STUDY.md).

---

## ⚠️ 막힐 요소 넷

### ① `format` 이 Metal 타입이다

`BufferDescriptor(buffer:format:stride:offset:)` 의 `format` 은 **`MTLAttributeFormat`** 입니다. `import Metal` 이 한 줄 더 필요해요. 쓰는 값은 `.float3` · `.float4` · `.float` 셋뿐입니다.

`MTLAttributeFormat.float3` 은 **12바이트(패딩 없음)** 입니다. 우리가 버퍼에 Float 을 빈틈없이 붙여 넣었으니 맞아떨어집니다 — `SIMD3<Float>`(16바이트)와 헷갈리지 마세요. **1단계에서 본 그 차이가 여기서 «괜찮은» 쪽으로 작용합니다.**

### ② `sphericalHarmonics` 만 튜플이다

넷은 descriptor 하나씩인데 이것만 **`(descriptor, degree)`** 두 개짜리입니다.

```swift
sphericalHarmonics: (어떤_descriptor, .zero)
```

`.zero` 는 **3 값**(확산 색만). `.first` 는 12, `.second` 는 27, `.third` 는 48 값입니다. 우리 `sh` 는 셋이니 `.zero`.

### ③ `throws` 가 둘이다

`LowLevelBuffer(descriptor:)` 와 `BufferResource(count:...)` **둘 다** throws 입니다. `try!` 금지 — 7단계에서 개수 상한을 알아낼 통로가 이 에러예요.

그런데 `RealityView` 의 클로저는 **throws 가 아닙니다.** 그래서 클로저 «안에서» `do/catch` 로 받아 `note` 에 담아야 합니다. 에러가 화면에 뜨지 않으면 「빈 화면」과 「실패」를 구별할 수 없습니다.

### ④ 옵션을 바꾸려면 `var`

`GaussianSplatResource(bufferResource)` 로 만든 뒤 `scaleActivation` 등을 지정합니다. `let` 으로 받으면 못 바꿀 수 있으니 `var` 로 받으세요.

---

# 따라 칠 코드

## 1) `Shared/SplatBufferLayout.swift` 에 offset 다섯 추가

`enum SplatBufferLayout { ... }` 안, `fieldNames` 아래에 붙입니다.

```swift
    /// 56바이트 안에서 각 속성이 시작하는 자리. ⚠️ `fieldNames` 순서와 같아야 한다
    static let positionOffset =  0 * MemoryLayout<Float>.stride   //  0
    static let scaleOffset    =  3 * MemoryLayout<Float>.stride   // 12
    static let rotationOffset =  6 * MemoryLayout<Float>.stride   // 24
    static let opacityOffset  = 10 * MemoryLayout<Float>.stride   // 40
    static let shOffset       = 11 * MemoryLayout<Float>.stride   // 44
```

## 2) `Steps/Step03_FirstSplat.swift`

```swift
import SwiftUI
import RealityKit
import Metal
import simd

struct Step03_FirstSplat: View {

    /// 하나로 시작한다. 0단계 큐브가 0.1m 에서 보였으므로 그 언저리
    let splats: [Splat] = [
        Splat(position: SIMD3(0, 0, 0),
              scale:    SIMD3(0.15, 0.05, 0.05),   // 한 축만 길게 → 타원인지 바로 보인다
              rotation: simd_quatf(ix: 0, iy: 0, iz: 0, r: 1),   // 회전 없음
              opacity:  1.0,
              sh:       SIMD3(1.0, 0.4, 0.2))
    ]

    @State private var note = "준비 중"

    var body: some View {
        RealityView { content in
            content.camera = .virtual
            do {
                content.add(try makeSplatEntity())
                note = "스플랫 \(splats.count)개 · scale(0.15, 0.05, 0.05) · identity"
            } catch {
                note = "실패 — \(error)"
            }
        }
        .overlay(alignment: .bottom) {
            Text(note)
                .font(.caption)
                .padding(8)
                .background(.black.opacity(0.5))
                .foregroundStyle(.white)
        }
    }

    func makeSplatEntity() throws -> Entity {

        // 1️⃣ 버퍼 — 2단계의 «쓰기» 와 똑같다. 읽는 쪽이 GPU 로 바뀌었을 뿐
        let stride = SplatBufferLayout.bytesPerSplat      // 56
        let total  = stride * splats.count

        let buffer = try LowLevelBuffer(
            descriptor: .init(capacity: total, sizeMultiple: stride))

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
            scale:    descriptor(.float3, SplatBufferLayout.scaleOffset),
            rotation: descriptor(.float4, SplatBufferLayout.rotationOffset),
            opacity:  descriptor(.float,  SplatBufferLayout.opacityOffset),
            sphericalHarmonics: (descriptor(.float3, SplatBufferLayout.shOffset), .zero)
        )

        // 4️⃣ 옵션 — 우리 값은 이미 최종값이라 되돌릴 것이 없다 (STUDY Q7)
        var resource = GaussianSplatResource(bufferResource)
        resource.scaleActivation   = .identity
        resource.opacityActivation = .identity

        // 5️⃣ 엔티티에 달아 돌려준다
        let entity = Entity()
        entity.components.set(GaussianSplatComponent(resource))
        return entity
    }
}

#Preview {
    Step03_FirstSplat()
}
```

## 3) `ContentView.swift`

「숫자와 친해지기」 아래에 새 Section 을 하나 엽니다.

```swift
Section("첫 타원체") {
    NavigationLink("첫 스플랫을 그린다") {
        Step03_FirstSplat()
    }
}
```

---

## 왜 이렇게 썼나

**`descriptor(_:_:)` 를 안쪽 함수로 둔 이유** — 다섯 줄이 `buffer` 와 `stride` 를 똑같이 반복합니다. 안쪽 함수로 묶으면 **다른 것(format·offset)만 눈에 남습니다.** 이 파일에서 정말 봐야 할 것이 그 두 열이거든요.

**`splats` 를 하나만 둔 이유** — 안 보일 때 의심할 곳을 줄이려고요. 둘이면 「둘 다 안 보이나, 하나만 안 보이나」가 또 하나의 변수가 됩니다.

**`scale` 을 한 축만 길게 둔 이유** — `(0.15, 0.05, 0.05)` 는 **길쭉한 럭비공**입니다. 세 축이 같으면 어느 각도에서 봐도 원이라 「타원체가 맞나」를 확인할 수 없어요.

**`opacity` 를 1.0 으로 둔 이유** — 첫 확인에서는 최대한 진하게. 옅어서 안 보이는 경우를 후보에서 지웁니다.

---

## 눈으로 확인하는 법

빌드 성공은 성공이 아닙니다 (규칙 13).

1. **뿌연 덩어리 하나**가 화면 가운데 보인다 — 가장자리가 흐릿하게 사라져야 합니다. 딱 떨어지면 스플랫이 아니라 다른 게 그려진 것
2. **아래 문장**에 「스플랫 1개」가 뜬다 — 「실패」면 에러 내용을 읽는다
3. **기기를 돌리면 어느 각도에서 납작해진다** — 럭비공이니까요. 이게 「타원체가 맞다」의 결정적 증거입니다
4. **색이 주황빛**이다 (`sh` 를 (1.0, 0.4, 0.2) 로 줬으니)

**안 보이면 볼 곳, 순서대로**

| 의심 | 확인 |
|---|---|
| 실패했는데 모르고 있다 | 아래 문장이 「실패」인가 |
| 렌더링 자체가 안 됨 | 0단계로 가서 큐브가 보이나 |
| offset 이 어긋남 | 표의 다섯 숫자(0·12·24·40·44)가 코드와 같나 |
| 너무 작다 / 크다 | `scale` 을 0.1 → 1.0 으로 훑어 본다 |
| 카메라 밖 | `position` 이 (0,0,0) 인가 |

### ⭐️ 즉흥 실험 — `scaleActivation` 을 `.exponential` 로

한 줄만 바꿔 보세요. **화면이 어떻게 되나요?** 설계 대화에서 예측한 그대로인가요, 다른가요?

되돌린 뒤 다음 단계로 가세요. 결과는 적어 두지 않겠습니다.

---

## 참고한 Apple 문서

- [GaussianSplatResource.BufferDescriptor](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/bufferdescriptor) — *"Express the stride and offset in bytes."*
- [GaussianSplatResource.BufferResource](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/bufferresource-swift.struct) — `init(count:position:scale:rotation:opacity:sphericalHarmonics:) throws`
- [GaussianSplatResource](https://developer.apple.com/documentation/realitykit/gaussiansplatresource) · [ActivationFunction](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/activationfunction) · [SphericalHarmonicDegree](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/sphericalharmonicdegree)
- [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) — iOS 27+
- [MTLAttributeFormat](https://developer.apple.com/documentation/metal/mtlattributeformat)
