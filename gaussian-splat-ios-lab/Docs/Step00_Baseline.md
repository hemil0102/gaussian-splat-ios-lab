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

## ⚠️ 막힐 요소 둘

**정답은 여기 안 적습니다. 대신 «무엇을 정해야 하는지» 는 분명히 적습니다** (규칙 1 ⓑ).

> 처음 쓴 판은 증상만 적고 할 일을 안 적어서 수수께끼였습니다. 고쳤습니다.

### ① 카메라 모드를 «한 줄» 정해야 합니다

**할 일** — `RealityView` 의 클로저 안에서, 받은 `content` 의 **`camera` 속성에 값을 하나 대입**하는 것. 그 한 줄을 안 쓰면 iOS 는 **기본이 AR 모드**라 카메라 권한을 묻고 방을 비춥니다.

**고르는 것** — `RealityViewCamera` 타입에 값이 **둘** 있습니다. 문서의 첫 줄이 그대로 알려 줍니다 — *"A camera for reality view scenes, that can be **world tracking** or **virtual**."* 우리는 이번 단계에서 AR 을 안 씁니다. **둘 중 어느 쪽일까요?**

→ [RealityViewCamera](https://developer.apple.com/documentation/realitykit/realityviewcamera) · [RealityViewCameraContent.camera](https://developer.apple.com/documentation/realitykit/realityviewcameracontent/camera)

> **왜 «iOS 는 타입이 다르다» 는 말이 나왔나** — `RealityView` 자체는 모든 플랫폼에 있습니다. 다른 건 **클로저가 받는 `content` 의 타입**입니다. 문서에 이렇게 적혀 있어요 — *"The `RealityViewContent` type on **visionOS**, and `RealityViewCameraContent` on **other platforms** represents the content of your `RealityView`."* 실제로 타입 이름을 쓸 일은 거의 없습니다(`content` 라고만 쓰면 Swift 가 알아서 압니다). **문제가 되는 건 «그 타입에 무엇이 있느냐» 입니다** — `camera` 속성은 iOS 쪽 타입에만 있고, visionOS 예제에는 아예 안 나옵니다. 그래서 visionOS 예제를 베끼면 이 한 줄이 통째로 빠집니다.

### ② 큐브의 «재질» 을 골라야 합니다

**할 일** — `ModelEntity(mesh:materials:)` 의 `materials` 배열에 **무엇을 넣을지 정하는 것.**

**왜 문제인가** — 가장 흔히 쓰는 `SimpleMaterial` 은 **빛을 받아야 보입니다.** 씬에 조명이 하나도 없으면 큐브는 «없는» 게 아니라 «까맣게 있는» 상태가 됩니다. 화면이 비어 보여도 사실은 거기 있는 거예요.

**두 갈래** — ⓐ **씬에 조명 엔티티를 하나 추가한다** ⓑ **빛이 필요 없는 재질을 쓴다.** 둘 다 됩니다. 다만 0단계는 «기준선» 이라 변수가 적을수록 좋습니다 — **어느 쪽이 더 단순할까요?**

→ [SimpleMaterial](https://developer.apple.com/documentation/realitykit/simplematerial) · [UnlitMaterial](https://developer.apple.com/documentation/realitykit/unlitmaterial) · [DirectionalLight](https://developer.apple.com/documentation/realitykit/directionallight)

> **② 는 11단계에서 값을 합니다.** 스플랫은 **빛을 아예 안 받습니다.** 여기서 «빛이 있어야 보이는 것» 을 한 번 겪어 두면, 11단계에서 조명 슬라이더를 올려도 스플랫만 미동도 없는 장면이 훨씬 선명하게 읽힙니다.

---

## 준비물

없습니다. 스캔 파일은 8단계에 필요합니다.

---

## 만들 것

`Steps/Step00_Baseline.swift` 의 뼈대에 `// 코드 작성:` 이 여섯 군데 있습니다. 그 자리에 적힌 **이름만** 보고 채우세요. 위에서부터 순서대로 가면 됩니다.

`ContentView.swift` 도 손봐야 합니다 — Xcode 가 만들어 준 「Hello, world!」 를 지우고, **단계 목록**으로 바꿉니다. `NavigationStack` 안에 `List` 하나, `NavigationLink` 로 `Step00_Baseline()` 으로 가면 됩니다. 앞으로 단계가 늘 때마다 여기에 한 줄씩 추가합니다.

---

## 눈으로 확인하는 법

빌드 성공은 성공이 아닙니다 (규칙 13).

1. **아이폰 실기기**에서 실행 — 시뮬레이터 아님
2. 카메라 권한을 **안 묻는다** (물으면 ① 이 안 된 것)
3. 화면에 **흰 큐브**가 보인다
4. 기기를 기울여도 **큐브가 그 자리에 있다** (배경이 따라 움직이면 ① 이 안 된 것)
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
> 규칙 1 ⓓ 입니다 — **먼저 직접 써 보세요.** 위의 「막힐 요소 둘」 과 문서 링크로 시작하고, 걸리면 **힌트를 한 칸씩 요청**하세요.
>
> 「모르겠다」 또는 「답 주세요」 라고 하시면 그때 이 자리에 채워 넣겠습니다.
