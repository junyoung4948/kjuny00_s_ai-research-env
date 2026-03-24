---
name: brainstorm
description: 가설 수립 — 넓은 탐색으로 연구 아이디어를 발산하고, 논리적 허점을 검증합니다.
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /brainstorm — 가설 수립

## 역할

- **Lead**: Gemini (넓은 컨텍스트로 논문 참조, 아이디어 연결)
- **Support (Claude)**: Lead의 draft를 논리적으로 검증하여 review 작성

## 사전 확인 (필수)

1. `.research/context.md` — 현재 연구 맥락
2. `.research/scope-mode.txt` — 현재 모드 확인
3. `.research/wisdom.md` — 과거 실패/성공 패턴

**Scope Mode 제한**: `REFINEMENT` 또는 `FOCUSED` 모드에서는 새로운 방향 탐색을 자제하세요.

## Claude의 행동 (Support)

### Phase 1: draft 검토
1. `.research/plans/hypothesis-{topic}-draft.md`를 읽습니다.
2. 각 가설에 대해 다음을 검증합니다:
   - 논리적 일관성: 전제 → 결론 흐름에 비약이 없는가?
   - 실현 가능성: 우리 환경(시뮬레이터, 하드웨어)에서 검증 가능한가?
   - 기존 연구와의 차별점: 이미 해결된 문제를 다시 풀고 있지 않은가?
   - wisdom.md의 과거 교훈과 충돌하지 않는가?

### Phase 2: review 작성
3. `.research/plans/hypothesis-{topic}-review.md`를 작성합니다.
4. 각 가설별로 구조화된 피드백:
   - **강점**: 논리적으로 탄탄한 부분
   - **약점/우려**: 발견된 논리적 허점
   - **제안**: 보완 방향 또는 대안
   - **추천 우선순위**: 가설 간 상대적 유망도

## Hard Gate

이 스킬에서는 **코드 작성, 파일 편집, 명령 실행이 차단**됩니다.
사고와 분석에만 집중하세요.

## 출력

| 역할 | 출력 파일 |
|------|----------|
| Lead (Gemini) | `.research/plans/hypothesis-{topic}-draft.md` |
| Support (Claude) | `.research/plans/hypothesis-{topic}-review.md` |
| 최종 (Lead 반영) | `.research/plans/hypothesis-{topic}-final.md` |
