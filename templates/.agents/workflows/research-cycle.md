# Research Cycle Workflow

이 파일은 Antigravity(Gemini)가 `.agents/workflows/`에서 참조하는 연구 사이클 워크플로우입니다.

---

## 전체 연구 사이클

```
EXPLORATION → REFINEMENT → FOCUSED → WRITING
     ↑                                  |
     └──────────── (회고 후 재탐색) ──────┘
```

### Phase 1: EXPLORATION (방향 탐색)

**목표**: 연구 아이디어 발산 및 가설 수립

```
[Gemini] /brainstorm → hypothesis-draft.md
    ↓ (연구자가 Claude에게 review 요청)
[Claude] review → hypothesis-review.md
    ↓ (연구자가 Gemini에게 반영 요청)
[Gemini] 반영 → hypothesis-final.md
    ↓ (연구자가 가설 선택)
```

**허용**: 자유로운 아이디어 탐색, 논문 조사
**자제**: 코드 작성, 파라미터 확정

---

### Phase 2: REFINEMENT (구체화)

**목표**: 선택된 가설에 대한 실험 설계

```
[Claude] /experiment-design → experiment-draft.md
    ↓ (연구자가 Gemini에게 review 요청)
[Gemini] review → experiment-review.md
    ↓ (연구자가 Claude에게 반영 요청)
[Claude] 반영 → experiment-final.md
```

**허용**: 실험 설계, 변수 정의
**자제**: 새로운 방향 제안

---

### Phase 3: FOCUSED (집중 실행)

**목표**: 실험 구현, 실행, 검증

```
[Claude] 시뮬레이션 스크립트 구현
[Gemini] 분석 스크립트 구현
    ↓
[Claude] 실험 실행/모니터링
    ↓
[Claude] /validate → validation-{name}.md
    ↓ (실패 시)
[Claude] /diagnose → diagnosis-{name}.md (3-Strike Rule)
    ↓ (성공 시)
[Gemini] /analyze → analysis-draft.md
    ↓
[Claude] review → analysis-review.md
    ↓
[Gemini] 반영 → analysis-final.md
```

**허용**: 코드 구현, 실험 실행, 디버깅
**자제**: 방향 전환, 새 아이디어

---

### Phase 4: WRITING (문서화)

**목표**: 연구 결과를 논문/보고서로 정리

```
[Gemini] /document → {section}-draft.md
    ↓
[Claude] review → {section}-review.md
    ↓
[Gemini] 반영 → {section}-final.md
```

**허용**: 논문 작성, 시각화
**자제**: 새 실험 실행, 코드 대규모 수정

---

### 사이클 완료 후: 회고

```
[Claude] /reflect → retros/{date}.md
    → wisdom.md 갱신
    → context.md 갱신
    → (연구자와 다음 방향 논의)
```

---

## Handoff 체크리스트

모델 간 산출물을 전달할 때 연구자가 확인할 항목:

- [ ] Lead가 `*-draft.md`를 완성했는가?
- [ ] Support에게 review를 요청했는가?
- [ ] Support가 `*-review.md`를 작성했는가?
- [ ] Lead에게 review 반영을 요청했는가?
- [ ] Lead가 `*-final.md`를 생성했는가?
- [ ] 연구자가 최종 산출물을 확인했는가?
