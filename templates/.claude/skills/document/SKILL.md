---
name: document
description: 논문/보고서 작성 — 연구 결과를 체계적으로 문서화합니다. Gemini가 초안, Claude가 교정.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - AskUserQuestion
---

# /document — 논문/보고서 작성

## 역할

- **Lead (초안)**: Gemini (스토리라인 구성, 초안 작성)
- **Support (교정)**: Claude (기술적 정확성 검증)

## 사전 확인 (필수)

1. `.research/context.md` — 현재 연구 맥락
2. `.research/scope-mode.txt` — 현재 모드 확인 (`WRITING` 권장)
3. `.research/plans/hypothesis-{topic}-final.md` — 확정된 가설
4. `.research/plans/experiment-{name}-final.md` — 실험 설계
5. `.research/feedback/analysis-{name}-final.md` — 분석 결과
6. `.research/feedback/validation-{name}.md` — 검증 결과

## Claude의 행동 (Support — 교정)

### Phase 1: 초안 검토
1. `docs/sections/{section}-draft.md`를 읽습니다.
2. 다음을 검증합니다:

**기술적 정확성**
- 인용된 수치가 실험 결과와 일치하는가?
- 방법론 설명이 실제 실험 설계와 일치하는가?
- 수식/알고리즘이 올바른가?

**논리적 흐름**
- 주장과 근거의 연결이 명확한가?
- 섹션 간 흐름이 자연스러운가?

**완전성**
- 빠진 실험 조건이나 결과가 없는가?
- 한계점(limitations)이 적절히 언급되었는가?

### Phase 2: review 작성
3. `docs/sections/{section}-review.md`를 작성합니다.
4. 구조화된 피드백:
   - **수정 필요 (Must Fix)**: 기술적 오류, 수치 불일치
   - **개선 제안 (Suggestion)**: 표현, 구조, 설명 개선
   - **확인 완료 (Verified)**: 정확성이 확인된 부분

### Hard Gate 예외

**원본(draft)을 직접 수정하지 마세요.**
별도 review 파일에만 피드백을 작성합니다.
Edit/Write 도구는 review 파일 작성에만 사용하세요.

## 출력

| 역할 | 출력 파일 |
|------|----------|
| Lead (Gemini) | `docs/sections/{section}-draft.md` |
| Support (Claude) | `docs/sections/{section}-review.md` |
| 최종 (Lead 반영) | `docs/sections/{section}-final.md` |
