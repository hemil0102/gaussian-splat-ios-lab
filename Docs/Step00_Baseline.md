# 0단계 · 기준선 — 흰 큐브 하나

`gaussian-splat-ios-lab/Steps/Step00_Baseline.swift` 의 설명서입니다.

**⏱ 10분.** 오래 붙들 단계가 아닙니다.

---

## 핵심

**이 단계는 스플랫과 아무 상관이 없습니다.** 나중에 스플랫이 안 보일 때 **«RealityView 자체가 안 뜬 건지, 스플랫만 안 뜬 건지» 를 가르기 위한 기준선**을 만들어 두는 것이 전부입니다.

큐브가 보이면 성공입니다. 예쁘게 만들지 마세요.

---

## 이 단계에서 얻는 것

1. 아이폰 실기기에 앱이 올라간다 (서명·프로비저닝 확인)
2. `RealityView` 가 화면에 뜬다
3. **이 기기가 Apple7 GPU 패밀리 이상**이라는 것을 코드로 확인 — 아니면 3단계부터 아무것도 안 보입니다

---

## ⚠️ 막힐 요소 셋

**답은 여기 안 적습니다.** 어디가 어려운지와 어느 문서를 볼지만 적습니다 (규칙 1 ⓑ).

### ① iOS 의 `RealityView` 는 visionOS 것과 타입이 다릅니다

인터넷에서 찾은 visionOS 예제를 그대로 붙이면 **컴파일이 안 됩니다.** 클로저가 받는 그 값의 타입이 플랫폼마다 다릅니다.

→ [RealityView](https://developer.apple.com/documentation/realitykit/realityview) 문서에서 **iOS 일 때 무엇을 받는지** 확인하세요.

### ② 그냥 두면 «AR 모드» 로 뜹니다

iOS 에서는 기본이 **카메라 화면 위에 그리는 모드**입니다. 우리는 AR 을 안 쓸 거라 이걸 꺼야 합니다. 안 끄면 카메라 권한을 묻고, 방을 비추고, 큐브가 어디 있는지도 헷갈립니다.

→ 힌트 하나만 — **«둘 중 하나를 고르는» 문제**입니다. [RealityViewCameraContent](https://developer.apple.com/documentation/realitykit/realityviewcameracontent) 에서 카메라를 다루는 속성을 찾아보세요.

### ③ 조명이 없으면 큐브가 안 보이거나 새까맣습니다

RealityKit 의 기본 재질은 **빛을 받아야** 보입니다. 큐브를 넣었는데 화면이 비었다면 «없는 것» 이 아니라 «안 보이는 것» 일 수 있습니다.

→ 두 갈래가 있습니다. **빛을 주는 방법**과 **빛이 필요 없는 재질을 쓰는 방법.** 어느 쪽이든 됩니다. 재질 쪽으로 갈 거면 [UnlitMaterial](https://developer.apple.com/documentation/realitykit/unlitmaterial) 을, 빛 쪽으로 갈 거면 [DirectionalLight](https://developer.apple.com/documentation/realitykit/directionallight) 를 보세요.

> **③ 은 4단계와 11단계에서 다시 나옵니다.** 스플랫은 **빛을 아예 안 받습니다** — 이 단계에서 «빛이 있어야 보이는 것» 을 한 번 겪어 두면 11단계에서 그 대비가 살아납니다.

---

## 준비물

없습니다. 스캔 파일은 8단계에 필요합니다.

---

## 만들 것

`Steps/Step00_Baseline.swift` 의 뼈대에 `// 코드 작성:` 이 네 군데 있습니다. 그 자리에 적힌 **이름만** 보고 채우세요.

`ContentView.swift` 도 손봐야 합니다 — Xcode 가 만들어 준 「Hello, world!」 를 지우고, **단계 목록**으로 바꿉니다. `NavigationStack` 안에 `List` 하나, `NavigationLink` 로 `Step00_Baseline()` 으로 가면 됩니다. 앞으로 단계가 늘 때마다 여기에 한 줄씩 추가합니다.

---

## 눈으로 확인하는 법

빌드 성공은 성공이 아닙니다 (규칙 13).

1. **아이폰 실기기**에서 실행 — 시뮬레이터 아님
2. 카메라 권한을 **안 묻는다** (물으면 ② 가 안 된 것)
3. 화면에 **흰 큐브**가 보인다
4. 기기를 기울여도 **큐브가 그 자리에 있다** (따라 움직이면 ② 가 안 된 것)
5. 화면 어딘가에 **GPU 패밀리 확인 결과**가 떠 있다 — Apple7 이상이면 통과

### ⭐️ 즉흥 실험

큐브의 크기를 `0.1` 로 두면 화면을 꽉 채우고, `0.001` 로 두면 점이 됩니다. **둘 사이 어디쯤이 «손에 쥔 물건» 처럼 보이나요?**

그 숫자를 적어 두세요. **3단계에서 첫 스플랫이 안 보일 때, 제일 먼저 의심할 것이 이 크기 감각**입니다.

---

## 연결

| | |
|---|---|
| 불러 쓰는 곳 | `ContentView` 의 단계 목록 |
| 기대는 것 | RealityKit · SwiftUI · Metal(GPU 확인용) |
| 준비물 | 없음 |
| 다음 단계 | 1단계에서 **스플랫 하나의 값 열넷을 화면에 표로** 찍습니다. 3D 는 잠시 쉽니다 |

---

## 참고한 Apple 문서

- [RealityView](https://developer.apple.com/documentation/realitykit/realityview)
- [RealityViewCameraContent](https://developer.apple.com/documentation/realitykit/realityviewcameracontent) — iOS 18+
- [MTLDevice.supportsFamily(_:)](https://developer.apple.com/documentation/metal/mtldevice/supportsfamily(_:)) · [MTLGPUFamily](https://developer.apple.com/documentation/metal/mtlgpufamily)
- [ModelEntity](https://developer.apple.com/documentation/realitykit/modelentity) · [MeshResource.generateBox](https://developer.apple.com/documentation/realitykit/meshresource/generatebox(size:cornerradius:))

---

# 따라 칠 코드

> **아직 비어 있습니다.**
>
> 규칙 1 ⓓ 입니다 — **먼저 직접 써 보세요.** 위의 「막힐 요소 셋」 과 문서 링크로 시작하고, 걸리면 **힌트를 한 칸씩 요청**하세요.
>
> 「모르겠다」 또는 「답 주세요」 라고 하시면 그때 이 자리에 채워 넣겠습니다.
