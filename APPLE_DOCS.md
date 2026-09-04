# APPLE_DOCS — 공식 문서 색인

**이 API 는 2026년에 나왔습니다.** 훈련 데이터가 얇아서 그럴듯하게 틀린 코드를 지어내기 가장 쉬운 조건입니다. 심볼 이름·시그니처·가용성은 **매번 여기서 확인**합니다 (규칙 16).

> **💡 문서를 원문 그대로 보는 법** — Apple 문서 페이지는 자바스크립트로 그려져서 복사가 잘 안 됩니다. **URL 뒤에 `.md` 를 붙이면** 마크다운 원문이 그대로 나옵니다 — 가용성 주석·코드 예제·표까지 전부.
>
> ```
> https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent.md
> ```
>
> 가용성이 헷갈릴 때 이 방법이 가장 빠릅니다.

---

## 1순위 — 매 단계 여는 것

| 문서 | 무엇이 있나 | 어느 단계 |
|---|---|---|
| [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) | **속성 표(어떤 값이 몇 float 인지) · 전체 예제 코드 · 성능 지침** | 01~ 전부 |
| [GaussianSplatResource](https://developer.apple.com/documentation/realitykit/gaussiansplatresource) | 활성화 함수 · 투영 모드 · **정렬 모드** · 색공간. **버퍼를 참조만 한다는 문장** | 03 · 11 |
| [GaussianSplatResource.BufferDescriptor](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/bufferdescriptor) | **stride·offset 이 바이트 단위**라는 것 | 02 |
| [GaussianSplatResource.BufferResource](https://developer.apple.com/documentation/realitykit/gaussiansplatresource/bufferresource-swift.struct) | 초기화 인자 · **개수 상한을 넘으면 throw** | 01 · 07 |
| [LowLevelBuffer](https://developer.apple.com/documentation/realitykit/lowlevelbuffer) | 버퍼 자체. iOS **26** 부터 (다른 것은 27) | 01 · 11 |

## 2순위 — 필요할 때

| 문서 | 어느 단계 |
|---|---|
| [Gaussian splats on visionOS](https://developer.apple.com/documentation/visionos/gaussian-splats-on-visionos) — 공식 샘플 프로젝트 | 막혔을 때 |
| [RealityView](https://developer.apple.com/documentation/realitykit/realityview) | 00 |
| [Entity](https://developer.apple.com/documentation/realitykit/entity) · [Transform](https://developer.apple.com/documentation/realitykit/transform) | 08 · 10 |
| [GroundingShadowComponent](https://developer.apple.com/documentation/realitykit/groundingshadowcomponent) | 08 |
| [ModelComponent](https://developer.apple.com/documentation/realitykit/modelcomponent) — 대조군 | 09 |

## 영상

| | 무엇이 있나 |
|---|---|
| [WWDC26 279 · Explore advances in RealityKit](https://developer.apple.com/videos/play/wwdc2026/279/) | **스플랫 API 를 설명하는 본편.** 구면조화 차수 이야기가 여기 |
| [WWDC26 287 · Build next-generation experiences with visionOS 27](https://developer.apple.com/videos/play/wwdc2026/287/) | 맥락과 사례(화분 스캔). API 세부는 279 로 넘김 |

---

## 문서에서 확인된 사실 (근거를 여기 모읍니다)

새로 확인할 때마다 한 줄씩 추가합니다. **«아마도» 를 적지 않습니다** — 못 찾은 것은 [PROBLEMS.md](PROBLEMS.md) 로.

| 사실 | 어디에 | 확인일 |
|---|---|---|
| `GaussianSplatComponent` 는 iOS 27 · iPadOS 27 · macCatalyst 27 · macOS 27 · visionOS 27 | 심볼 문서 가용성 | 2026-09-02 |
| `LowLevelBuffer` 만 iOS **26** 부터 | 심볼 문서 가용성 | 2026-09-02 |
| **Apple7 GPU 패밀리 이상** 필요 (A14 = iPhone 12 이상) | GaussianSplatComponent Overview | 2026-09-02 |
| 스플랫 한 개 = position float3 · scale float3 · rotation float4 · opacity float1 · SH float3+ | 같은 문서의 속성 표 | 2026-09-02 |
| **half precision 도 허용** | 같은 문서 | 2026-09-02 |
| 인터리브(구조체 배열)와 속성별 버퍼(배열의 구조체) **둘 다 가능** | 같은 문서 | 2026-09-02 |
| **프레임워크가 파일을 로드하지 않는다** — PLY·USD 등은 직접 파싱 | 같은 문서 | 2026-09-02 |
| **개발자가 만지는 셰이더가 없다.** 투명 패스에서 뒤→앞으로 블렌딩 | 같은 문서 | 2026-09-02 |
| **씬 조명이 스플랫에 영향을 주지 않는다.** 색은 촬영 당시 조명 | 같은 문서 Important | 2026-09-02 |
| `GroundingShadowComponent` 를 붙이면 **구형 프록시로 근사 그림자** | 같은 문서 | 2026-09-02 |
| 개수 상한이 있고 **`BufferResource` 초기화가 throw** 한다. 숫자는 비공개 | 같은 문서 Performance | 2026-09-02 |
| 비용 = **개수 × 오버드로.** 줄이는 법 둘 — 학습 단계 pruning, 저불투명 컬링 | 같은 문서 | 2026-09-02 |
| `BufferDescriptor` 의 **stride·offset 은 바이트 단위** | BufferDescriptor Overview | 2026-09-03 |
| `LowLevelBuffer` 의 멤버는 **여섯뿐** — `Descriptor` · `init(descriptor:)` · `bytesUsed` · `withUnsafeBytes` · `withUnsafeMutableBytes` · `read`/`replace` | LowLevelBuffer 심볼 목록 | 2026-09-03 |
| `Descriptor(capacity:sizeMultiple:)` — `capacity` 는 **바이트**, `sizeMultiple` 은 «bytesUsed 가 이 값의 배수여야 한다» | Descriptor 심볼 문서 | 2026-09-03 |
| `LowLevelBuffer.init(descriptor:)` 는 **throws** | 심볼 선언 | 2026-09-03 |
| `withUnsafeBytes`/`withUnsafeMutableBytes` 의 **클로저 반환 타입이 `Void`** — 표준 라이브러리 것과 달라 결과를 못 돌려받는다 | 심볼 선언 | 2026-09-03 |
| 두 메서드의 포인터는 **클로저 수명 동안만 유효** ("only valid for the lifetime of the callback") | 같은 문서 Discussion | 2026-09-03 |
| `bytesUsed` 는 `get set` — 쓴 만큼을 **직접 알려 준다** | 심볼 선언 | 2026-09-03 |
| `BufferDescriptor(buffer:format:stride:offset:)` — `format` 이 **`MTLAttributeFormat`**(Metal 타입). `import Metal` 이 필요하다 | BufferDescriptor 심볼 | 2026-09-04 |
| 「offset 에서 시작해 스플랫마다 stride 만큼 전진한다」 — 다섯 descriptor 가 **한 버퍼를 offset 만 달리해 공유**해도 된다 | BufferDescriptor·BufferResource Overview | 2026-09-04 |
| `BufferResource(count:position:scale:rotation:opacity:sphericalHarmonics:)` **throws** — `sphericalHarmonics` 는 **(BufferDescriptor, SphericalHarmonicDegree) 튜플** | BufferResource 심볼 | 2026-09-04 |
| `ActivationFunction` 은 셋 — **`.identity` · `.exponential` · `.sigmoid`** | ActivationFunction 심볼 | 2026-09-04 |
| `SphericalHarmonicDegree` 넷 — `.zero`(3) · `.first`(12) · `.second`(27) · `.third`(48) 값 | SphericalHarmonicDegree 심볼 | 2026-09-04 |
| `GaussianSplatResource(_ bufferResource:)` · `GaussianSplatComponent(_ resource:)` — 둘 다 인자 하나 | 각 심볼 | 2026-09-04 |
| **버퍼를 참조만 하므로 `LowLevelBuffer` 내용을 바꾸면 애니메이션이 된다** (13단계의 근거) | GaussianSplatResource Overview | 2026-09-04 |
| **공식 예제가 `GaussianSplatComponent` Overview 안에 통째로 있다** — PLY→버퍼→descriptor 다섯→BufferResource→Entity | GaussianSplatComponent Overview | 2026-09-04 |
| 예제의 capacity 는 **`(length + 15) & ~0xF`** — 16의 배수로 올린다. `sizeMultiple` 은 **16** | 같은 예제 | 2026-09-04 |
| 예제는 **`bytesUsed` 를 설정하지 않는다** | 같은 예제 | 2026-09-04 |
| 예제의 stride 는 **`15 * floatSize`(60)** — 속성 합은 14개(56)인데 15. **이유 불명**(PROBLEMS P3) | 같은 예제 | 2026-09-04 |
| 예제의 offset 은 `0 · 3 · 6 · 10 · 11` × floatSize — **우리 배치와 같다** | 같은 예제 | 2026-09-04 |
| 「각 스플랫을 **타원체로, 투명 패스에서, 정렬 모드에 따라 뒤→앞 블렌딩**」 | 같은 문서 | 2026-09-04 |
| visionOS 공식 샘플 페이지에는 **코드가 없다** — 실제 예제는 위 심볼 문서 쪽 | Gaussian splats on visionOS | 2026-09-04 |
| **실측** · SH 0차의 색 공식은 **`색 = 0.5 + 0.2820948 × sh`** — `sh` 는 색이 아니라 **계수**다 | 3단계 화면에서 확인 | 2026-09-04 |
| **실측** · 어떤 `sh` 를 넣어도 `0.5` 가 더해져 **회색기가 섞인다.** 순색은 나머지 둘을 음수로 밀어야 | 같은 곳 | 2026-09-04 |
| **실측** · 스플랫 하나가 «네모로 잘려» 보이는 것은 정상 — 무한히 퍼지는 가우시안을 **사각형 안에서만 계산**하기 때문 | 같은 곳 | 2026-09-04 |
| `ProjectionMode` 는 둘 — **`.perspective`**(표준 원근) · **`.tangential`**(접선 근사, "can reduce artifacts") | ProjectionMode 심볼 | 2026-09-04 |
| **자르는 반경을 정하는 API 는 없다** — 「개발자가 만지는 셰이더가 없다」가 근거. `opacity`·`scale` 로만 우회 | GaussianSplatComponent Overview | 2026-09-04 |
| `RealityViewCamera` 는 둘 — `.virtual`(고정) · `.spatialTracking`(패스스루+추적). **`.virtual` 은 기기를 돌려도 시점이 안 바뀐다** | RealityViewCamera 심볼 + 실측 | 2026-09-04 |
| 카메라를 직접 안 놓으면 **RealityKit 이 기본 카메라를 알아서 만든다** — 위치를 알 수 없다 | PerspectiveCamera Overview | 2026-09-04 |
| **실측 확정** · `LowLevelBuffer` 의 `capacity` 는 **16의 배수여야 한다.** 아니면 초기화가 throw (점 14개, 예외 없음) | 실측 (Q&A) | 2026-09-04 |
| **실측** · `sizeMultiple` 은 16일 필요 없다 — 56 으로 두고 `bytesUsed` 168 로도 잘 된다 | 실측 | 2026-09-04 |
| **실측** · stride 는 **56 이면 된다** — 예제의 60(15 float)은 그쪽 PLY 사정 | 실측 | 2026-09-04 |
| **실측 확정** · 스플랫은 **위치들의 경계 상자에 «면적» 이 있어야** 그려진다. 점·선분은 안 나온다. **개수·scale 은 무관** | 실측 (Q&A) | 2026-09-04 |
| 리소스가 드는 옵션 넷 — **활성화 함수(스케일·불투명도) · 투영 모드 · 정렬 모드 · 색공간** | GaussianSplatResource Overview | 2026-09-02 |
| **버퍼를 복사하지 않고 참조한다 → 내용을 갱신하면 애니메이션이 된다** | GaussianSplatResource Overview | 2026-09-02 |

---

## 문서 밖의 것

공식 문서가 아니므로 **판단의 근거로만 쓰고, 코드의 근거로는 쓰지 않습니다.**

- [MetalSplatter](https://github.com/scier/MetalSplatter) (MIT) — PLY·SPZ·.splat 파서 `SplatIO`. **5·6단계에서 막히면 여기 구현을 봅니다.** 렌더러는 독자 Metal 구현이라 안 써도 됩니다
- [Radiance Fields — Apple](https://radiancefields.com/platforms/apple) — 플랫폼 지원 현황 정리
- [Scaniverse](https://apps.apple.com/app/id1541433223) — 온디바이스 캡처·학습 (Niantic, 무료)
- [3DGS Render 5.0](https://www.cgchannel.com/2026/06/3dgs-render-5-0-lets-you-animate-gaussian-splats-inside-blender/) — Blender 에서 프록시 메시로 스플랫 리깅, PLY 시퀀스 베이크 (12단계)
