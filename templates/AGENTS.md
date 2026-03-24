# AI 연구 파트너 공유 규칙

이 문서는 Claude Code와 Antigravity(Gemini) **양쪽이 자동으로 읽는 공유 규칙**입니다.
모든 AI 에이전트는 이 규칙을 준수합니다.

---

## 1. 프로젝트 개요

- **분야**: 컴퓨터 아키텍처 / 시스템 연구
- **연구자**: 대학원생 (human-in-the-loop 기본 원칙)
- **주요 작업**: 아이디어 토론, LLM 프로파일링, 시뮬레이션(Analytical Modeling), Design Space Exploration
- **플랫폼**: Antigravity(Gemini) + Claude Code(Opus/Sonnet)

---

## 2. 모델 역할 분담 (단계별 Lead/Support)

각 연구 단계에서 해당 작업의 핵심 요구에 가장 적합한 모델이 **Lead**를 맡습니다.

| 연구 단계 | Lead | Support | Lead 선정 이유 |
|-----------|------|---------|---------------|
| 가설 수립 (`/brainstorm`) | **Gemini** | Claude (논리 검증) | 넓은 컨텍스트로 논문 여러 편 참조하며 아이디어 연결 |
| 실험 설계 (`/experiment-design`) | **Claude** | Gemini (탐색적 제안) | 변수 통제, 파라미터 공간 정의에 정밀 추론 필요 |
| 시뮬레이션 스크립트 구현 | **Claude** | — | CLI 네이티브, 직접 실행/디버깅 가능 |
| 분석 스크립트 구현 | **Gemini** | — | 에디터 inline, 시각화 결과 멀티모달 확인 |
| 실험 실행/모니터링 | **Claude** | — | CLI에서 프로세스 관리, 로그 모니터링 |
| 결과 검증 (`/validate`) | **Claude** | — | 수치 범위 검증, 일관성 체크에 정밀 추론 |
| 결과 분석 (`/analyze`) | **Gemini** | Claude (수치 검증) | 큰 컨텍스트로 대량 데이터 패턴 파악, 멀티모달 |
| 논문 작성 (`/document`) | **Gemini** (초안) | Claude (교정) | 스토리라인 구성 → 기술적 정확성 검증 분리 |
| 회고 (`/reflect`) | **Claude** | — | Memory 시스템으로 세션 간 연속성 유지 |
| 실패 진단 (`/diagnose`) | **Claude** | — | 체계적 디버깅, 로그 파싱, 3-Strike Rule |

### Lead/Support 행동 원칙
- **Lead**: 해당 단계의 주요 산출물을 작성. `*-draft.md`를 생성.
- **Support**: Lead의 산출물을 검토하여 `*-review.md`를 작성. 원본을 수정하지 않음.
- Lead가 review를 반영하여 `*-final.md`를 생성.

---

## 3. Category 가이드 (참고용)

작업 유형에 따라 권장하는 모델 흐름입니다. 강제 규칙이 아니라 가이드라인입니다.

| Category | 모델 흐름 | 설명 |
|----------|----------|------|
| **discussion** | Gemini(발산) → Claude(수렴/검증) | 아이디어 토론, 브레인스토밍 |
| **profiling** | Claude(설계) → Gemini(스크립트) → Claude(분석) | LLM 프로파일링 실험 |
| **simulation** | Claude(모델 설계) → Gemini(코드 구현) → Claude(검증) | 시뮬레이션 기반 평가 |
| **writing** | Gemini(초안) → Claude(교정) → Gemini(최종) | 논문/보고서 |

---

## 4. Scope Mode

`.research/scope-mode.txt`에 현재 연구 단계가 기록되어 있습니다.
**작업 전 반드시 이 파일을 확인하고, 현재 모드에 맞지 않는 행동을 자제하세요.**

| Mode | 의미 | 허용 행동 | 자제할 행동 |
|------|------|----------|------------|
| **EXPLORATION** | 방향 탐색 중 | 자유롭게 아이디어 탐색, 논문 조사 | 코드 작성, 파라미터 확정 |
| **REFINEMENT** | 구체화 중 | 실험 설계, 변수 정의 | 새로운 방향 제안 |
| **FOCUSED** | 집중 실행 중 | 코드 구현, 실험 실행, 디버깅 | 방향 전환, 새 아이디어 |
| **WRITING** | 문서화 중 | 논문 작성, 시각화 | 새 실험 실행, 코드 대규모 수정 |

---

## 5. Artifact 통신 규약

두 모델은 API 직접 통신 없이 **파일시스템 artifact로 비동기 소통**합니다.

### 네이밍 컨벤션
```
*-draft.md    → Lead 모델이 작성한 초안
*-review.md   → Support 모델이 작성한 검증/피드백
*-final.md    → 피드백 반영 후 최종본
```

### Handoff 프로토콜
1. Lead 모델이 `*-draft.md`를 작성하고 연구자에게 알림
2. 연구자가 Support 모델에게 review를 요청
3. Support 모델이 `*-review.md`를 작성 (원본 수정 금지)
4. 연구자가 Lead 모델에게 review 반영을 요청
5. Lead 모델이 `*-final.md`를 생성

---

## 6. .research/ 디렉토리 규칙

| 파일/폴더 | 용도 | 읽기 | 쓰기 |
|-----------|------|------|------|
| `context.md` | 현재 연구 맥락, 진행 상황 | 양쪽 (세션 시작 시 필수) | 양쪽 |
| `wisdom.md` | 누적 인사이트, 교훈 | 양쪽 | 양쪽 (추가만, 삭제 금지) |
| `decisions.md` | 핵심 설계/방법론 결정 기록 | 양쪽 | 양쪽 (추가만) |
| `scope-mode.txt` | 현재 Scope Mode | 양쪽 | 연구자만 (AI 임의 변경 금지) |
| `pipeline-status.md` | 실험 파이프라인 상태 | 양쪽 | 양쪽 |
| `plans/` | 가설, 실험 설계서 | 양쪽 | 해당 단계 Lead |
| `feedback/` | 교차 리뷰, 검증 결과 | 양쪽 | 해당 단계 담당 모델 |
| `retros/` | 회고 기록 | 양쪽 | Claude (/reflect) |
| `logs/` | 실험 로그 요약 | 양쪽 | 실행 담당 모델 |

---

## 7. FROZEN 디렉토리 (수정 금지)

다음 디렉토리의 파일은 **절대 수정하지 마세요**:
- `profiling/results/` — 프로파일링 원본 결과
- `simulation/results/` — 시뮬레이션 원본 결과

이 디렉토리들은 실험의 재현성을 보장하기 위해 보호됩니다.
분석은 원본을 복사하거나 읽기 전용으로 수행하세요.
Claude Code에서는 hook(`check-freeze.sh`)이 자동으로 편집을 차단합니다.

---

## 8. 안전 원칙

### Human-in-the-loop
- 가설 선택, 실험 방향, 파라미터 확정은 **반드시 연구자의 확인**을 받으세요.
- AI가 독단적으로 연구 방향을 결정하지 마세요.

### Atomic Decision
- 실험 파라미터 결정 시 **한 번에 하나씩** 확인하세요.
- 여러 결정을 한꺼번에 묶지 마세요.

### 3-Strike Rule (디버깅 시)
- `/diagnose`에서 가설 3개를 순차 검증합니다.
- 3번 모두 실패하면 연구자에게 에스컬레이션합니다.
- AI 디버깅 무한 루프를 방지합니다.

---

## 9. 자연어 요청 시 동일 원칙 적용

명시적으로 `/brainstorm`, `/validate` 등 스킬을 호출하지 않더라도,
다음 키워드가 포함된 요청은 해당 스킬의 원칙(Hard Gate, Lead/Support, 출력 형식)을 따르세요:

| 키워드 | 적용 스킬 원칙 |
|--------|--------------|
| "브레인스토밍", "아이디어", "가설" | `/brainstorm` |
| "실험 설계", "파라미터", "변수 통제" | `/experiment-design` |
| "검증", "validate", "결과 확인" | `/validate` |
| "분석", "analyze", "패턴", "트렌드" | `/analyze` |
| "디버깅", "에러", "실패 원인" | `/diagnose` |
| "논문", "보고서", "문서화" | `/document` |
| "회고", "되돌아보기", "배운 점" | `/reflect` |
