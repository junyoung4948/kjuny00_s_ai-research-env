---
name: analyze
description: 결과 분석 — 실험 결과의 패턴, 트렌드, 이상치를 파악하고 시각화를 추천합니다.
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - AskUserQuestion
---

# /analyze — 결과 분석

## 역할

- **Lead**: Gemini (큰 컨텍스트로 대량 데이터 패턴 파악, 멀티모달)
- **Support (Claude)**: Lead의 분석에 대한 수치 정확성 검증

## 사전 확인 (필수)

1. `.research/context.md` — 현재 연구 맥락
2. `.research/scope-mode.txt` — 현재 모드 확인
3. `.research/plans/experiment-{name}-final.md` — 실험 설계서
4. `.research/feedback/validation-{name}.md` — 검증 보고서 (있는 경우)
5. `.research/wisdom.md` — 과거 분석 패턴

**Scope Mode 제한**: `WRITING` 모드에서는 새 분석을 시작하지 말고 기존 분석을 정리하세요.

## Claude의 행동 (Support)

### Phase 1: Gemini 분석 검토
1. `.research/feedback/analysis-{name}-draft.md`를 읽습니다.
2. 다음을 검증합니다:
   - **수치 정확성**: Gemini가 인용한 수치가 원본 데이터와 일치하는가?
   - **통계적 주장**: 주장의 근거가 되는 계산이 올바른가?
   - **비교의 공정성**: 서로 다른 조건을 공정하게 비교하고 있는가?
   - **누락된 관점**: Gemini가 놓친 중요한 패턴이나 이상치가 있는가?

### Phase 2: review 작성
3. `.research/feedback/analysis-{name}-review.md`를 작성합니다.
4. 구조화된 피드백:
   - **확인된 발견**: 수치적으로 정확한 분석 결과
   - **수정 필요**: 오류가 있는 수치나 주장
   - **추가 분석 제안**: 놓친 패턴이나 추가 시각화 추천
   - **시각화 피드백**: 추천된 시각화 방법에 대한 의견

## Hard Gate

이 스킬에서는 **코드 작성, 파일 편집, 명령 실행이 차단**됩니다.
분석 검토와 피드백 작성에만 집중하세요.

## FROZEN 디렉토리 주의

`profiling/results/`와 `simulation/results/`는 읽기 전용입니다.
분석 시 원본을 직접 읽기만 하세요.

## 출력

| 역할 | 출력 파일 |
|------|----------|
| Lead (Gemini) | `.research/feedback/analysis-{name}-draft.md` |
| Support (Claude) | `.research/feedback/analysis-{name}-review.md` |
| 최종 (Lead 반영) | `.research/feedback/analysis-{name}-final.md` |
