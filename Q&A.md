# Q&A — 막혔던 것과 그 해결

물어본 것과 답을 요약해 여기 쌓습니다 (규칙 17). **아직 못 푼 것은 [PROBLEMS.md](PROBLEMS.md) 로** 가고, 풀리면 여기로 옮깁니다.

**설명에는 비유를 2~3줄 덧붙이고, 그 비유가 어디서 깨지는지도 적습니다** (규칙 19). 비유가 잡음이 될 자리에는 붙이지 않습니다.

**빗나간 예측은 «틀렸다» 가 아니라 «수확» 으로 적습니다** (규칙 4).

---

## 형식

````markdown
## Q. 질문 한 줄

**A.** 핵심을 먼저 한 문단.

자세한 설명.

```swift
// 필요하면 코드
```

> **비유** — …
> **깨지는 곳** — …

**어디서 나왔나** — N단계 · 2026-MM-DD
**근거** — [문서 이름](링크)
````

---

## Q. `GaussianSplatComponent` 는 visionOS 전용 아닌가요?

**A.** 아닙니다. **iOS 27 · iPadOS 27 · macCatalyst 27 · macOS 27 · visionOS 27** 에 전부 있습니다.

문서 제목이 「Gaussian splats on **visionOS**」 라서 오해하기 쉽습니다. 그건 샘플 코드 프로젝트의 이름이고, 심볼 자체의 가용성은 다섯 플랫폼입니다. 기기 조건은 **Apple7 GPU 패밀리 이상** — iPhone 12(A14) 가 하한선입니다.

그래서 이 저장소는 **iOS 앱**으로 만들고 아이폰 실기기에서 확인합니다. visionOS 시뮬레이터를 열 이유가 없습니다.

**어디서 나왔나** — 저장소 개설 · 2026-09-02
**근거** — [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) 가용성 주석

---

## Q. 왜 `Entity(named: "scan.ply")` 로 못 불러오나요?

**A.** **RealityKit 은 스플랫 파일을 로드하지 않습니다.** Apple 은 자체 스플랫 파일 포맷을 만들지 않았고, API 는 포맷 불가지론입니다.

문서의 문장 그대로입니다 — *「프레임워크는 파일을 직접 로드하지 않으므로, 여러분의 소스 포맷(PLY, USD, 그 밖 어떤 컨테이너든)을 파싱해서 버퍼를 직접 채웁니다.」*

그래서 이 저장소의 절반이 «숫자를 어떻게 배치하는가» 입니다. 5·6단계가 그 자리입니다.

> **비유** — 액자만 파는 가게입니다. 사진은 직접 인화해 와야 합니다.
> **깨지는 곳** — 액자는 규격이 정해져 있지만 이 API 는 «어떤 크기든 좋으니 몇 mm 인지만 알려 달라» 고 합니다. 그게 `BufferDescriptor` 입니다.

**어디서 나왔나** — 저장소 개설 · 2026-09-02
**근거** — [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) · Providing Splat Data

---

## Q. 캡처한 스플랫에 애니메이션을 넣을 수 있나요?

**A.** 됩니다. **세 층위가 있고 난이도가 크게 다릅니다.**

| 층위 | 방법 | 단계 |
|---|---|---|
| 엔티티를 움직인다 | 스플랫도 평범한 `Entity`. `Transform` 애니메이션·물리·제스처가 그대로 | 10 |
| **버퍼를 갱신한다** | 문서의 한 줄이 근거 — *「프레임워크는 버퍼를 복사하지 않고 참조하므로, 하부 `LowLevelBuffer` 의 내용을 갱신해 스플랫을 시간에 따라 애니메이션할 수 있습니다.」* | 11 |
| 리깅해서 캐릭터처럼 | RealityKit 밖. Blender + 3DGS Render 5.0 이 프록시 메시의 변형을 전이하고 **PLY 시퀀스로 베이크** → 다시 11단계로 | 12 |

**실용 케이스의 9할은 첫 줄에서 끝납니다.** 두 번째 줄이 «진짜 스플랫 애니메이션» 이고, 세 번째는 아직 실험적입니다.

**어디서 나왔나** — 저장소 개설 · 2026-09-02
**근거** — [GaussianSplatResource](https://developer.apple.com/documentation/realitykit/gaussiansplatresource) Overview
