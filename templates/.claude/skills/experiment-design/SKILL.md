---
name: experiment-design
description: 실험 설계 — 변수 통제, 파라미터 공간 정의, 실험 방법론을 체계적으로 명세합니다.
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /experiment-design — 실험 설계

## 역할

- **Lead**: Claude (변수 통제, 파라미터 공간 정의에 정밀 추론)
- **Support**: Gemini (탐색적 제안)

## 사전 확인 (필수)

1. `.research/context.md` — 현재 연구 맥락
2. `.research/scope-mode.txt` — 현재 모드 확인
3. `.research/plans/hypothesis-{topic}-final.md` — 확정된 가설
4. `.research/wisdom.md` — 과거 실험 교훈

**Scope Mode 제한**: `EXPLORATION` 모드에서는 파라미터를 확정하지 말고 방향성만 논의하세요.

## Claude의 행동 (Lead)

### Phase 1: 연구자와 Atomic Decision
**한 번에 하나씩** 다음 항목을 연구자에게 확인합니다:

1. **목표 변수 (Dependent Variable)**: 무엇을 측정할 것인가?
2. **독립 변수 (Independent Variable)**: 무엇을 변화시킬 것인가?
3. **통제 변수 (Control Variable)**: 무엇을 고정할 것인가?
4. **도구/시뮬레이터**: 어떤 도구를 사용할 것인가?
5. **파라미터 범위**: 각 변수의 탐색 범위는?
6. **베이스라인**: 비교 기준은?
7. **성공 기준**: 어떤 결과가 가설을 지지/반박하는가?

> ⚠️ 여러 결정을 한꺼번에 묶어서 진행하지 마세요 (Atomic Decision 원칙).

### Phase 2: 실험 계획서 작성
모든 결정이 확인되면 다음 구조로 작성합니다:

```markdown
# 실험 계획: {name}

## 가설
(hypothesis-final에서 인용)

## 실험 변수
| 유형 | 변수 | 값/범위 |
|------|------|---------|
| Independent | ... | ... |
| Dependent | ... | ... |
| Control | ... | ... |

## 도구 및 환경
- 시뮬레이터: ...
- 워크로드: ...
- 하드웨어/환경: ...

## 실험 매트릭스
(전체 파라미터 조합)

## 베이스라인
...

## 성공 기준
...

## 예상 소요 시간
...
```

### Phase 3: decisions.md 업데이트
핵심 설계 결정을 `.research/decisions.md`에 기록합니다.

## Hard Gate

이 스킬에서는 **코드 작성, 파일 편집, 명령 실행이 차단**됩니다.
설계와 계획 수립에만 집중하세요.

## 출력

| 역할 | 출력 파일 |
|------|----------|
| Lead (Claude) | `.research/plans/experiment-{name}-draft.md` |
| Support (Gemini) | `.research/plans/experiment-{name}-review.md` |
| 최종 (Lead 반영) | `.research/plans/experiment-{name}-final.md` |
