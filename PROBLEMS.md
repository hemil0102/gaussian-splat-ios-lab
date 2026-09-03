# PROBLEMS — 아직 못 푼 것

**재현되지만 해결하지 못하고 우회 중인 것**만 여기 둡니다 (규칙 17). 풀리면 [Q&A.md](Q&A.md) 로 옮기고 여기서 지웁니다.

«아마도» 로 빈칸을 메우지 않습니다. **모른다는 것을 지우지 않는 자리**입니다.

상태 : 🔴 우회책 없음 · 🟡 우회 중 · 🟢 해결됨(옮기기 대기)

---

## 목록

| | 제목 | 상태 | 걸리는 단계 |
|---|---|:---:|---|
| P1 | [스플랫 개수 상한의 정확한 값을 모른다](#p1--스플랫-개수-상한의-정확한-값을-모른다) | 🟡 | 04 · 07 |

---

## P1 · 스플랫 개수 상한의 정확한 값을 모른다

### 증상

`GaussianSplatResource.BufferResource` 초기화가 «내부 제한» 을 넘으면 던진다고 문서에 적혀 있는데, **그 숫자가 어디에도 없습니다.**

> The framework enforces an internal limit on the total number of splats, and the `BufferResource` initializer throws if you exceed it.

### 왜 문제인가

- Scaniverse 스캔 하나가 수십만~수백만 스플랫입니다. **상한을 모르면 컬링을 얼마나 해야 하는지 정할 수 없습니다**
- 기기별로 다른지, 메모리에 따라 달라지는지도 불명입니다

### 시도했지만 실패한 것

- 공식 문서 전체(컴포넌트·리소스·버퍼 리소스·샘플 코드) — 숫자 없음
- WWDC26 279·287 세션 — 언급 없음

### 지금의 대처

**실측합니다.** 4단계에서 프로시저럴로 개수를 늘려 가며 throw 가 나는 지점을 찾고, 그 숫자를 여기와 [APPLE_DOCS.md](APPLE_DOCS.md) 에 적습니다.

그때까지는 **`try!` 를 절대 쓰지 않고** 에러를 잡아 화면에 표시합니다 — 상한이 이 에러로만 드러나기 때문입니다.

### 다시 볼 조건

- 4단계 실측이 끝났을 때 → 숫자를 적고 🟢 로
- 기기를 바꿔서 숫자가 달라졌을 때 → 기기별 표로

### 참고

- [GaussianSplatComponent](https://developer.apple.com/documentation/realitykit/gaussiansplatcomponent) · Performance Considerations
