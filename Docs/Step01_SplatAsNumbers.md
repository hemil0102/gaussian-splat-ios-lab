# 1단계 · 스플랫 하나를 «숫자로»

`Shared/Splat.swift` 와 `Steps/Step01_SplatAsNumbers.swift` 의 설명서입니다.

**⏱ 20분. 3D 는 안 나옵니다.** `List` 에 표를 찍는 게 전부예요.

---

## 핵심

**이 저장소의 주제가 «숫자의 배치» 라서, 그 숫자부터 눈으로 봅니다.**

그리고 이 단계에는 목적이 하나 더 있습니다 — **«손으로 센 것» 과 «기계가 잰 것» 이 다르다는 걸 화면에서 확인하는 것.** 설계 대화에서 이미 계산해 두셨죠. 그게 실제로 그런지 기기에서 봅니다.

| | |
|---|---|
| 손으로 센 것 | `Float` 14개 × 4바이트 = **56** |
| 우리 구조체 | **?** ← 화면에서 확인 |
| Apple 이 요구하는 것 | **56** |

---

## 만들 파일 둘

**순서를 지키세요.** `Shared/` 를 먼저 만들어야 `Steps/` 에서 자동완성이 도와줍니다.

| 파일 | 무엇 |
|---|---|
| `Shared/Splat.swift` | 스플랫 하나를 담는 구조체. **3단계까지 씁니다** |
| `Steps/Step01_SplatAsNumbers.swift` | 그 값을 표로 찍는 화면 |

`ContentView.swift` 의 「숫자와 친해지기」 Section 에 항목을 하나 더 추가하는 것도 잊지 마세요.

---

## 설계 대화에서 정한 것

```swift
struct Splat {
    var position: SIMD3<Float>    // 16바이트
    var scale:    SIMD3<Float>    // 16바이트
    var rotation: simd_quatf      // 16바이트
    var opacity:  Float           //  4바이트
    var sh:       SIMD3<Float>    // 16바이트
}
```

**왜 이렇게 골랐나**

- `SIMD3<Float>` — RealityKit 이 어차피 쓰는 타입이고 읽기 편합니다. **`Float` 세 개를 따로 두는 것보다 프로퍼티가 절반으로 줍니다**
- `simd_quatf` — 진짜 회전 타입. 회전 계산이 딸려 옵니다. **다만 3단계에서 순서 함정을 만납니다 — 알고 고른 것입니다**

두 선택 다 **«2·3단계에서 부딪혀 보기 위해» 일부러 고른 것**입니다. 안전한 답이 아닙니다.

---

## ⚠️ 막힐 요소 셋

**정답은 여기 안 적습니다. 대신 «무엇을 해야 하는지» 는 분명히 적습니다** (규칙 1 ⓑ).

### ① `sample` 을 어디에 어떻게 두나

**할 일** — 화면에 찍을 스플랫 하나를 미리 만들어 두는 것.

**왜 문제인가** — `Splat` 은 구조체라 «인스턴스가 있어야» 값을 읽을 수 있습니다. 그런데 화면 코드에서 매번 값 열넷을 손으로 채워 넣는 건 번거롭습니다. **타입 자체에 붙여 두면** `Splat.sample` 한 줄로 끝납니다.

**힌트** — 0단계에서 `checkGPUFamily()` 를 `static` 으로 할지 말지 고민했던 그 이야기와 같은 종류입니다. **«인스턴스 없이 부를 수 있는 것»** 을 만드는 키워드가 하나 있습니다.

**값의 범위** — 그럴듯한 숫자를 넣으세요. 나중에 잣대가 됩니다.

| 값 | 그럴듯한 범위 |
|---|---|
| `position` | −2 ~ 2 (미터) |
| `scale` | 0.01 ~ 0.5 |
| `rotation` | 길이가 1인 쿼터니언. 회전이 없으면 «실수부 1, 나머지 0» |
| `opacity` | 0 ~ 1 |
| `sh` | 0 ~ 1 (색이라 생각하고) |

### ② 값 열넷을 어떻게 «표» 로 만드나

**할 일** — `SIMD3<Float>` 하나에서 x·y·z 를 각각 꺼내 줄 셋으로 만드는 것.

**왜 문제인가** — `Text(splat.position)` 은 안 됩니다. `Text` 는 문자열을 받는데 `SIMD3<Float>` 는 문자열이 아니에요. **꺼내서 문자열로 바꿔야** 합니다.

**힌트** — `SIMD3<Float>` 의 세 값은 `.x` · `.y` · `.z` 로 꺼냅니다. 문자열로 바꾸는 방법은 여러 가지인데, 소수점 자리를 맞추고 싶으면 `String(format:)` 이 편합니다.

> ⭐️GUIDE⭐️ **`List` 와 `Section`** — `List` 는 세로로 죽 늘어놓는 SwiftUI 뷰입니다(설정 앱 같은 모양). `Section("제목") { ... }` 으로 묶으면 제목이 붙은 덩어리가 됩니다. 이 화면은 Section 셋으로 나눕니다.

### ③ 크기를 어떻게 재나

**할 일** — `MemoryLayout` 으로 세 값을 재서 화면에 띄우는 것.

**세 값이 무엇인지**

| | 뜻 |
|---|---|
| `size` | 이 타입이 실제로 쓰는 바이트 수 |
| `stride` | **다음 것이 시작하는 자리까지의** 바이트 수 ([Q1](../STUDY.md) 의 그것) |
| `alignment` | 몇의 배수 주소에서 시작해야 하나 |

**힌트** — `MemoryLayout<타입>.size` 처럼 씁니다. 꺾쇠 안에 타입 이름을 넣는 것이라 인스턴스가 필요 없습니다.

**세 값을 다 찍으세요.** `size` 와 `stride` 가 같은지 다른지가 2단계에서 의미를 갖습니다.

---

## 눈으로 확인하는 법

빌드 성공은 성공이 아닙니다 (규칙 13).

1. **값 열넷**이 이름과 함께 화면에 보인다
2. **`rotation` 의 메모리 순서**가 찍힌다 — 만들 때 넣은 순서와 같은가, 다른가?
3. **크기 세 값**이 보인다 — 손으로 센 **56** 과 다른가?
4. 다르다면 **몇 바이트 차이인지** 화면에서 읽을 수 있다

**3번에서 56이 나오면 오히려 뭔가 잘못된 것입니다.** 설계 대화에서 계산한 값이 나와야 합니다.

### ⭐️ 즉흥 실험 — 필드 순서를 바꿔 보세요

`Splat` 안에서 **`opacity` 를 맨 위로** 올려 보세요. 값은 하나도 안 바뀌고 **줄 순서만** 바꾸는 겁니다.

```swift
struct Splat {
    var opacity:  Float          // ← 맨 위로
    var position: SIMD3<Float>
    var scale:    SIMD3<Float>
    var rotation: simd_quatf
    var sh:       SIMD3<Float>
}
```

**`size` 가 달라지나요? 달라진다면 몇으로?**

그리고 **왜 그런지** 생각해 보세요 — 모눈종이에 다시 그려 보면 보입니다. 답은 적어 두지 않겠습니다.

> 이 실험이 2단계에서 값을 합니다. **필드를 어떻게 늘어놓느냐로 낭비를 줄일 수 있다**는 것이 여기서 나옵니다.

---

## 연결

| | |
|---|---|
| 불러 쓰는 곳 | `ContentView` 의 「숫자와 친해지기」 Section |
| 기대는 것 | SwiftUI · simd (`SIMD3` · `simd_quatf`) |
| 준비물 | 없음 |
| 다음 단계 | 2단계에서 이 구조체를 **`LowLevelBuffer` 에 넣었다 꺼내** 봅니다. 여기서 확인한 «크기 차이» 가 거기서 문제가 됩니다 |

---

## 참고한 Apple 문서

- [SIMD3](https://developer.apple.com/documentation/swift/simd3) · [simd_quatf](https://developer.apple.com/documentation/simd/simd_quatf) · [simd_quatf.init(ix:iy:iz:r:)](https://developer.apple.com/documentation/simd/simd_quatf/init(ix:iy:iz:r:))
- [MemoryLayout](https://developer.apple.com/documentation/swift/memorylayout)
- [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) — 속성 표(값 열넷과 그 순서)
- [List](https://developer.apple.com/documentation/swiftui/list) · [Section](https://developer.apple.com/documentation/swiftui/section)

---

# 따라 칠 코드

> **아직 비어 있습니다.**
>
> 규칙 1 ⓓ 입니다 — **먼저 직접 써 보세요.** 위의 「막힐 요소 셋」 과 문서 링크로 시작하고, 걸리면 **힌트를 한 칸씩 요청**하세요.
>
> 「모르겠다」 또는 「답 주세요」 라고 하시면 그때 이 자리에 채워 넣겠습니다.
