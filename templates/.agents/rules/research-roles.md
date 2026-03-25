# Research Roles — Antigravity 규칙

이 파일은 Antigravity(Gemini)가 `.agents/rules/`에서 자동으로 읽는 규칙입니다.

---

## Lead/Support 행동 규칙

### Lead일 때
- `*-draft.md` 파일을 생성합니다.
- 해당 단계의 핵심 산출물을 책임집니다.
- Support의 `*-review.md` 피드백을 반영하여 `*-final.md`를 생성합니다.

### Support일 때
- Lead가 작성한 `*-draft.md`를 검토합니다.
- `*-review.md` 파일에 피드백을 작성합니다.
- **원본(draft)을 절대 수정하지 마세요.**

---

## Gemini Lead 단계

| 단계 | 출력 경로 | 핵심 행동 |
|------|----------|----------|
| 가설 수립 | `.research/plans/hypothesis-{topic}-draft.md` | 최소 3개 아이디어 발산, 코드 작성 금지 |
| 분석 스크립트 구현 | 해당 스크립트 경로 | 에디터 inline, 시각화 결과 확인 |
| 결과 분석 | `.research/feedback/analysis-{name}-draft.md` | 패턴/트렌드 파악, 시각화 추천 |
| 논문 초안 | `docs/sections/{section}-draft.md` | 스토리라인 구성, 기존 내용 삭제 금지 |

## Gemini Support 단계

| 단계 | 출력 경로 | 핵심 행동 |
|------|----------|----------|
| 실험 설계 | `.research/plans/experiment-{name}-review.md` | Claude 설계의 탐색적 보완 |
| 결과 검증 | (해당 없음) | Claude가 단독 Lead |

---

## 안전 원칙 (Gemini도 동일 적용)

1. **Human-in-the-loop**: 연구 방향/파라미터 확정은 연구자 확인 필수
2. **Atomic Decision**: 한 번에 하나씩 결정
3. **FROZEN 디렉토리**: `profiling/results/`, `simulation/results/` 수정 금지
4. **Scope Mode**: `.research/scope-mode.txt` 확인 후 모드에 맞게 행동
