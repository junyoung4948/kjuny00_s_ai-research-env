# AI Research Environment — 종합 가이드

> **대상**: 이 하네스를 사용하는 연구자
> **버전**: v2 (OmO + gstack 패턴 적용)

---

## Part 1: 아키텍처

### 1. 전체 구조

```
프로젝트/
├── AGENTS.md              ← [공유] 양쪽 자동 로딩 (12개 섹션)
├── CLAUDE.md              ← [Claude 전용] 역할, 안전 규칙, 스킬 참조
├── GEMINI.md              ← [Gemini 전용] 역할, 규칙 참조
│
├── .claude/               ← [Claude 전용]
│   ├── settings.json      ← Hook 등록 + 기본 권한
│   ├── hooks/
│   │   ├── check-freeze.sh   ← Edit/Write 시 FROZEN 디렉토리 보호
│   │   └── check-careful.sh  ← Bash 시 위험 명령 감지
│   └── skills/            ← 7개 스킬 (Hard Gate 적용)
│       ├── brainstorm/SKILL.md
│       ├── experiment-design/SKILL.md
│       ├── validate/SKILL.md
│       ├── analyze/SKILL.md
│       ├── diagnose/SKILL.md
│       ├── document/SKILL.md
│       └── reflect/SKILL.md
│
├── .agents/               ← [Gemini 전용]
│   ├── skills/            ← 7개 스킬 (.claude/skills/에서 미러링, 동일 내용)
│   ├── rules/             ← 상시 자동 로딩
│   │   ├── safety.md         ← FROZEN, 3-Strike, Atomic Decision 등
│   │   ├── anti-slop.md      ← Anti-Slop + Anti-Sycophancy + Completion Status
│   │   └── research-roles.md ← Lead/Support 행동 규칙
│   └── workflows/
│       └── research-cycle.md ← 4단계 연구 사이클
│
├── .research/             ← [공유] 양쪽 읽기/쓰기
│   ├── context.md         ← 연구 맥락 (세션 시작 시 필독)
│   ├── wisdom.md          ← 누적 인사이트 (append-only)
│   ├── decisions.md       ← 핵심 설계/방법론 결정
│   ├── scope-mode.txt     ← 현재 Scope Mode (연구자만 수정)
│   ├── pipeline-status.md ← 실험 파이프라인 상태
│   ├── plans/             ← 가설, 실험 계획 문서
│   ├── feedback/          ← 리뷰, 검증 결과
│   ├── retros/            ← 회고 기록
│   └── logs/              ← 실험 로그 요약
│
├── profiling/
│   ├── scripts/           ← 프로파일링 스크립트
│   └── results/           ← ⛔ FROZEN (수정 불가)
├── simulation/
│   ├── configs/           ← 시뮬레이션 설정
│   ├── scripts/           ← 시뮬레이션 스크립트
│   └── results/           ← ⛔ FROZEN (수정 불가)
└── docs/
    └── sections/          ← 논문/보고서 섹션
```

### 2. 3-tier 공유 모델

이 환경에서는 Claude Code와 Gemini(Antigravity)가 **같은 프로젝트**에서 작업하되, 각자의 설정 파일은 분리됨.

| 계층 | 파일 | 읽는 모델 | 역할 |
|------|------|-----------|------|
| **공유** | `AGENTS.md` | 양쪽 | 범용 규칙 12개 섹션 (역할, 안전, Anti-Slop, Anti-Sycophancy 등) |
| **공유** | `.research/*` | 양쪽 | 연구 상태 파일 (context, wisdom, decisions, scope-mode 등) |
| **공유 (내용)** | `skills/*/SKILL.md` | 양쪽 | 동일한 스킬 내용 (디렉토리만 `.claude/skills/` vs `.agents/skills/`) |
| **Claude 전용** | `.claude/*` | Claude만 | settings.json (hooks, 권한), allowed-tools (Hard Gate) |
| **Claude 전용** | `CLAUDE.md` | Claude만 | Claude 역할 지시, 스킬 가이드 |
| **Gemini 전용** | `.agents/rules/*` | Gemini만 | 상시 규칙 (safety, anti-slop, research-roles) |
| **Gemini 전용** | `.agents/workflows/*` | Gemini만 | `/` 커맨드 (research-cycle) |
| **Gemini 전용** | `GEMINI.md` | Gemini만 | Gemini 역할 지시 |

**핵심**: `.claude/`는 `.aiexclude`로 Gemini에게 숨겨짐. `.agents/`는 Claude에게도 보이지만 Claude용이 아님.

### 3. 설계 출처

이 환경은 두 개의 오픈소스 프로젝트에서 패턴을 가져와 연구 맥락에 맞게 적용함.

| 패턴 | 출처 | 우리 환경에서의 구현 |
|------|------|---------------------|
| Anti-Slop (6-point self-check) | OmO (Metis 감지) | AGENTS.md §10 + 각 SKILL.md `Slop Check` |
| Must NOT (스킬별 금지 사항) | OmO (역할별 제한) | 각 SKILL.md `Must NOT` 섹션 |
| Evidence Required (증거 의무) | OmO (검증 문화) | AGENTS.md §8 + 각 SKILL.md `Evidence Required` |
| Anti-Sycophancy (솔직한 피드백) | gstack (office-hours) | AGENTS.md §11 |
| Completion Status Protocol | gstack (investigate/ship) | AGENTS.md §12 + 각 SKILL.md `Completion Status` |
| Confusion Score (자기 조절) | gstack (qa WTF-Likelihood) | AGENTS.md §8 + diagnose SKILL.md |
| Iron Law (근본 원인 없이 수정 금지) | gstack (investigate) | AGENTS.md §8 + diagnose SKILL.md |
| Escalation Format (구조화된 에스컬레이션) | gstack (completion status) | AGENTS.md §8 |
| Decision Classification (Mechanical vs Taste) | gstack (autoplan) | AGENTS.md §8 |
| PreToolUse Hooks (물리적 차단) | gstack (freeze/careful) | `.claude/hooks/check-freeze.sh`, `check-careful.sh` |
| 3-Strike Rule (3회 실패 → 중단) | gstack (investigate) | AGENTS.md §8 (시스템 전체 확장) |
| Atomic Decision (하나씩 확인) | 자체 설계 | AGENTS.md §8 |
| Scope Mode (4단계 모드) | 자체 설계 | AGENTS.md §4 + `.research/scope-mode.txt` |
| Lead/Support 핸드오프 | 자체 설계 | AGENTS.md §2, §5 |

### 4. Hard Gate vs Soft Rules

이 환경은 두 가지 수준의 강제력을 사용함.

**Hard Gate (물리적으로 불가능하게 만듦)**:
- **Hooks** (`check-freeze.sh`): Claude가 FROZEN 디렉토리의 파일을 수정하려고 하면, hook이 도구 호출을 가로채서 `deny` 반환 → Claude가 아무리 원해도 수정 불가
- **allowed-tools** (SKILL.md frontmatter): `/brainstorm` 스킬에서 `Edit`, `Write`, `Bash` 도구가 목록에 없으면 → Claude가 해당 도구를 사용할 수 없음
- **permissions** (settings.json): 기본 허용 도구를 `Read`, `Glob`, `Grep`, `WebSearch`로 제한

**Soft Rules (프롬프트로 지시 — 위반 가능하지만 강하게 유도)**:
- **AGENTS.md 규칙**: Anti-Slop, Anti-Sycophancy, 3-Strike Rule 등 — 모델이 읽고 따르도록 지시
- **`.agents/rules/*`**: Gemini 전용 상시 규칙 — Gemini는 hooks가 없으므로 soft rules가 유일한 안전장치
- **Must NOT / Slop Check / Evidence Required**: 각 SKILL.md에 명시된 행동 제약

**Claude vs Gemini 차이**:
- Claude: Hard Gate (hooks, allowed-tools) + Soft Rules (AGENTS.md, SKILL.md)
- Gemini: **Soft Rules만** (`.agents/rules/*`, AGENTS.md) — Antigravity는 hook 메커니즘을 지원하지 않음

---

## Part 2: 실용 가이드

### 5. 프로젝트 초기화

**사용법**:
```bash
cd /your/research/project
bash /path/to/ai-research-env/init-project.sh .
```

**내부 동작** (8단계):

| 단계 | 작업 | 동작 방식 |
|------|------|-----------|
| 1 | 디렉토리 생성 | `.research/`, `.claude/`, `.agents/`, `profiling/`, `simulation/`, `docs/` 등 28개 디렉토리 |
| 2 | 코어 파일 복사 | `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` → **이미 존재하면 건너뜀** (`copy_if_not_exists`) |
| 3 | `.gitignore`, `.aiexclude` | `.aiexclude`는 `.claude/`를 Gemini에게 숨김 |
| 4 | Claude 설정 + hooks | `settings.json`, `check-freeze.sh`, `check-careful.sh` → **항상 최신 버전으로 덮어씀** |
| 5 | Claude 스킬 7개 | `.claude/skills/*/SKILL.md` → 이미 존재하면 건너뜀 |
| 6 | Antigravity 스킬 미러링 | `.claude/skills/`의 내용을 `.agents/skills/`로 복사 (동일 소스) |
| 7 | Antigravity rules + workflows | `safety.md`, `anti-slop.md`, `research-roles.md`, `research-cycle.md` |
| 8 | `.research/` 초기 파일 | `context.md`, `wisdom.md`, `decisions.md`, `scope-mode.txt`, `pipeline-status.md` |

**설계 의도**: hooks(4단계)는 항상 최신화하고, 연구 콘텐츠(2, 5, 8단계)는 기존 파일을 보존하여 연구자의 수정 사항이 날아가지 않도록 함.

### 6. 7개 스킬 사용법

#### 스킬 요약표

| 스킬 | Lead | Claude 역할 | 입력 조건 | 결과물 |
|------|------|-------------|-----------|--------|
| `/brainstorm` | Gemini | Support (리뷰) | context.md, scope-mode.txt, wisdom.md | `hypothesis-{topic}-review.md` |
| `/experiment-design` | Claude | Lead (설계) | hypothesis-final.md | `experiment-{name}-draft.md` |
| `/validate` | Claude | Lead (검증) | experiment-final.md, 결과 파일 | `validation-{name}.md` |
| `/analyze` | Gemini | Support (수치 검증) | validation report, 결과 파일 | `analysis-{name}-review.md` |
| `/diagnose` | Claude | Lead (진단) | 실험 설계, 로그 파일 | `diagnosis-{name}.md` |
| `/document` | Gemini | Support (기술 리뷰) | 모든 final 파일 | `{section}-review.md` |
| `/reflect` | Claude | Lead (회고) | 최근 작업 아티팩트 | `retros/{date}.md` + wisdom.md 업데이트 |

#### `/brainstorm` — 가설 수립

**언제 사용**: 새로운 연구 아이디어가 필요할 때 (EXPLORATION 단계)

**사용 흐름**:
1. Gemini에게 `/brainstorm` → `hypothesis-{topic}-draft.md` 생성
2. 연구자가 Claude에게 리뷰 요청
3. Claude에게 `/brainstorm` → `hypothesis-{topic}-review.md` 생성

**내부 동작**:
- Claude에서 `/brainstorm` 입력 시 `.claude/skills/brainstorm/SKILL.md` 로딩
- `allowed-tools: [Read, Glob, Grep, WebSearch, AskUserQuestion]` → **코드 작성, 파일 수정, 명령 실행 불가** (Hard Gate)
- Claude는 Support 역할 → Gemini의 초안을 읽고 리뷰만 작성
- Gemini에서 `/brainstorm` 사용 시 `.agents/skills/brainstorm/SKILL.md` 로딩 (동일 내용, allowed-tools는 Antigravity가 무시)
- 완료 시 Completion Status 출력 필수 (DONE/BLOCKED/NEEDS_CONTEXT)

#### `/experiment-design` — 실험 설계

**언제 사용**: 가설이 확정된 후 실험을 구체화할 때 (REFINEMENT 단계)

**사용 흐름**:
1. Claude에게 `/experiment-design` → 파라미터를 **하나씩** 확인 (Atomic Decision)
2. 모든 파라미터 확정 후 `experiment-{name}-draft.md` 생성
3. Gemini 리뷰 → Claude 반영 → `experiment-{name}-final.md`

**내부 동작**:
- 7개 항목을 순차 확인: 종속변수 → 독립변수 → 통제변수 → 도구 → 파라미터 범위 → 베이스라인 → 성공 기준
- Hard Gate: 코드 작성 불가 (설계에만 집중)
- Effort Estimate 태그 포함 (Quick/Short/Medium/Large)
- 실험별 Must NOT 목록 생성

#### `/validate` — 결과 검증

**언제 사용**: 실험 결과가 나온 직후, 분석 전 (FOCUSED 단계)

**사용 흐름**:
1. Claude에게 `/validate` → 4단계 검증 수행
2. `validation-{name}.md` 생성 (PASS/CONDITIONAL/FAIL 판정)

**내부 동작**:
- Phase 1: Sanity Check (수치 범위, 단위, 누락 데이터)
- Phase 2: Consistency (내부 일관성, 베이스라인, 트렌드)
- Phase 3: Reproducibility (동일 설정 재현성)
- Phase 4: Verdict 테이블 작성
- `Bash` 허용되지만 **읽기 전용만** (파싱, 계산, 로그 조회)
- FROZEN 디렉토리 파일은 읽기만 가능 (hook이 수정 차단)

#### `/analyze` — 결과 분석

**언제 사용**: 검증 통과 후 패턴과 트렌드를 파악할 때 (FOCUSED 단계)

**사용 흐름**:
1. Gemini에게 `/analyze` → `analysis-{name}-draft.md` 생성
2. Claude에게 `/analyze` → 수치 정확성 검증 → `analysis-{name}-review.md`

**내부 동작**:
- Claude는 Support 역할: Gemini의 수치 인용이 원본 데이터와 일치하는지 검증
- Hard Gate: 코드 작성 불가 (분석 리뷰에만 집중)
- 모든 주장에 "X가 Y% 증가, A→B" 형식의 구체적 수치 필수

#### `/diagnose` — 실패 진단

**언제 사용**: 실험 실패 또는 예상치 못한 결과 발생 시 (FOCUSED 단계)

**사용 흐름**:
1. Claude에게 `/diagnose` → 최대 3개 가설 순차 검증
2. 성공 시 수정 적용, 3회 실패 시 에스컬레이션

**내부 동작**:
- **3-Strike Rule**: 가설1 → 실패 → 가설2 → 실패 → 가설3 → 실패 → STOP + Escalation Format 출력
- **Iron Law**: 근본 원인 파악 전 수정 금지. "동작한다"는 증거가 아님 — WHY를 설명해야 함
- **Scope Lock**: 진단 중 관련 없는 파일 수정 금지. 범위 밖 수정 필요 시 연구자에게 먼저 확인
- **Confusion Score**: 누적 혼란도 추적. 25% 초과 시 자동 중단. 10% 초과 시 보고서에 현재 점수 포함
- `Edit`, `Bash` 허용 (수정과 실행이 필요하므로)
- FROZEN 디렉토리는 여전히 수정 불가 (hook 보호)

#### `/document` — 논문/보고서 작성

**언제 사용**: 결과 분석이 완료된 후 (WRITING 단계)

**사용 흐름**:
1. Gemini에게 `/document` → `{section}-draft.md` 생성
2. Claude에게 `/document` → 기술 정확성 리뷰 → `{section}-review.md`

**내부 동작**:
- Claude는 Support 역할: **원본 초안 수정 절대 금지** (별도 리뷰 파일만 작성)
- 리뷰 항목: 기술 정확성 (수치 일치?), 논리 흐름 (주장-증거 연결?), 완전성 (빠진 결과?)
- `Edit`, `Write` 허용되지만 리뷰 파일 생성 용도로만

#### `/reflect` — 회고

**언제 사용**: 연구 사이클 완료 후 (모든 단계 후)

**사용 흐름**:
1. Claude에게 `/reflect` → `retros/{date}.md` 생성
2. `wisdom.md`, `context.md` 자동 업데이트
3. Scope Mode 변경 필요 여부 연구자와 논의

**내부 동작**:
- Phase 1: 최근 사이클 사실 수집 (어떤 가설, 어떤 결과, 예상과의 차이)
- Phase 2: 인사이트 추출 (성공/실패/놀라운 점/교훈/도구 팁)
- Phase 3: 회고 문서 작성
- Phase 4: wisdom.md에 인사이트 추가 (**기존 항목 삭제 금지**, append-only)
- wisdom.md의 3개 카테고리에 배치: Learnings / Pitfalls / Tool Tips

### 7. 연구 워크플로우

```
  ┌─────────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
  │ EXPLORATION │───→│ REFINEMENT   │───→│ FOCUSED  │───→│ WRITING  │
  │ (방향 탐색)  │    │ (실험 설계)   │    │ (실행)    │    │ (문서화)  │
  └─────────────┘    └──────────────┘    └──────────┘    └──────────┘
         ↑                                                      │
         └────────────── /reflect (회고 & 재탐색) ──────────────┘
```

| 단계 | scope-mode.txt | 주요 스킬 | 생성되는 파일 |
|------|---------------|-----------|-------------|
| **EXPLORATION** | `EXPLORATION` | `/brainstorm` | `hypothesis-{topic}-draft/review/final.md` |
| **REFINEMENT** | `REFINEMENT` | `/experiment-design` | `experiment-{name}-draft/review/final.md` |
| **FOCUSED** | `FOCUSED` | `/validate`, `/diagnose`, `/analyze` | `validation-*.md`, `diagnosis-*.md`, `analysis-*-draft/review/final.md` |
| **WRITING** | `WRITING` | `/document` | `docs/sections/{section}-draft/review/final.md` |
| **회고** | (변경 없음) | `/reflect` | `retros/{date}.md` |

**Scope Mode가 하는 일**: `.research/scope-mode.txt`에 현재 단계가 기록됨. 양쪽 모델이 작업 시작 전 이 파일을 읽고, 현재 단계에서 허용되지 않는 행동을 하지 않도록 자기 제어.

예시:
- `FOCUSED` 모드에서 Claude가 새로운 연구 방향을 제안하면 → AGENTS.md §4의 "Must Avoid: Direction changes, new ideas" 위반
- `EXPLORATION` 모드에서 Gemini가 코드를 작성하면 → "Must Avoid: Code writing, parameter decisions" 위반

**scope-mode.txt 변경**: 연구자만 가능. AI는 변경 불가 (`.research/` 디렉토리 규칙으로 강제).

### 8. 안전 메커니즘

#### 8-1. Hooks (물리적 차단) — Claude 전용

**check-freeze.sh** — Edit/Write 도구 호출 시 자동 실행

```
Claude가 Edit/Write 호출
  ↓
check-freeze.sh 실행 (settings.json의 PreToolUse 등록)
  ↓
tool_input에서 file_path 추출 (grep + python3 fallback)
  ↓
file_path가 profiling/results/* 또는 simulation/results/*인가?
  ├── YES → permissionDecision: "deny" + 메시지 → ⛔ 도구 호출 차단
  └── NO  → {} → ✅ 허용
```

**check-careful.sh** — Bash 도구 호출 시 자동 실행

```
Claude가 Bash 호출
  ↓
check-careful.sh 실행
  ↓
tool_input에서 command 추출
  ↓
Safe 예외 패턴 확인 (rm -rf __pycache__, node_modules 등)
  ├── 매칭 → {} → ✅ 허용
  └── 미매칭 → 위험 패턴 확인
       ├── rm -rf, git reset --hard, DROP TABLE 등 → permissionDecision: "ask" + 경고 메시지
       └── 미매칭 → {} → ✅ 허용
```

**YOLO mode 참고**: `--dangerously-skip-permissions` 사용 시 `"deny"`는 여전히 차단되지만, `"ask"`는 자동 승인됨. 즉 FROZEN 디렉토리 보호는 유지되지만 위험 명령 경고는 우회됨.

#### 8-2. 3-Strike Rule — 양쪽 모델

```
작업 시도 → 실패
  ↓
Strike 1: 재시도 → 실패
  ↓
Strike 2: 재시도 → 실패
  ↓
Strike 3: STOP
  ↓
Escalation Format 출력:
  STATUS: BLOCKED
  REASON: [이유]
  ATTEMPTED: [시도한 것 3가지]
  RECOMMENDATION: [연구자가 해야 할 것]
  ↓
4번째 시도 금지 — 연구자 입력 대기
```

적용 범위: `/diagnose`(가설), 스크립트 구현(빌드 에러), `/analyze`(이상치 해석), **모든 작업**

#### 8-3. Confusion Score — 양쪽 모델

3-Strike는 **연속** 실패만 감지. Confusion Score는 **누적** 혼란도를 추적하여 점진적 drift를 잡음.

```
시작: 0%
  ├── 실패한 수정/가설: +15%
  ├── 3개 이상 파일 수정: +10%
  ├── 5번째 이후 파라미터 조정: +2%씩
  ├── 초기 범위 밖 파일 수정: +20%
  └── 이전 변경 되돌리기: +15%

25% 초과 → STOP → 점수 분석과 함께 에스컬레이션
10회 반복 → 무조건 STOP
```

주로 `/diagnose`와 스크립트 구현에서 활성화.

#### 8-4. Anti-Slop — 양쪽 모델

모든 출력 생성 전 6가지 자기 점검:

| 점검 | 질문 |
|------|------|
| Scope Inflation | 요청하지 않은 작업을 제안하고 있는가? |
| Premature Framework | 일회성 작업에 재사용 인프라를 만들고 있는가? |
| Over-analysis | 분석 복잡도가 데이터 양에 비례하는가? |
| Documentation Bloat | 산출물 길이가 발견 규모에 비례하는가? |
| Hallucinated Expertise | 증거 파일/로그/레퍼런스를 가리킬 수 있는가? |
| Speculative Conclusion | 데이터가 보여주는 것 vs 추론을 구분했는가? |

#### 8-5. Anti-Sycophancy — 양쪽 모델

빈말 금지 + 솔직한 평가 강제:

| 금지 표현 | 대체 |
|-----------|------|
| "That's an interesting hypothesis" | "This hypothesis is strong/weak because [이유]" |
| "There are several approaches" | "I recommend X because [이유]. 이 입장을 바꿀 증거: [Y]" |
| "You might want to consider..." | "This is flawed because..." 또는 "This works because..." |

필수 행동: (1) 모든 평가에 입장 표명, (2) 주장의 가장 강한 버전을 반박, (3) Support 역할에서 비판이 가치.

#### 8-6. Completion Status — 양쪽 모델

모든 스킬 출력의 마지막에 필수:

| 상태 | 의미 |
|------|------|
| `DONE` | 모든 단계 완료, 증거 포함 |
| `DONE_WITH_CONCERNS` | 완료했지만 연구자가 알아야 할 이슈 있음 |
| `BLOCKED` | 진행 불가 → Escalation Format 사용 |
| `NEEDS_CONTEXT` | 정보 부족 → 필요한 정보 명시 |

#### 8-7. Atomic Decision — 양쪽 모델

선택지가 2개 이상이면 **한 번에 하나씩** 확인:
```
"시뮬레이터로 gem5를 사용할까요?" → 확인
"캐시 크기 범위: 32KB–2MB?" → 확인
"워크로드: SPEC CPU2017?" → 확인
```

단, **Mechanical 결정**(명확하게 정답이 하나인 경우)은 자동 결정 허용:
- 기존 프로젝트 패턴 따르기
- 동등한 선택지 중 더 단순한 것
- 파일명, 네이밍 컨벤션

**Taste 결정**(합리적으로 의견이 갈리는 경우)만 연구자에게 질문:
- 연구 방향, 파라미터 값, 방법론 선택

### 9. Lead/Support 핸드오프

**전체 흐름**:
```
Lead가 *-draft.md 작성
  ↓
연구자가 Support에게 리뷰 요청
  ↓
Support가 *-review.md 작성 (원본 수정 절대 불가)
  ↓
연구자가 Lead에게 리뷰 반영 요청
  ↓
Lead가 *-final.md 생성
  ↓
연구자가 최종 확인
```

**구체적 시나리오** (`/brainstorm`):
```
[Gemini IDE]  /brainstorm 입력
              → .agents/skills/brainstorm/SKILL.md 로딩
              → Gemini가 Lead로서 .research/plans/hypothesis-cache-opt-draft.md 작성
              → "초안 완성했습니다. Claude에게 리뷰를 요청해주세요."

[연구자]      Claude Code에서 "hypothesis-cache-opt-draft.md를 리뷰해줘"

[Claude Code]  /brainstorm 스킬 원칙 적용 (키워드 "리뷰" + "hypothesis" 감지)
              → .claude/skills/brainstorm/SKILL.md 로딩
              → Hard Gate: Read, Glob, Grep, WebSearch만 사용 가능
              → Gemini의 초안 읽기 → 논리 일관성, 실현 가능성, 참신성, wisdom 충돌 검증
              → .research/plans/hypothesis-cache-opt-review.md 작성
              → STATUS: DONE

[연구자]      Gemini에게 "리뷰 반영해줘"

[Gemini IDE]  hypothesis-cache-opt-review.md 읽기 → 반영
              → .research/plans/hypothesis-cache-opt-final.md 생성
```

**Review 파일 구조** (모든 `*-review.md`):
```markdown
## TASK
검토 대상 (파일 경로, 범위)

## KEY FINDINGS
핵심 발견 3-5개

## MUST FIX
반드시 수정할 오류

## SUGGESTIONS
개선 제안 (선택, 우선순위 표시)

## VERIFIED
검증 완료된 부분 (Lead가 건드리지 않을 것)

## CONTEXT
검토 시 참조한 파일, 배경 지식
```

### 10. .research/ 상태 파일

| 파일 | 역할 | 읽기 | 쓰기 | 규칙 |
|------|------|------|------|------|
| `context.md` | 현재 연구 맥락, 진행 상황 | 양쪽 (세션 시작 시 필수) | 양쪽 | 연구 진행에 따라 지속 업데이트 |
| `wisdom.md` | 누적 인사이트 | 양쪽 | 양쪽 | **삭제 금지** (append-only). 3개 카테고리: Learnings, Pitfalls, Tool Tips |
| `decisions.md` | 핵심 설계/방법론 결정 | 양쪽 | 양쪽 | **삭제 금지** (append-only). 날짜, 결정, 근거, 대안, 확인 |
| `scope-mode.txt` | 현재 Scope Mode | 양쪽 | **연구자만** | AI가 절대 수정 불가 |
| `pipeline-status.md` | 실험 파이프라인 상태 | 양쪽 | 양쪽 | 실험 시작/완료 시 업데이트 |
| `plans/` | 가설, 실험 계획 | 양쪽 | 해당 단계 Lead | draft → review → final |
| `feedback/` | 검증, 분석, 진단 결과 | 양쪽 | 해당 스킬 담당 모델 | validation-*.md, analysis-*.md 등 |
| `retros/` | 회고 기록 | 양쪽 | Claude (`/reflect`) | `{date}.md` 형식 |
| `logs/` | 실험 로그 요약 | 양쪽 | 실행 담당 모델 | 실험별 로그 |

---

## Part 3: 레퍼런스

### 11. 파일 맵

#### 템플릿 (`ai-research-env/templates/`)

| 경로 | 설명 |
|------|------|
| `AGENTS.md` | 공유 규칙 12개 섹션 |
| `CLAUDE.md` | Claude 역할 + 스킬 가이드 + 안전 규칙 |
| `GEMINI.md` | Gemini 역할 + 규칙 참조 + 아티팩트 규약 |
| `.claude/settings.json` | hooks 등록 (freeze + careful) + 기본 권한 (Read, Glob, Grep, WebSearch) |
| `.claude/hooks/check-freeze.sh` | FROZEN 디렉토리 보호 (deny) |
| `.claude/hooks/check-careful.sh` | 위험 명령 감지 (ask) |
| `.claude/skills/brainstorm/SKILL.md` | 가설 수립 — Support(Claude), Hard Gate: 읽기 전용 |
| `.claude/skills/experiment-design/SKILL.md` | 실험 설계 — Lead(Claude), Hard Gate: 읽기 전용 |
| `.claude/skills/validate/SKILL.md` | 결과 검증 — Lead(Claude), Bash 읽기 전용 |
| `.claude/skills/analyze/SKILL.md` | 결과 분석 — Support(Claude), Hard Gate: 읽기 전용 |
| `.claude/skills/diagnose/SKILL.md` | 실패 진단 — Lead(Claude), 3-Strike + Iron Law + Scope Lock + Confusion Score |
| `.claude/skills/document/SKILL.md` | 논문 작성 — Support(Claude), 원본 수정 금지 |
| `.claude/skills/reflect/SKILL.md` | 회고 — Lead(Claude), wisdom.md 업데이트 |
| `.agents/skills/*/SKILL.md` | 위 7개와 동일 내용 (Antigravity 미러링) |
| `.agents/rules/safety.md` | Gemini 상시 안전 규칙 (FROZEN, 3-Strike, Atomic Decision, Confusion Score 등) |
| `.agents/rules/anti-slop.md` | Gemini 상시 Anti-Slop + Anti-Sycophancy + Completion Status |
| `.agents/rules/research-roles.md` | Gemini Lead/Support 행동 규칙 |
| `.agents/workflows/research-cycle.md` | 4단계 연구 사이클 워크플로우 |
| `.research/context.md` | 연구 맥락 (세션 시작 시 필독) |
| `.research/wisdom.md` | 누적 인사이트 (3-카테고리, append-only) |
| `.research/decisions.md` | 핵심 결정 기록 (append-only) |
| `.research/scope-mode.txt` | 현재 Scope Mode (기본: EXPLORATION) |
| `.research/pipeline-status.md` | 실험 파이프라인 상태 |

#### 인프라 (`ai-research-env/`)

| 경로 | 설명 |
|------|------|
| `init-project.sh` | 8단계 프로젝트 초기화 스크립트 |
| `setup.sh` | 글로벌 설정 설치 (선택사항) |
| `global/claude/CLAUDE.md` | 글로벌 Claude 기본 규칙 |
| `global/claude/settings.json` | 글로벌 기본 권한 |
| `global/gemini/AGENTS.md` | 글로벌 Gemini 기본 규칙 |
| `docs/GUIDE.md` | 이 문서 |
| `README.md` | 프로젝트 소개 (한국어) |

### 12. 다음 세션 TODO

추가 harness engineering 후보:

- [ ] AGENTS.md §12에 DONE/BLOCKED 출력 형식의 구체적 마크다운 템플릿 추가
- [ ] 스킬별 Completion Status를 skill-specific하게 커스터마이징 (현재는 모두 동일한 한 줄 참조)
- [ ] Gemini 스킬에서 Lead 역할의 상세 행동 정의 (현재 SKILL.md는 Claude Support 관점 중심)
- [ ] `.research/handoff/` 디렉토리의 분석 문서 정리 (gstack, OmO 분석은 개발용이므로 프로덕션에서 제거 검토)
- [ ] 실제 연구 프로젝트에서 init-project.sh 실행 후 end-to-end 테스트
