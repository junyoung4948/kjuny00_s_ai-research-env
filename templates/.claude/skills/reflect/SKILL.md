---
name: reflect
description: 회고 — 연구 사이클을 되돌아보며 인사이트를 정리하고, context/wisdom을 갱신합니다.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
  - AskUserQuestion
---

# /reflect — 회고

## 역할

- **Lead**: Claude (Memory 시스템으로 세션 간 연속성 유지)

## 사전 확인 (필수)

1. `.research/context.md` — 현재 연구 맥락
2. `.research/wisdom.md` — 기존 인사이트
3. `.research/decisions.md` — 기존 결정 기록
4. 최근 작업의 관련 artifact들 (plans, feedback, logs)

## Claude의 행동 (Lead)

### Phase 1: 사실 수집
1. 최근 연구 사이클에서 수행한 작업을 정리합니다:
   - 어떤 가설을 검증했는가?
   - 실험 결과는 어떠했는가?
   - 예상과 다른 점이 있었는가?

### Phase 2: 인사이트 도출
2. 다음 질문에 답합니다:
   - **성공**: 무엇이 잘 되었는가? 왜?
   - **실패**: 무엇이 실패했는가? 왜?
   - **놀라움**: 예상과 달랐던 점은?
   - **교훈**: 다음에 적용할 수 있는 교훈은?
   - **도구/프로세스**: 시뮬레이터, 분석 방법 등에서 배운 팁은?

### Phase 3: 회고록 작성
3. `.research/retros/{date}.md`를 작성합니다:

```markdown
# 회고: {date}

## 이번 사이클 요약
- 기간: ...
- 목표: ...
- 결과: ...

## 잘 된 점
- ...

## 아쉬운 점
- ...

## 예상과 달랐던 점
- ...

## 교훈
- ...

## 다음 단계 제안
- ...
```

### Phase 4: 컨텍스트 갱신
4. `.research/wisdom.md`에 새 인사이트를 추가합니다.
   - 형식: `- [{date}] {인사이트 내용}`
   - **기존 항목은 삭제하지 마세요** (추가만)

5. `.research/context.md`를 현재 상태에 맞게 갱신합니다.
   - 진행 상황, 다음 단계 등을 업데이트

6. 연구자에게 다음을 확인합니다:
   - scope-mode 변경이 필요한가?
   - 연구 방향 수정이 필요한가?

## 출력

| 출력 파일 | 설명 |
|----------|------|
| `.research/retros/{date}.md` | 회고 기록 |
| `.research/wisdom.md` | 인사이트 추가 (갱신) |
| `.research/context.md` | 연구 맥락 갱신 |
