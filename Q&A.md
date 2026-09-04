# Q&A — 막혔던 것과 그 해결

물어본 것과 답을 요약해 여기 쌓습니다 (규칙 17). **아직 못 푼 것은 [PROBLEMS.md](PROBLEMS.md) 로** 가고, 풀리면 여기로 옮깁니다.

**설명에는 비유를 2~3줄 덧붙이고, 그 비유가 어디서 깨지는지도 적습니다** (규칙 19). 비유가 잡음이 될 자리에는 붙이지 않습니다.

**빗나간 예측은 «틀렸다» 가 아니라 «수확» 으로 적습니다** (규칙 4).

---

## 스플랫이 그려지려면 경계 상자에 «면적» 이 있어야 한다 (P4 해결 · 실측)

**언제** — 2026-09-04 · 3단계

**증상** — 에러 없이, 상태 문구도 정상인데 화면에 아무것도 안 그려짐. 같은 장면의 `ModelEntity` 큐브는 잘 보임.

### 실측 표

`scale` 은 셋 다 `(0.16, 0.04, 0.04)` 로 고정하고 **위치만** 바꿨다.

| 개수 | 위치들 | 경계 상자 x·y·z | 0 아닌 축 | 결과 |
|:---:|---|---|:---:|:---:|
| 1 | (0,0,0) | 0 · 0 · 0 | 0 | ❌ |
| 2 | (0,0,0) × 2 | 0 · 0 · 0 | 0 | ❌ |
| 2 | (±0.25, 0, 0) | 0.5 · 0 · 0 | 1 | ❌ |
| 3 | (−0.25,0,0) (0,0.25,0) (0.25,0,0) | 0.5 · 0.25 · 0 | 2 | ✅ |
| 2 | (−0.25,−0.25,0) (0.25,0.25,0) | 0.5 · 0.5 · 0 | 2 | ✅ |

### 결론

> **위치들의 경계 상자에 «면적» 이 있어야 그려진다. 부피는 없어도 된다.**

- **점**(면적 0) ❌ · **선분**(면적 0) ❌ · **평면**(면적 > 0) ✅
- **개수는 무관하다** — 2개짜리가 되기도 하고 안 되기도 한다. 오직 퍼진 모양이 가른다
- **`scale` 은 무관하다** — 하나짜리도 «크기»는 있었지만 안 나왔다. 프레임워크는 **위치만** 본다. 문서의 「bounds of the **point-cloud** data」와 맞는다

### 죽은 가설 셋

빗나간 것도 남긴다 (규칙 4).

| 가설 | 죽은 근거 |
|---|---|
| 크기·색·활성화 함수 문제 | 값을 다 바꿔도 동일 |
| **정렬 패스가 n=1 을 못 다룬다** (bitonic sort 는 n=1 이면 비교 0회) | **2개 겹침이 안 나옴** |
| **개수가 원인이다** | 같은 2개가 되기도 안 되기도 함 |

### 아직 모르는 것

- **최소 크기 임계값이 있나** — 0.5 × 0.5 는 되지만 0.001 × 0.001 은? 안 재 봤다
- **왜** 그런가 — 「면적 0 인 경계 상자가 컬링된다」는 추론이고 내부 구현은 볼 수 없다

### 바깥에 같은 보고는 없다 (2026-09-04 조사)

Apple 문서는 count 의 **상한**만 말하고 하한은 없다. `BufferResource` 는 `count: 1` 을 throw 없이 받는다. Apple 포럼 [thread/807309](https://developer.apple.com/forums/thread/807309) 은 「API 가 있나요?」 수준이고 답변이 없다. 웹 전반에 이 API 관련 보고 자체가 거의 없다 — WWDC26 에서 나온 지 3개월이라서다.

**Feedback Assistant 에 올릴 조건을 갖췄다** — 문서에 없는 동작, 명확한 재현 조건, 위의 실측 표.

### 실전 영향

8단계부터는 실제 스캔이라 수십만 개가 퍼져 있어 **다시 만날 일이 없다.** 손으로 만든 스플랫으로 실험할 때만 걸린다.

### 배운 것 — 「최소로 줄였는데 안 된다」 싶으면 최소 그 자체를 의심하라

「하나로 시작해 의심할 곳을 줄인다」가 이 저장소의 기본 전략인데, **최소 사례가 하필 API 가 다루지 못하는 사례**였다. AI 가 세운 가설 여섯이 연달아 빗나간 뒤에야 나왔다.

그리고 **가설을 가르려면 «두 가설이 다른 답을 내는 지점» 을 골라야 한다.** 마지막 실험(2개 · x·y 동시)이 그 지점이었다 — 개수 가설이면 ❌, 면적 가설이면 ✅ 로 갈리게 설계했기 때문에 **한 번에 닫혔다.**

---

## `.spatialTracking` 으로 바꿨더니 시작할 때 버벅인다 — 정상입니다

**언제** — 2026-09-04 · 3단계

**증상** — 3단계 화면에 들어갈 때마다 카메라가 버벅이면서 켜짐. 매번.

**먼저 쟀다 (추측하지 않고)**

```swift
let t0 = CFAbsoluteTimeGetCurrent()
defer { print("⏱ makeSplatEntity \((CFAbsoluteTimeGetCurrent() - t0) * 1000) ms") }
```

**실기기(A19 Pro) 결과 — `0.54ms`.** 프레임 하나가 16.7ms 이므로 **한 프레임의 3%** 다. 버퍼 168바이트를 쓰는 게 전부이니 당연하다.

**결론** — **우리 코드는 무죄.** 버벅임은 전부 **ARKit 세션 시작 비용**이다. `.spatialTracking` 을 켜면 셋이 한꺼번에 일어난다.

1. 카메라 하드웨어 준비
2. 월드 트래킹 초기화 — 주변을 몇 프레임 봐야 「어디인지」가 잡힌다
3. 렌더 파이프라인 첫 컴파일

**없앨 수 없다.** ARKit 을 쓰는 모든 앱이 겪는다.

**할 수 있는 것 — «없애기» 가 아니라 «덜 어색하게»**

- 준비되는 동안 **왜 기다리는지 알려 준다** — 「주변을 천천히 비춰 주세요」
- 이 안내는 실제로 **시간을 줄인다.** 사용자가 폰을 움직여 주면 트래킹이 빨리 잡히고, 가만히 두면 오래 걸린다. 안내가 성능에 기여하는 드문 경우다

**배운 것 — 「느리다」 를 고치기 전에 «어디가» 느린지 재라**

재기 전에는 「버퍼 쓰는 게 무거운가?」 같은 후보가 그럴듯해 보였다. **0.54ms 라는 숫자 하나가 그 후보를 통째로 지웠고**, 남은 것이 「우리가 못 고치는 것」이라는 사실까지 알려 줬다.

**못 고친다는 것을 아는 것도 성과다.** 안 재고 최적화에 들어갔으면 며칠을 쓰고도 버벅임은 그대로였을 것이다.

**⚠️ 시뮬레이터 수치는 의미 없다** (규칙 15). 위 숫자는 실기기 값이다.

---

## `LowLevelBuffer` 의 `capacity` 는 **16의 배수**여야 한다 (P2 해결 · 실측)

**언제** — 2026-09-04 · 3단계 마무리

**증상** — 스플랫 하나(56바이트)짜리 버퍼 초기화가 던짐.

```
ResourceError(underlyingError: ... .invalid(bufferCapacity: 56))
```

**어떻게 확정했나** — 버퍼 «만들기» 는 그리기와 무관하므로, capacity 열넷을 훑는 반복문 하나로 지도를 그렸다. `sizeMultiple: 1`(기본값)로 두어 변수를 하나로 줄였다.

```swift
for c in [16, 32, 40, 48, 56, 57, 60, 64, 72, 88, 100, 112, 168, 176] {
    do { _ = try LowLevelBuffer(descriptor: .init(capacity: c, sizeMultiple: 1)); print("✅ \(c)") }
    catch { print("❌ \(c)") }
}
```

| 결과 | capacity |
|---|---|
| ✅ | 16 · 32 · 48 · 64 · 112 · 176 |
| ❌ | 40 · 56 · 57 · 60 · 72 · 88 · 100 · 168 |

**✅ 는 전부 16의 배수, ❌ 는 전부 아니다. 예외 없음.**

**결론** — `capacity` 는 **16의 배수**여야 한다. Apple 문서 산문에는 없고, 공식 예제의 `((length + 15) & ~0xF)` 가 유일한 흔적이다.

**죽은 경쟁 가설** — 「최소 크기(64 또는 128)가 있다」. `16` 이 통과했고, 64보다 큰 **72·88·100 이 전부 거부**되어 기각.

**배운 것 — 답이 같아도 근거가 다르면 다른 것이다**

처음 세운 「16의 배수」는 **점 둘**(56 실패 · 112 통과)에 맞춘 추측이었다. 112 는 「16의 배수」이면서 동시에 「56보다 큼」·「64보다 큼」이라 **세 가설을 전혀 가르지 못한다.** 그런데 Apple 예제가 같은 올림을 하는 것을 보고 확정으로 굳혀 버렸다 — **바로 앞에서 `stride 15` 를 따라 하지 않기로 배웠으면서** 같은 함정에 빠진 것이다.

사용자가 「넓혔더니 된 걸로 볼 수 있지 않나」라고 되물어 다시 열었고, **한 번의 반복문으로 점 열넷**을 얻어 확정했다.

**가설을 가르려면 «두 가설이 다른 답을 내는 지점» 을 골라야 한다.** 72·88·100 이 그 지점이었다 — 「최소 크기」면 통과, 「16의 배수」면 거부. 그런 점을 넣지 않은 시험은 몇 번을 해도 가설을 못 가른다.

**남은 추론** — **왜** 16인지는 모른다. Metal 의 정렬 단위(`float4` = 16바이트)로 짐작할 뿐 문서 근거는 없다.

---

## Apple 예제의 `stride = 15 * floatSize` 는 따라 하지 않아도 된다 (P3 해결)

**언제** — 2026-09-04 · 3단계 마무리

**의문** — `GaussianSplatComponent` 문서의 예제가 stride 를 **15 float(60바이트)** 로 잡는데, 같은 문서의 속성 표를 더하면 **14개(56바이트)** 다. offset 도 `0·3·6·10·11` 로 14개 배치와 정확히 맞는다.

**확인** — 우리 배치(stride **56**)로 스플랫 셋을 넣고 그렸다. **셋 다 제자리에, 제 색으로 보인다.**

**결론** — **56이 맞다.** 예제의 15는 그쪽 `bunny.ply` 한 행이 15개 필드여서 나온 «데이터 사정» 이지 **프레임워크 요구가 아니다.**

**다만 증명되지 않은 것 하나**

이걸로 「`MTLAttributeFormat.float3` 가 12바이트로만 읽힌다」가 증명된 것은 아니다. `capacity` 를 16의 배수로 올려 뒀기 때문에(168 → 176), **마지막 스플랫이 몇 바이트 넘겨 읽어도 여분이 받아 준다.** 색이 멀쩡한 것으로 보아 넘치더라도 무해한 자리인 것은 확실하다.

**배운 것 — 공식 예제는 «규약» 과 «그 예제의 사정» 이 섞여 있다**

막혔을 때 예제를 한 줄씩 대조한 것은 옳았다. 실제로 `sizeMultiple: 16` 과 capacity 올림은 거기서만 알 수 있었다. 하지만 **예제의 모든 숫자가 규약인 것은 아니다.**

가르는 방법은 하나다 — **문서의 «표» 와 예제의 «코드» 가 어긋나면, 표가 규약이고 코드가 사정이다.** 표는 API 를 설명하려고 쓴 것이고, 코드는 특정 파일을 읽으려고 쓴 것이니까.

그리고 **눈 감고 고친 것은 원인이 밝혀진 뒤에 하나씩 되돌려야 한다.** 안 그러면 「왜 되는지 모르는 코드」가 남는다.

---

## `.overlay` 안에 Text 를 둘 넣었더니 글자가 겹친다

**언제** — 2026-09-04 · 3단계

**증상** — 두 줄을 띄우려고 `Text` 를 둘 넣었더니 같은 자리에 **포개져** 찍힘.

```swift
.overlay(alignment: .bottom) {
    Text(note)
    Text(deviceNote)
        .font(.caption)      // ← 이것도 둘째에만 붙는다
}
```

**원인** — **`.overlay` 의 내용물은 `VStack` 이 아니라 `ZStack` 입니다.** 이름 그대로 «겹쳐 놓는» 수식어라, 뷰를 둘 주면 앞뒤로 쌓입니다.

**해결** — 나란히 놓고 싶으면 **직접 `VStack` 으로 묶습니다.** 수식어도 `VStack` 바깥에 붙여야 둘 다에 적용됩니다.

```swift
.overlay(alignment: .bottom) {
    VStack(spacing: 2) {
        Text(note)
        Text(deviceNote)
    }
    .font(.caption)          // ← VStack 에 붙이면 안쪽 Text 둘 다 받는다
    .padding(8)
}
```

**배운 것 — SwiftUI 에서 «뷰를 여러 개 나열하면» 어떻게 되는지는 자리마다 다릅니다**

| 자리 | 여러 개를 넣으면 |
|---|---|
| `VStack`·`HStack` | 세로·가로로 나란히 |
| `List`·`Section` | 줄줄이 |
| **`.overlay`·`.background`·`ZStack`** | **겹쳐서** |
| `Group` | 묶기만 하고 배치는 부모가 정함 |

「나열하면 알아서 세로로」가 아닙니다. **무엇이 배치를 정하는지**를 봐야 합니다.

그리고 **수식어는 «바로 앞의 뷰 하나»에만 붙습니다.** 여럿에 적용하려면 스택으로 묶고 스택에 붙이세요.

---

## 스플랫이 에러 없이 «아무것도» 안 그려질 때 — 3단계 디버깅 전말

**언제** — 2026-09-04 · 3단계

**증상** — `throws` 둘 다 통과, 화면 문구도 「스플랫 1개」로 정상. 그런데 화면에 아무것도 없음.

### 무엇을 어떤 순서로 지웠나

이 순서 자체가 다음에 또 쓸 자산입니다. **한 번에 하나씩, 증거를 남기며** 지웠습니다.

| # | 시험한 것 | 방법 | 결과 |
|---|---|---|---|
| 1 | 「하얗다」가 배경인가 그려진 것인가 | `.background(.blue)` 한 줄 | 파래짐 → **아무것도 안 그려짐** |
| 2 | 카메라·렌더링이 사나 | 같은 장면에 **큐브 대조군** | 큐브 보임 → 렌더 무죄 |
| 3 | 큐브가 스플랫을 가렸나 | 큐브를 옆으로 | 여전히 안 보임 |
| 4 | 크기 문제인가 | 0.05 → 0.30 | 동일 |
| 5 | 색이 묻혔나 | 초록·계수형 | 동일 |
| 6 | 기기가 못 그리나 | **화면에 GPU·apple7·iOS 를 띄움** | A19 Pro · O · 27.0 → 무죄 |
| 7 | 배선이 틀렸나 | **공식 예제와 한 줄씩 대조** | `sizeMultiple`·`bytesUsed`·`stride` 셋이 다름 → 고침 |
| 8 | 값이 제대로 들어갔나 | 버퍼를 GPU 에 주기 직전 **읽어서 print** | 열넷 다 정상 |
| 9 | **스플랫이 하나여서인가** | 셋으로 벌려 놓음 | **✅ 그려짐** |

### 원인

**스플랫 하나짜리는 그려지지 않습니다** (→ [PROBLEMS P4](PROBLEMS.md)). 원인은 아직 «부피 0 인 bounds 가 컬링된다» 는 추론 단계입니다.

가는 길에 셋을 더 고쳤습니다 — `sizeMultiple` 은 **16**, `bytesUsed` 도 **16의 배수**, `stride` 는 **15 float(60바이트)**. 셋 다 Apple 공식 예제를 문자 그대로 대조해서 나왔습니다.

### 배운 것 넷

**① 「보이지 않는다」를 둘로 쪼개라** — «배경이 그런 색인 것» 과 «그런 색이 그려진 것» 은 완전히 다른 문제입니다. `.background(.blue)` 한 줄이 이걸 가릅니다. **가장 싸고 가장 결정적인 한 줄이었습니다.**

**② 대조군은 «같은 장면» 에 두어라** — 0단계 화면에서 큐브가 보이는 것은 근거가 약합니다. 카메라도 좌표계도 다르니까요. 같은 `RealityView` 안에 넣어야 변수가 하나로 줍니다. 다만 **원점에 두면 스플랫을 삼킵니다** — 대조군은 옆에.

**③ 막히면 공식 예제를 «한 줄씩» 대조하라** — 산문 설명에는 없던 `sizeMultiple: 16` 과 `stride = 15 * floatSize` 가 예제 코드에만 있었습니다. `GaussianSplatComponent` 문서 Overview 안에 전체 예제가 들어 있습니다.

**④ 「최소로 줄였는데 안 된다」 싶으면 최소 그 자체를 의심하라** — 이 저장소의 기본 전략(하나로 시작해 의심할 곳을 줄인다)이 여기서는 **역효과**였습니다. 최소 사례가 하필 API 가 다루지 못하는 사례였거든요. **AI 가 세운 가설 여섯 개가 연달아 빗나간 뒤에야** 나온 답입니다.

### 덤 — 화면에서 확인된 것 둘

- **`sh` 는 색이 아니라 계수다.** `색 = 0.5 + 0.2820948 × sh`. 그래서 무엇을 넣어도 회색기가 섞이고, 순색을 원하면 나머지 둘을 음수로 밀어야 합니다
- **스플랫 하나가 네모로 잘려 보이는 것은 정상.** 무한히 퍼지는 가우시안을 사각형 안에서만 계산하기 때문이고, `opacity` 를 낮추면 사라집니다

---

## `var body: some View` 에서 "no return statements ... from which to infer an underlying type"

**언제** — 2026-09-04 · 3단계 타이핑 중

**증상** — `var body: some View {` 줄에 빨간 줄. 정작 body 안의 뷰 코드는 멀쩡해 보인다.

**원인** — **중괄호 짝이 어긋나 `makeSplatEntity()` 가 `body` 안에 들어가 있었다.**

```swift
var body: some View {
    RealityView { ... }
    .overlay { ... }

    func makeSplatEntity() ... { ... }   // ← body 안
}
```

`body` 는 **ViewBuilder** 라 마지막 항목을 반환값으로 잡는다. 그런데 마지막이 **함수 선언**이라 돌려줄 값이 없다. 그래서 «반환문이 없어 타입을 추론할 수 없다» 고 한다.

**해결** — `.overlay` 가 끝나는 자리에 `}` 를 넣어 `body` 를 닫고, 맨 아래 `}` 하나를 지운다. 함수가 `body` 의 **형제 메서드**가 되면 사라진다.

**배운 것 — 이 에러는 «body 가 비었다» 는 뜻이 아니다**

`some View` 에서 나는 이 에러의 원인은 대개 둘이다.

| 원인 | 확인법 |
|---|---|
| **중괄호가 어긋나 엉뚱한 것이 body 안에 있다** | **⌃I** 로 전체 들여쓰기를 다시 잡아 본다. `func` 이 `var body` 보다 안쪽이면 그것 |
| body 안 어딘가의 타입이 안 맞아 추론이 통째로 실패했다 | 뷰를 한두 개씩 지워 가며 어디서 살아나는지 본다 |

**Xcode 는 에러 위치를 «선언 줄» 에 찍습니다.** 진짜 원인은 그 아래 어딘가입니다 — 표시된 줄만 노려보면 못 찾습니다.

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

---

## Q. `generateBox(size:)` 를 그대로 썼는데 에러가 납니다

**A.** **`generateBox` 는 `MeshResource` 에 속한 «타입 메서드» 라서, 앞에 소속을 밝혀야 합니다.**

```swift
// ❌ 에러 — 이런 이름의 전역 함수는 없다
mesh: generateBox(size: SIMD3(1, 1, 1))

// ✅ 소속을 밝힌다
mesh: MeshResource.generateBox(size: 0.1)

// ✅ 또는 점만 — 파라미터 타입이 이미 MeshResource 라서 Swift 가 안다
mesh: .generateBox(size: 0.1)
```

`MeshResource` 문서를 보면 이 함수가 **「Creating a box」 절 안**에 있습니다. 그 절에 있다는 것이 곧 «`MeshResource` 의 것» 이라는 뜻이에요. 문서에서 함수를 찾았을 때 **왼쪽 사이드바의 어느 타입 밑에 있는지**를 같이 보는 습관이 여기서 값을 합니다.

**함께 걸릴 두 가지**

1. **`SIMD3(1, 1, 1)` 은 스칼라 타입이 모호할 수 있습니다.** `generateBox(size:)` 에는 **`Float` 를 받는 것과 `SIMD3<Float>` 를 받는 것 둘**이 있어서, 세 변이 같은 정육면체면 `.generateBox(size: 0.1)` 한 줄이 제일 깔끔합니다. 굳이 벡터로 쓰려면 `SIMD3<Float>(0.1, 0.1, 0.1)` 처럼 스칼라 타입을 적어 주세요.
2. **RealityKit 의 길이 단위는 «미터» 입니다.** `1` 은 **한 변이 1미터인 상자**예요. 화면을 꽉 채우다 못해 카메라가 상자 «안» 에 들어가 버려서, 흔히 «아무것도 안 보인다» 로 나타납니다. `0.1`(10cm) 근처에서 시작하세요.

> **비유** — 「`generateBox`」 는 전화번호부의 «영업팀 김민수» 같은 것입니다. 회사 이름 없이 「김민수 바꿔 주세요」 하면 교환원이 누군지 모릅니다.
> **깨지는 곳** — 다만 Swift 는 **문맥으로 회사를 추론**합니다. 「`mesh:` 자리에는 `MeshResource` 만 올 수 있다」 는 걸 알기 때문에 `.generateBox` 처럼 점만 찍어도 통합니다. 사람 교환원보다 똑똑한 셈이죠.

**어디서 나왔나** — 0단계 · 2026-09-03
**근거** — [MeshResource](https://developer.apple.com/documentation/realitykit/meshresource) · [generateBox(size:cornerRadius:)](https://developer.apple.com/documentation/realitykit/meshresource/generatebox(size:cornerradius:)-8em0v)

---

## Q. `materials:` 에 `SimpleMaterial(...)` 을 넣었는데 에러가 납니다

**A.** **`materials` 는 «재질 하나» 가 아니라 «재질 배열» 을 받습니다.** 대괄호로 감싸면 됩니다.

```swift
// ❌ 하나만 줌
materials: SimpleMaterial(color: .white, isMetallic: false)

// ✅ 배열로
materials: [SimpleMaterial(color: .white, isMetallic: false)]
```

Xcode 가 처음 채워 준 자리 표시가 이미 알려 주고 있었습니다 — `<#T##[any Material]#>`. **바깥의 대괄호 `[ ]` 가 «배열» 이라는 뜻**입니다. 자리 표시의 `T##` 뒤에 오는 것이 그 자리가 요구하는 타입이에요.

**왜 배열인가** — 메시 하나가 **여러 부분으로 나뉘어 각각 다른 재질**을 가질 수 있기 때문입니다. `generateBox(width:height:depth:cornerRadius:splitFaces:)` 에서 `splitFaces` 를 켜면 상자의 여섯 면에 서로 다른 재질을 줄 수 있어요. 그 메시가 재질을 몇 개 원하는지는 [`expectedMaterialCount`](https://developer.apple.com/documentation/realitykit/meshresource/expectedmaterialcount) 가 알려 줍니다. 하나만 주면 모든 부분에 그것이 쓰입니다.

> **읽는 요령** — 앞으로 자리 표시(`<#T##…#>`)가 보이면 **`T##` 뒤의 글자를 그대로 타입으로 읽으세요.** `[any Material]` 은 「Material 을 따르는 아무 타입이나 담은 **배열**」 입니다.

**어디서 나왔나** — 0단계 · 2026-09-03
**근거** — [ModelEntity(mesh:materials:)](https://developer.apple.com/documentation/realitykit/modelentity/init(mesh:materials:)) · [MeshResource.expectedMaterialCount](https://developer.apple.com/documentation/realitykit/meshresource/expectedmaterialcount)

---

## Q. 조명을 안 넣었는데 흰 큐브가 그냥 보입니다. 조명은 어떻게 확인하나요?

**A.** **AI 의 예고가 빗나갔습니다.** 「조명이 없으면 안 보이거나 새까맣다」 고 적었는데, 실제로는 **잘 보입니다.**

`RealityView` 를 AR 아닌 모드(`content.camera = .virtual`)로 쓰면 **RealityKit 이 기본 조명 환경을 하나 깔아 줍니다.** 조명 엔티티를 단 하나도 안 넣어도 씬은 이미 밝습니다. 그래서 `SimpleMaterial` 이 «빛을 받는 재질» 이라는 사실이 **«보인다 / 안 보인다» 로는 드러나지 않습니다.**

### 그럼 어떻게 확인하나

**흰 배경에 흰 큐브로는 아무것도 안 보입니다.** 두 가지를 바꿔야 차이가 드러납니다.

1. **색을 흰색이 아닌 것으로** — `.red` 처럼
2. **큐브를 살짝 돌려 두 면 이상이 보이게** — `box.orientation` 을 만지면 됩니다

그 상태에서 **면마다 밝기가 다른지** 보세요. 다르면 빛이 닿고 있다는 뜻입니다.

그리고 재질만 한 줄 바꿔 비교합니다.

| 재질 | 보이는 모습 |
|---|---|
| `SimpleMaterial(color: .red, isMetallic: false)` | 면마다 밝기가 다름. **«상자» 로 보임** |
| `UnlitMaterial(color: .red)` | 전부 같은 빨강. **«빨간 육각형» 으로 보임** |

**그 차이가 «빛을 받는다» 의 정체입니다.**

> **비유** — 흰 종이에 흰 크레용으로 그린 것과 같습니다. 크레용이 안 나오는 게 아니라 **배경과 구별이 안 되는** 것이죠.
> **깨지는 곳** — 크레용은 색만 문제지만 여기서는 «면마다 밝기가 다른가» 라는 정보가 통째로 사라집니다. 흰색은 명암이 가장 안 읽히는 색입니다.

### 왜 이게 중요한가

**11단계의 예고편이기 때문입니다.** 스플랫은 `UnlitMaterial` 쪽에 가깝습니다 — 색이 **촬영 당시 조명 그대로 구워져** 있어서, 씬의 조명을 아무리 올려도 미동도 하지 않습니다. Apple 문서가 그렇게 못 박고 있어요.

> Important: Scene lighting doesn't affect a Gaussian splat asset. The color of the rendered output reflects the lighting conditions present during the original capture.

지금 이 두 큐브의 차이를 눈에 익혀 두면, 11단계에서 「왜 스플랫만 안 변하지」 가 이미 아는 이야기가 됩니다.

**어디서 나왔나** — 0단계 · 2026-09-03
**근거** — [SimpleMaterial](https://developer.apple.com/documentation/realitykit/simplematerial) (*"A basic material that responds to lights in the scene"*) · [UnlitMaterial](https://developer.apple.com/documentation/realitykit/unlitmaterial) · [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent)

---

## Q. 왜 스플랫에 Apple7 GPU 패밀리 이상이 필요한가

**A. Apple 은 «필요하다» 고만 적고 «왜» 는 안 적었습니다.** 문서 전체를 뒤졌지만 이유를 못 찾았습니다. 그래서 여기서는 **확인된 것**과 **추론**을 나눠 적습니다.

### 확인된 것 (문서)

| 사실 | 출처 |
|---|---|
| *"Gaussian splats require a device with Apple7 GPU family support."* | [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) |
| Apple7 = **Apple A14 와 M1 GPU** | [MTLGPUFamily.apple7](https://developer.apple.com/documentation/metal/mtlgpufamily/apple7) |
| 그래서 실질적으로 **iPhone 12 이상**, **M1 이상 맥** | 위 둘의 조합 |
| 어느 «기능» 이 결정적인지 | **문서에 없음. 못 찾았습니다** |

### 추론 — 스플랫 렌더링이 «보통 그리기» 가 아니기 때문

⚠️ **아래는 확인된 사실이 아니라 정황에서 세운 추론입니다.**

메시 하나를 그리는 것과 스플랫 수십만 개를 그리는 것은 GPU 가 하는 일의 «종류» 가 다릅니다. 원 논문([Kerbl et al. 2023](https://ar5iv.labs.arxiv.org/html/2308.04079))이 밝힌 렌더러 구조가 이렇습니다.

1. **매 프레임 전체 정렬** — 모든 스플랫을 «깊이 + 타일 번호» 키로 **GPU 라딕스 정렬**. 반투명한 것은 뒤에서 앞으로 겹쳐야 색이 맞기 때문
2. **화면을 16×16 타일로 쪼개 담기** — 스플랫 하나가 여러 타일에 걸치면 그만큼 복제
3. **타일마다 스레드 블록 하나** — 스플랫 묶음을 **공유 메모리**에 같이 올려 놓고 블렌딩
4. **알파가 포화되면 조기 종료** — 스레드들이 주기적으로 서로 물어봄

즉 **매 프레임 돌아가는 대규모 컴퓨트 파이프라인**입니다. 삼각형을 던지는 일이 아니에요. Apple7(A14·M1)은 Apple GPU 의 컴퓨트 능력과 메모리 대역폭이 크게 올라간 세대이고, **Apple 이 «이 아래로는 실용적인 프레임이 안 나온다» 고 그은 선일 가능성이 큽니다.**

> **하지만 이건 «가능성이 크다» 이지 «그렇다» 가 아닙니다.** 특정 Metal 기능(원자적 연산·SIMD 그룹 연산·타일 메모리 중 무엇)이 하한선을 정했는지는 확인하지 못했습니다.

### 실무에서 뭘 하면 되나

**0단계에서 만든 `checkGPUFamily()` 가 그 답입니다.** 이유를 몰라도 **기기가 되는지 안 되는지는 코드로 물어볼 수 있습니다.** 3단계에서 아무것도 안 보일 때, 이 한 줄이 «내 코드가 틀렸나 / 기기가 안 되나» 를 갈라 줍니다.

**어디서 나왔나** — 0단계 완료 직후 · 2026-09-03
**근거** — [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) · [MTLGPUFamily](https://developer.apple.com/documentation/metal/mtlgpufamily) · [3D Gaussian Splatting for Real-Time Radiance Field Rendering (Kerbl et al. 2023)](https://ar5iv.labs.arxiv.org/html/2308.04079)

---

## Q. 구조체에 담아 스플랫을 표현하는 게 «맞는» 방법인가? Metal 로 직접 만들 수도 있나?

**A.** **이 구조체는 «맞는 표현» 이 아니라 «학습용 발판» 입니다.** RealityKit 은 `Splat` 구조체를 본 적이 없고 앞으로도 못 봅니다. RealityKit 이 아는 것은 **날것의 float 덩어리와 `BufferDescriptor`** 뿐입니다.

### 층이 셋

```
① 파일 (PLY)          디스크에 저장된 형태 · 필드 62개
        ↓
② 구조체 Splat         사람이 읽기 위한 형태 · 80바이트   ← 선택 사항
        ↓
③ GPU 버퍼            실제로 그려지는 형태 · 56바이트
```

**②는 없어도 됩니다.** ① → ③ 직행이 가능하고 **실무에서는 대개 그렇게 합니다.** 스플랫 50만 개를 `[Splat]` 로 만들면 `80 × 50만 = 40MB` 를 만들었다가 버퍼로 옮기며 `56 × 50만 = 28MB` 를 또 만듭니다. 68MB 를 쓰고 40MB 를 버리는 셈입니다.

**그래서 9단계쯤에서 이 구조체를 버릴 가능성이 큽니다.** 지금 만드는 것이 영원히 남는 설계가 아닙니다.

### 그럼 왜 지금 만드나

**«내가 정한 배치» 와 «GPU 가 원하는 배치» 가 다르다는 것을 몸으로 알려면 둘 다 있어야 하기 때문입니다.** ②를 건너뛰면 코드는 짧아지지만 `stride`·`offset`·정렬이 **왜** 그렇게 생겼는지 알 기회가 사라집니다. 3단계까지는 스플랫이 한 개~열 개라 성능이 문제가 안 되니, 그 구간을 배우는 데 씁니다.

### Metal 로 직접 — 됩니다

`GaussianSplatComponent` 는 RealityKit 이 주는 **한 가지 길**일 뿐이고 그 아래는 결국 Metal 입니다.

| | RealityKit (이 저장소) | Metal 직접 |
|---|---|---|
| 매 프레임 정렬 | **프레임워크가 함** | 컴퓨트 셰이더로 직접 |
| 블렌딩 순서 | 함 | 직접 |
| 셰이더 | **못 만짐** | 마음대로 |
| 코드량 | 수십 줄 | 수천 줄 |

[MetalSplatter](https://github.com/scier/MetalSplatter) 가 그 «Metal 직접» 구현입니다. Apple 이 스플랫 API 를 내기 전부터 있던 오픈소스예요. 이 저장소는 **파서(`SplatIO`)만** 빌려 쓰고 렌더링은 RealityKit 에 맡깁니다.

**WebGPU·Unity·Unreal·Vulkan 도 다 됩니다.** 데이터는 그냥 숫자이고, 다른 것은 **«누가 정렬하고 누가 블렌딩하느냐»** 뿐입니다.

**어디서 나왔나** — 1단계 타이핑 직전 · 2026-09-03
**근거** — [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) (*"you parse your source format ... and populate the buffers yourself"*) · [MetalSplatter](https://github.com/scier/MetalSplatter)

---

## Q. `simd_quatf` 를 썼는데 «그런 타입 없음» 이라고 나옵니다

**A.** **`import simd` 가 빠진 것입니다.**

같은 파일에서 `SIMD3<Float>` 는 잘 되는데 `simd_quatf` 만 안 되는 것이 헷갈리는 지점입니다. **둘의 출신이 다릅니다.**

| 타입 | 어디 것 | import |
|---|---|---|
| `SIMD3<Float>` · `SIMD4<Float>` | **Swift 표준 라이브러리** | 필요 없음 |
| `simd_quatf` · `simd_float4x4` | **`simd` 모듈** | `import simd` |

이름이 `SIMD` 로 시작하느냐 `simd_` 로 시작하느냐가 대충의 구분선입니다 — 앞의 것은 Swift 가 직접 만든 타입이고, 뒤의 것은 **C 의 simd 라이브러리를 Swift 로 끌어온 것**입니다. `simd_quatf` 의 이니셜라이저가 `init(ix:iy:iz:r:)` 처럼 C 스러운 것도 그 때문이고요.

**어디서 나왔나** — 1단계 · 2026-09-03
**근거** — [simd_quatf](https://developer.apple.com/documentation/simd/simd_quatf) · [SIMD3](https://developer.apple.com/documentation/swift/simd3)

---

## Q. `row(_:_:)` 를 제네릭으로 만들어 Float 와 Int 를 둘 다 받게 할 수 있나?

**A.** **됩니다. 그런데 «되는 것» 과 «이득인 것» 이 다릅니다.**

```swift
func row<V: Numeric>(_ name: String, _ value: V) -> some View {
    ...
    Text(String(format: "%.3f", value))   // ← 여기서 막힌다
}
```

`Float` 과 `Int` 는 둘 다 `Numeric` 이라 **매개변수는 잘 묶입니다.** 문제는 **함수 «안» 에서 할 수 있는 일**입니다.

- `"%.3f"` 는 **부동소수점용** 형식입니다. `Int` 를 넣으면 쓰레기 값이 나오고 경고도 안 뜹니다
- `Int` 에 맞추려면 `"%d"` 인데 그럼 `Float` 이 깨집니다
- **그리고 애초에 둘은 다르게 보여야 합니다** — `0.100` 과 `80` 이요. 크기 표에 `80.000` 이 뜨면 이상합니다

> **제네릭은 «타입을 묶는» 도구지 «표현을 묶는» 도구가 아닙니다.** 화면에 다르게 보여야 하는 둘을 억지로 묶으면 함수 안에서 다시 갈라야 해서 이득이 없습니다. [RULES 규칙 11](RULES.md#규칙-11의-의미) 의 «적용하지 않는 자리» 에 있는 그 상황입니다.

### 골랐던 것 — 값을 «문자열로» 받기

```swift
func row(_ name: String, _ value: String) -> some View
```

이유 셋.

1. **포맷을 부르는 쪽이 정합니다** — Float 은 `%.3f`, Int 는 `"\(n)"`, 나중엔 `"56 → 80 (+24)"` 같은 계산된 문자열도 그대로 들어갑니다
2. **2단계에서 값을 합니다** — 거기서는 «넣은 값 vs 꺼낸 값» 을 한 줄에 나란히 적게 됩니다
3. 함수는 «가로로 배치하는 일» 만 하게 됩니다. 숫자를 어떻게 보여줄지는 그 함수가 알 바가 아닙니다 — **[SRP]**

**대안이었던 것** — 오버로드 둘(`row(_:_: Float)` · `row(_:_: Int)`)도 나쁘지 않습니다. 부르는 쪽이 제일 짧아지는 대신 배치 코드가 두 벌이 됩니다.

**어디서 나왔나** — 1단계 · 2026-09-03
