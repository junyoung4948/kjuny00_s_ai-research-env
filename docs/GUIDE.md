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
│   │   ├── check-careful.sh  ← Bash 시 위험 명령 감지
│   │   └── pre-read-guard.sh ← 중복 파일 읽기 방지 Hook (경고)
│   └── skills/            ← brainstorm-arch, build-motivation, peer-review
│
├── .agents/               ← [Gemini 전용]
│   ├── skills/            ← brainstorm-arch, build-motivation, peer-review
│   ├── rules/             ← 상시 자동 로딩
│   │   ├── safety.md                    ← FROZEN, 3-Strike, Atomic Decision 등
│   │   ├── anti-slop.md                 ← Anti-Slop + Anti-Sycophancy + Completion Status
│   │   ├── research-roles.md            ← Lead/Support 행동 규칙
│   │   └── rationalization-prevention.md ← LLM 규칙 우회 패턴 및 반박 테이블
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
| **공유** | `AGENTS.md` | 양쪽 (지시어 방식) | 범용 규칙 12개 섹션 (역할, 안전, Anti-Slop, Anti-Sycophancy 등) |
| **공유** | `.research/*` | 양쪽 | 연구 상태 파일 (context, wisdom, decisions, scope-mode 등) |
| **Claude 전용** | `.claude/skills/*/SKILL.md` | Claude만 | (새로운 파이프라인에 맞춰 추가될 예정) |
| **Gemini 전용** | `.agents/skills/*/SKILL.md` | Gemini만 | (새로운 파이프라인에 맞춰 추가될 예정) |
| **Claude 전용** | `.claude/*` | Claude만 | settings.json (hooks, 권한), allowed-tools (Hard Gate) |
| **Claude 전용** | `CLAUDE.md` | Claude만 | Claude 역할 지시, Required Reading by Phase 지시어 |
| **Gemini 전용** | `GEMINI.md` | Gemini만 | Gemini 역할 지시, Required Reading by Phase 지시어 |

**핵심**: `.claude/`는 `.aiexclude`로 Gemini에게 숨겨짐. `.agents/`는 Claude에게도 보이지만 Claude용이 아님.

**AGENTS.md 로딩 방식**: `@` include나 자동 주입이 아니라 **지시어 기반 lazy loading**. `CLAUDE.md`/`GEMINI.md`에 "X할 때 AGENTS.md §Y를 읽어라" 형식의 지시어가 있어, 모델이 해당 phase 진입 시 스스로 해당 섹션을 읽도록 유도. (예: artifact 생성 전 → §10 Anti-Slop, skill 종료 전 → §8 Verification Gate + §12 Completion Status)

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
| Rationalization Prevention (규칙 우회 차단) | superpowers (TDD + verification-before-completion) | AGENTS.md §10.5 |
| CSO Description Convention (skill 라우팅 최적화) | superpowers (writing-skills) | 모든 SKILL.md `description` 필드 "Use when..." 형식 |
| Forced-Invocation Directive (스킬 invoke 강제) | superpowers (using-superpowers) | AGENTS.md §9 |
| Verification Gate Function (완료 주장 절차화) | superpowers (verification-before-completion) | AGENTS.md §8 |
| Required Reading by Phase (AGENTS.md lazy loading) | OmO (directory-agents-injector, 수동 구현) | `CLAUDE.md`/`GEMINI.md`의 "Required Reading by Phase" 섹션 — phase별 트리거로 AGENTS.md 해당 섹션을 on-demand 읽기 |
| Integration Test Infrastructure (hook 테스트) | superpowers (testing.md) | `ai-research-env/tests/` |

### 4. Hard Gate vs Soft Rules

이 환경은 두 가지 수준의 강제력을 사용함.

**Hard Gate (물리적으로 불가능하게 만듦)**:
- **Hooks** (`check-freeze.sh`): Claude가 FROZEN 디렉토리의 파일을 수정하려고 하면, hook이 도구 호출을 가로채서 `deny` 반환 → Claude가 아무리 원해도 수정 불가
- **allowed-tools** (SKILL.md frontmatter): `/brainstorm` 스킬에서 `Edit`, `Write`, `Bash` 도구가 목록에 없으면 → Claude가 해당 도구를 사용할 수 없음
- **permissions** (settings.json): 기본 허용 도구를 `Read`, `Glob`, `Grep`, `WebSearch`로 제한

**Soft Rules (프롬프트로 지시 — 위반 가능하지만 강하게 유도)**:
- **AGENTS.md 규칙**: Anti-Slop, Anti-Sycophancy, 3-Strike Rule 등 — 모델이 읽고 따르도록 지시
- **Must NOT / Slop Check / Evidence Required**: 각 SKILL.md에 명시된 행동 제약

**Claude vs Gemini 차이**:
- Claude: Hard Gate (hooks, allowed-tools) + Soft Rules (AGENTS.md, SKILL.md)
- Gemini: **Soft Rules만** (AGENTS.md) — Antigravity는 hook 메커니즘을 지원하지 않음

### 5. 토큰 최적화 시스템

**대폭 토큰 절감**을 위한 사전 인덱싱 및 중복 방지 시스템입니다. [OpenWolf](https://github.com/nikhilweee/OpenWolf)와 [Aspens](https://github.com/acenolaza/aspens) 오픈소스 프로젝트의 패턴을 참고하여 구현되었습니다.

> **스킬 트리거**: Claude Code와 Antigravity는 이미 각 SKILL.md의 YAML frontmatter를 자동으로 읽어 트리거 여부를 판단합니다. 별도의 스킬 인덱스 없이도 에이전트 시스템이 효율적으로 작동합니다.

#### 5.1 핵심 컴포넌트

| 컴포넌트 | 파일 위치 | 기능 | 절감 효과 |
|----------|-----------|------|----------|
| **Project Map 생성기** | `scripts/generate-project-map.sh` | 파일 구조 + 토큰 추정 인덱싱 | 디렉토리 탐색 반복 제거 |
| **Pre-Read Guard Hook** | `.claude/hooks/pre-read-guard.sh` | 중복 읽기 감지 + 경고 | 세션 내 재독 방지 |

#### 5.2 자동 생성 파일

**`.research/project-map.md`** — 프로젝트의 모든 파일을 디렉토리별로 정리하여 설명과 토큰 추정치 포함:
```markdown
# Project Map
> Generated: 2026-03-31T21:00:00+09:00 | Files: 86

## .
- `AGENTS.md` — Agent configuration (~4738 tok)
- `CLAUDE.md` — Claude Code instructions (~520 tok)

## .claude/skills/analyze/
- `SKILL.md` — Result analysis — identify patterns and trends (~1200 tok)
```

#### 5.3 동작 원리

**1단계: 사전 인덱싱** (`init-project.sh` 11.5단계에서 자동 실행)
- `generate-project-map.sh`: 모든 파일의 설명 추출 + 토큰 추정

**2단계: 효율적 참조** (에이전트가 필요 시 활용)
- Project map을 통해 파일 정보 빠르게 조회 가능 (grep 활용)
- 에이전트들이 반복적인 디렉토리 탐색 대신 인덱스 참조
- **주의**: project-map.md 자체가 큰 경우 직접 읽기보다는 grep으로 필요한 부분만 조회

**3단계: 중복 방지** (Pre-Read Guard Hook 활성화)
- 첫 읽기: `📋 project-map: filename — description (~tokens tok)`
- 중복 읽기: `⚡ pre-read: filename already read this session (~tokens tok). Use existing knowledge instead.`

#### 5.4 기술적 구현 세부사항

**설명 추출 알고리즘**:
```bash
# SKILL.md: YAML frontmatter description 필드
# .sh: shebang 다음 첫 # 코멘트
# .md: 첫 H1/H2 heading
# .py: docstring 또는 첫 # 코멘트
# known files: 사전 정의된 설명 (settings.json → "Claude settings")
```

**토큰 추정 공식**:
- `.md` 파일: `char_count / 4.0`
- 코드 파일: `char_count / 3.5`
- 혼합 파일: `char_count / 3.75`

**Hook JSON 파싱**:
```bash
# PreToolUse에서 전달되는 JSON에서 file_path 추출
file_path=$(echo "$json" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
```

---

## Part 2: 실용 가이드

### 6. 프로젝트 초기화

**사용법**:
```bash
cd /your/research/project
bash /path/to/ai-research-env/init-project.sh .
```

**내부 동작** (11단계):

| 단계 | 작업 | 동작 방식 |
|------|------|-----------|
| 1 | 디렉토리 생성 | `.research/`, `.claude/`, `.agents/`, `profiling/`, `simulation/`, `docs/`, `scripts/` 등 |
| 2 | 코어 파일 복사 | `AGENTS.md`, `CLAUDE.md`, `GEMINI.md` → **이미 존재하면 건너뜀** |
| 3 | `.gitignore`, `.aiexclude` | `.aiexclude`는 `.claude/`를 Gemini에게 숨김 |
| 4 | Claude 설정 + hooks | `settings.json` (**jq로 hooks만 병합**), hooks는 **항상 최신 버전** |
| 5 | Claude 스킬 | `.claude/skills/*/SKILL.md` 복사 (프로젝트별) |
| 6 | Antigravity 스킬 | `.agents/skills/*/SKILL.md` 복사 (프로젝트별) |
| 6.5 | Shared Skills | **Global 설치 권장** — `setup.sh` 실행 시 `~/.claude/skills/`, `~/.agents/skills/`에 설치 |
| 7 | `.agents/` rules + workflows | Antigravity 전용 규칙 및 워크플로우 파일 |
| 8 | Integration tests | `tests/test-check-freeze.sh`, `tests/test-check-careful.sh` |
| 9 | Scripts | `generate-project-map.sh`, `sync-models.py` 등 |
| 10 | Handoff protocol | `.research/handoff/README.md` |
| 11 | `.research/` 초기 파일 | `context.md`, `wisdom.md`, `decisions.md`, `scope-mode.txt`, `pipeline-status.md` — **절대 덮어쓰지 않음** |
| 11.5 | Project map 생성 | `generate-project-map.sh` 자동 실행 → `.research/project-map.md` |
| 12 | Dynamic Model Selection | 초기 sync + cron 등록 + 셸 프로파일 설정 |

**설계 의도**: 
- hooks/scripts(4, 8, 9단계)는 항상 최신화
- 연구 콘텐츠(2, 11단계)는 기존 파일 보존
- **settings.json**: jq로 hooks만 템플릿에서 병합, MCP/permissions는 유지
- **Shared Skills**: global 설치 권장 (프로젝트별 복사 제거)

### 7. 연구 사이클 스킬 사용법 (현재 재설계 중)

> **알림**: 기존의 10개 연구 스킬(`brainstorm`, `experiment-design`, `validate`, `analyze`, `diagnose`, `document`, `reflect`, `cross-review`, `pickup` 등)은 새로운 연구 파이프라인 구축을 위해 모두 제거되었습니다. 
> 조만간 고도화된 스킬셋과 워크플로우로 개편될 예정입니다.

#### `/sync-docs` — 문서 동기화

> **연구 사이클 스킬이 아닌 환경 유지보수 스킬입니다.** 스킬 추가, hook 수정, 스크립트 변경 후 프로젝트 문서가 실제 상태와 어긋날 때 사용합니다.

**언제 사용**:
- 새 스킬(`SKILL.md`)을 추가하거나 기존 스킬을 수정한 후
- hook 스크립트(`check-freeze.sh`, `check-careful.sh`)의 패턴을 변경한 후
- 디렉토리 구조나 스크립트 파일을 추가/변경한 후
- README, GUIDE.md 등의 문서가 실제와 달라진 것을 발견했을 때

**사용 흐름**:
1. Claude에게 `/sync-docs` 입력
2. 프로젝트 유형 자동 감지 → 감사 대상 결정
3. `git diff`로 최근 변경 파일 식별 → 관련 문서 집중 감사
4. 사실적 변경(스킬 수, 파일 경로 등)은 자동 적용
5. 서술적 변경(소개문, 아키텍처 설명 등)은 연구자에게 확인 후 적용
6. 파일별 `[Updated/Current/Skipped]` 요약 출력

**내부 동작 (7단계)**:

**Step 0 — 프로젝트 유형 자동 감지** (Dual-Mode)

스킬 시작 시 bash로 현재 디렉토리를 검사하여 두 모드 중 하나를 선택합니다:

| 조건 | 모드 | 감사 대상 |
|------|------|----------|
| `templates/` + `init-project.sh` 존재 | **Template Mode** | README.md, docs/GUIDE.md, docs/REFERENCES.md |
| `.research/` + `AGENTS.md` 존재 | **Research Mode** | AGENTS.md, CLAUDE.md, GEMINI.md, README.md(있으면) |
| 해당 없음 | 연구자에게 확인 | — |

이를 통해 하나의 스킬이 ai-research-env 템플릿 프로젝트 자체와 `init-project.sh`로 생성된 연구 프로젝트 양쪽에서 모두 동작합니다.

**Step 1 — Pre-flight**: `git diff --name-only HEAD~5`로 최근 변경된 파일 목록 확인 (git 없으면 전체 감사 모드)

**Step 2 — Per-File 감사** (모드별):
- *Template Mode*: README 스킬 테이블 수/내용 vs 실제 `templates/.claude/skills/`, hook 섹션 vs 실제 `templates/.claude/hooks/`, 디렉토리 구조 트리 일치 여부
- *Research Mode*: AGENTS.md 스킬 목록 vs 실제 `.claude/skills/`, CLAUDE.md Safety Rules FROZEN dirs vs 실제 `check-freeze.sh`, GEMINI.md와 AGENTS.md 일관성

**Step 3 — Auto-Update (확인 없이 자동 적용)**:
- 스킬 개수 변경 ("9개 Skills" → "10개 Skills")
- 스킬 테이블/목록에 새 항목 추가
- 디렉토리 구조 트리 갱신
- 파일 경로 참조 수정
- hook 패턴 테이블 갱신

**Step 4 — Risky Changes (연구자 확인 필요)**:
- 프로젝트 소개문/포지셔닝 변경
- 아키텍처 설계 근거 설명 변경
- 섹션 삭제 또는 대규모 재작성

**Step 5 — Cross-Doc 일관성 검사**:
- *Template Mode*: README 스킬 수 ↔ GUIDE 스킬 목록, README hook 설명 ↔ GUIDE hook 섹션, README 구조 트리 ↔ GUIDE 구조 트리
- *Research Mode*: AGENTS.md 스킬 목록 ↔ CLAUDE.md Skills Guide, CLAUDE.md Safety Rules ↔ `check-freeze.sh` FROZEN_DIRS 실제값

**Step 6 — Summary**: 파일별 상태 출력
```
Documentation sync health:
  README.md           [Updated] (스킬 수 9→10, /sync-docs 행 추가)
  docs/GUIDE.md       [Current]
  docs/REFERENCES.md  [Skipped]
```

**Hard Gate**: `Read, Glob, Grep, Edit, Write, Bash, AskUserQuestion` 허용. Bash는 디렉토리/git 조회 용도로만 사용 (실험 실행 금지).

#### Shared Skills (범용 생산성 스킬)

연구 전용 스킬 외에도, 모든 프로젝트와 일상 업무에서 유용한 **범용 생산성 스킬 12개**가 포함되어 있습니다. 이 스킬들은 [anthropic/skills](https://github.com/anthropics/anthropic-quickstarts/tree/main/computer-use-demo/skills)와 [antigravity-awesome-skills](https://github.com/antigravity-ai/awesome-skills)에서 엄선하여 통합되었습니다.

| 소스 | 스킬 | 용도 |
|------|------|------|
| **Official (Anthropic)** | `pdf` | 논문 및 PDF 문서 읽기, 데이터 추출 |
| | `skill-creator` | 새 스킬 생성, 테스트, 평가 도구 |
| | `xlsx` | 실험 결과 데이터(Excel) 분석 및 처리 |
| | `pptx` | 연구 발표 자료(PowerPoint) 생성 및 편집 |
| | `doc-coauthoring` | 기술 문서, 제안서 공동 작성 구조화 |
| | `sync-docs` | **핵심**: 프로젝트 문서(README, GUIDE 등) 자동 동기화 |
| **Community (Antigravity)** | `matplotlib` | 논문용 고품질 그래프 및 시각화 생성 |
| | `seaborn` | 통계 데이터 시각화 (matplotlib 보완) |
| | `bash-pro` | 방어적 Bash 스크립팅 및 자동화 전문가 |
| | `python-pro` | Python 3.12+ 최신 패턴 및 성능 최적화 |
| | `gdb-cli` | C/C++ 시뮬레이터 디버깅 (GDB 연동) |
| | `git-advanced-workflows` | 복잡한 Git 히스토리 관리 및 복구 |

### 8. 연구 워크플로우

> **알림**: 기존의 4단계 연구 워크플로우와 스킬 매핑은 새로운 파이프라인 설계를 위해 제거되었습니다.

**Scope Mode가 하는 일**: `.research/scope-mode.txt`에 현재 단계가 기록됨. 양쪽 모델이 작업 시작 전 이 파일을 읽고, 현재 단계에서 허용되지 않는 행동을 하지 않도록 자기 제어.

예시:
- `FOCUSED` 모드에서 Claude가 새로운 연구 방향을 제안하면 → AGENTS.md §4의 "Must Avoid: Direction changes, new ideas" 위반
- `EXPLORATION` 모드에서 Gemini가 코드를 작성하면 → "Must Avoid: Code writing, parameter decisions" 위반

**scope-mode.txt 변경**: 연구자만 가능. AI는 변경 불가 (`.research/` 디렉토리 규칙으로 강제).

### 9. Dynamic Model Selection (최적 모델 자동 선택)

환경은 항상 최고의 성능과 안정성을 가진 모델을 사용할 수 있도록 자동 갱신 메커니즘을 제공합니다.

#### 8-1. 아키텍처
- **기준 모델**: Claude Code의 기본 모델은 `opusplan`으로 설정됩니다. (Plan 모드: Opus, Execution 모드: Sonnet 자동 전환)
- **자동 갱신 (Cron)**: 업무 시간(10:00 ~ 20:00) 동안 매시간 `sync-models.py`가 백그라운드에서 실행됩니다.
- **환경 변수 주입**: 스크립트가 `~/.claude/model-env.sh`를 갱신하고, 이는 `.bashrc`/`.zshrc`를 통해 셸에 로드됩니다.
- **결과**: `opusplan`이 참조하는 `ANTHROPIC_DEFAULT_OPUS_MODEL`과 `ANTHROPIC_DEFAULT_SONNET_MODEL`이 항상 최적의 모델 버전으로 자동 오버라이드됩니다.

#### 8-2. 선택 알고리즘 (sync-models.py)
단순한 1시간 단위 최고점이 아니라 연구에 적합한 "복합 판단"을 내립니다:
1. **자격 심사**: 7일 평균 점수(`periodAvg`)가 55점 미만이거나, API에서 `critical` 수준의 성능 저하(degradation)가 보고된 모델은 즉시 후보에서 제외됩니다.
2. **실시간 랭킹**: 자격을 통과한 모델 중 실시간 점수(`currentScore`)가 가장 높은 모델을 1위로 선정합니다.
3. **Hysteresis (플립플롭 방지)**: 새로운 1위 모델이 현재 사용 중인 모델보다 **5점 이하**로 높다면 교체하지 않습니다. (모델이 매시간 바뀌어 컨텍스트가 흔들리는 현상 방지)

#### 8-3. 온디맨드 심층 분석 (/check-models)
Antigravity에게 `/check-models` 명령을 내리면, 실시간 벤치마크 데이터를 심층 분석합니다:
- 각 모델의 점수 안정성(`stability`), 신뢰 구간 하한(`confidenceLower`), 추세(`trend`) 분석
- 코딩 벤치마크(correctness, codeQuality 등) 7-axis 세부 역량 검토
- 인사이트를 종합하여 모델 유지/변경을 제안 (실제 변경 여부는 연구자의 판단)

---

### 10. 안전 메커니즘

#### 9-1. Hooks (물리적 차단) — Claude 전용

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

#### 8-8. Verification Gate Function — 양쪽 모델

완료 주장 전 **5단계 절차 필수**:

```
1. IDENTIFY: 이 주장을 증명할 명령/검사는?
2. RUN: 검증 실행 (이번 세션에서, 기억에 의존 금지)
3. READ: 전체 출력 확인. exit code. 오류 수 확인.
4. VERIFY: 출력이 실제로 주장을 뒷받침하는가?
   - NO → 실제 상태를 증거와 함께 보고
   - YES → 5단계로
5. CLAIM: 증거와 함께 주장 (관련 출력 포함)
```

어떤 단계라도 건너뛰면 "검증"이 아니라 "주장". DONE/DONE_WITH_CONCERNS 선언 전 항상 적용.

#### 8-9. Rationalization Prevention — 양쪽 모델

LLM은 규칙에서 빠져나갈 논리 경로를 능동적으로 구성함. 연구 컨텍스트 주요 패턴과 반박:

| 합리화 | 현실 |
|--------|------|
| "실험이 너무 작아서 공식 설계 불필요" | 규모는 변수 통제를 면제하지 않음 |
| "결과가 어떻게 나올지 이미 앎" | 예측 ≠ 증거. 실행하라 |
| "연구자가 잡아줄 것" | Human-in-the-loop은 방향 결정용, 오류 수정용이 아님 |
| "이번 실패는 단순 — 3-Strike 불필요" | 단순했다면 첫 번째 수정이 작동했을 것 |

전체 테이블: AGENTS.md §10.5 + `.agents/rules/rationalization-prevention.md`

#### 8-10. Forced-Invocation Directive — 양쪽 모델

작업 키워드가 AGENTS.md §9 테이블에 매핑되면 **반드시** 해당 스킬을 invoke해야 함. 판단 재량 없음.

```
"analyze" 키워드 감지 → /analyze 스킬 invoke 전까지 분석 시작 불가
"debug" 키워드 감지 → /diagnose 스킬 invoke 전까지 진단 시작 불가
```

Red Flags (스킬 건너뛰기 합리화):
- "잠깐 살펴보기만 할게요" → 스킬이 HOW를 정의함. 먼저 invoke
- "스킬 내용 기억함" → 스킬은 변함. 현재 버전을 invoke
- "연구자가 이미 방법을 알려줬음" → 지시는 WHAT, 스킬은 HOW



---

### 12. .research/ 상태 파일

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

### 13. 파일 맵

#### 템플릿 (`ai-research-env/templates/`)

| 경로 | 설명 |
|------|------|
| `AGENTS.md` | 공유 규칙 12개 섹션 |
| `CLAUDE.md` | Claude 역할 + 스킬 가이드 + 안전 규칙 |
| `GEMINI.md` | Gemini 역할 + 규칙 참조 + 아티팩트 규약 |
| `.claude/settings.json` | hooks 등록 (freeze + careful) + 기본 권한 (Read, Glob, Grep, WebSearch) |
| `.claude/hooks/check-freeze.sh` | FROZEN 디렉토리 보호 (deny) |
| `.claude/hooks/check-careful.sh` | 위험 명령 감지 (ask) |
| `.claude/hooks/pre-read-guard.sh` | 중복 읽기 방지 Hook (warning) |
| `.claude/skills/*/SKILL.md` | (새로운 파이프라인에 맞춰 추가될 예정) |
| `.agents/skills/*/SKILL.md` | (새로운 파이프라인에 맞춰 추가될 예정) |
| `.research/context.md` | 연구 맥락 (세션 시작 시 필독) |
| `.research/wisdom.md` | 누적 인사이트 (3-카테고리, append-only) |
| `.research/decisions.md` | 핵심 결정 기록 (append-only) |
| `.research/scope-mode.txt` | 현재 Scope Mode (기본: EXPLORATION) |
| `.research/pipeline-status.md` | 실험 파이프라인 상태 |

#### 인프라 (`ai-research-env/`)

| 경로 | 설명 |
|------|------|
| `init-project.sh` | 11단계 프로젝트 초기화 스크립트 |
| `scripts/generate-project-map.sh` | 프로젝트 디렉토리 맵 파싱 스크립트 |
| `tests/test-check-freeze.sh` | check-freeze.sh hook 단위 테스트 (7 test cases) |
| `tests/test-check-careful.sh` | check-careful.sh hook 단위 테스트 (10 test cases) |
| `setup.sh` | 글로벌 설정 설치 (선택사항) |
| `global/claude/CLAUDE.md` | 글로벌 Claude 기본 규칙 |
| `global/claude/settings.json` | 글로벌 기본 권한 |
| `global/gemini/AGENTS.md` | 글로벌 Gemini 기본 규칙 |
| `docs/GUIDE.md` | 이 문서 |
| `README.md` | 프로젝트 소개 (한국어) |

### 14. 다음 세션 TODO

추가 harness engineering 후보:

- [ ] AGENTS.md §12에 DONE/BLOCKED 출력 형식의 구체적 마크다운 템플릿 추가 (DEFERRED — Verification Gate Function이 사실상 대체. 실사용 시 불일치 발생하면 추가)
- [ ] 스킬별 Completion Status를 skill-specific하게 커스터마이징 (DEFERRED — 실험 1~2회 경험 후 정의해야 의미 있음)
- [ ] 실제 연구 프로젝트에서 init-project.sh 실행 후 end-to-end 테스트 (DEFERRED — 스크립트 수정 시 추가)

**완료된 harness 개선 이력** (superpowers 분석 결과 반영, 2026-03-26):
- [x] Verification Gate Function → AGENTS.md §8
- [x] Forced-Invocation Directive + Red Flags → AGENTS.md §9
- [x] Rationalization Prevention → AGENTS.md §10.5 + `.agents/rules/rationalization-prevention.md`
- [x] CSO Description Convention → 모든 SKILL.md description "Use when..." 형식
- [x] Implementation Steps → `/experiment-design` SKILL.md (>1 file or >20 lines trigger)
- [x] Integration Test Infrastructure → `tests/` 디렉토리 (8/8 pass)




