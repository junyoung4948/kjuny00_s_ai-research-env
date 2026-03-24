# ai-research-env

컴퓨터 아키텍처/시스템 연구를 위한 **AI 멀티 에이전트 협업 환경** 템플릿.

[Claude Code](https://docs.anthropic.com/en/docs/claude-code)(Opus/Sonnet)와 [Antigravity](https://blog.google/technology/google-deepmind/project-mariner-gemini/)(Gemini)가 **파일시스템 기반 비동기 통신**으로 협업하며, 연구자(human-in-the-loop)가 모든 핵심 결정을 통제합니다.

---

## 왜 만들었나?

Claude Code와 Antigravity(Gemini)를 연구에 같이 쓰고 싶은데, 두 모델이 같은 프로젝트에서 협업할 수 있는 표준화된 환경이 없었습니다.

이 템플릿은:
- 두 모델의 **역할 분담**과 **통신 규약**을 정의합니다
- **파라미터 결정, 실험 결과 보호, 디버깅 한도** 등의 안전장치를 설정 파일과 hook으로 강제합니다
- 연구 맥락을 `.research/`에 보존하여 세션 간 연속성을 유지합니다

---

## 어떻게 만들어졌나?

이 프레임워크는 두 오픈소스 프로젝트를 분석하여 설계되었습니다:

1. **[oh-my-openagent](https://github.com/nicekate/oh-my-openagent)** — AGENTS.md를 활용한 크로스 툴 브릿지 패턴, Wisdom 누적 시스템, Category 기반 모델 흐름 가이드
2. **[gstack](https://github.com/anthropics/gstack)** — Claude Code Skills(Hard Gate), PreToolUse hooks(freeze/careful), artifact 기반 비동기 통신, 3-Strike Rule

두 프로젝트의 분석 결과를 교차 검증하고, Gemini와 Claude가 공동으로 구현 계획을 수립한 뒤 Claude Code가 최종 구현했습니다.

---

## 핵심 개념

### 1. 단계별 Lead/Support 역할 분담

각 연구 단계에서 가장 적합한 모델이 **Lead**를 맡습니다.

| 연구 단계 | Lead | Support | 이유 |
|-----------|------|---------|------|
| 가설 수립 (`/brainstorm`) | **Gemini** | Claude | 넓은 컨텍스트로 논문 참조, 아이디어 연결 |
| 실험 설계 (`/experiment-design`) | **Claude** | Gemini | 변수 통제, 파라미터 공간 정의에 정밀 추론 |
| 시뮬레이션 스크립트 구현 | **Claude** | — | CLI 네이티브, 직접 실행/디버깅 |
| 분석 스크립트 구현 | **Gemini** | — | 에디터 inline, 멀티모달 시각화 확인 |
| 실험 실행/모니터링 | **Claude** | — | CLI 프로세스 관리, 로그 모니터링 |
| 결과 검증 (`/validate`) | **Claude** | — | 수치 범위 검증, 일관성 체크 |
| 결과 분석 (`/analyze`) | **Gemini** | Claude | 대량 데이터 패턴 파악, 멀티모달 |
| 논문 작성 (`/document`) | **Gemini** | Claude | 스토리라인 구성 → 기술적 정확성 검증 분리 |
| 실패 진단 (`/diagnose`) | **Claude** | — | 체계적 디버깅, 3-Strike Rule |
| 회고 (`/reflect`) | **Claude** | — | Memory 시스템으로 세션 간 연속성 |

### 2. Artifact 기반 비동기 통신

두 모델은 API 직접 통신 없이 **파일시스템 artifact로 비동기 소통**합니다.

```
Lead 모델 → *-draft.md    (초안)
    ↓ (연구자가 Support에게 review 요청)
Support 모델 → *-review.md  (검증/피드백)
    ↓ (연구자가 Lead에게 반영 요청)
Lead 모델 → *-final.md    (최종본)
```

연구자가 모든 handoff를 중재하므로 AI 간 직접 통신의 위험을 방지합니다.

### 3. Hard Gate (Skills)

Claude Code의 Skills 시스템(`allowed-tools`)으로 **물리적으로** 도구를 차단합니다.

예: `/brainstorm`에서는 `Read`, `Glob`, `Grep`, `AskUserQuestion`만 허용 → 코드 작성/실행 불가

프롬프트 수준의 "하지 마세요"가 아니라, 도구 자체가 차단되므로 우회 불가능합니다.

### 4. 안전 메커니즘

- **Atomic Decision**: 파라미터를 한 번에 하나씩 연구자에게 확인
- **3-Strike Rule**: `/diagnose`에서 3개 가설 모두 실패 시 연구자에게 에스컬레이션 (무한 디버깅 방지)
- **FROZEN 디렉토리**: `profiling/results/`, `simulation/results/` 수정을 hook으로 자동 차단
- **Careful hook**: `rm -r`, `git reset --hard`, `git push -f` 등 위험 명령 감지 시 확인 요청
- **Scope Mode**: 현재 연구 단계에 맞지 않는 행동을 자제 (예: FOCUSED 모드에서 새 아이디어 탐색 방지)

### 5. 세션 간 연속성

`.research/` 디렉토리가 연구 맥락을 영구 보존합니다:

| 파일 | 용도 |
|------|------|
| `context.md` | 현재 연구 맥락, 진행 상황 (세션 시작 시 필수 읽기) |
| `wisdom.md` | 누적 인사이트 — 실패 교훈, 도구 팁 (추가만, 삭제 금지) |
| `decisions.md` | 핵심 설계/방법론 결정 기록 |
| `scope-mode.txt` | 현재 Scope Mode (연구자만 변경) |
| `pipeline-status.md` | 활성/완료 실험 상태 추적 |

---

## 설치

### 요구사항

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Antigravity (Project Mariner)](https://blog.google/technology/google-deepmind/project-mariner-gemini/) 또는 Gemini 기반 에이전트
- bash, python3

### 1단계: 이 레포 클론

```bash
git clone https://github.com/<your-username>/ai-research-env.git
cd ai-research-env
```

### 2단계: 전역 설정 설치 (선택)

```bash
bash setup.sh
```

`~/.claude/CLAUDE.md`와 `~/.claude/settings.json`에 기본 설정을 복사합니다.
기존 파일이 있으면 건너뜁니다.

### 3단계: 연구 프로젝트에 적용

```bash
cd /path/to/your/research-project
bash /path/to/ai-research-env/init-project.sh
```

이 명령이 생성하는 구조:

```
your-research-project/
├── AGENTS.md              ← 양쪽 모델 공유 규칙
├── CLAUDE.md              ← Claude Code 전용 지침
├── GEMINI.md              ← Antigravity 전용 지침
├── .gitignore
├── .aiexclude             ← Gemini에서 민감 파일 제외
├── .claude/
│   ├── settings.json      ← hooks, permissions
│   ├── hooks/
│   │   ├── check-freeze.sh   ← FROZEN 디렉토리 보호
│   │   └── check-careful.sh  ← 위험 명령 감지
│   └── skills/
│       ├── brainstorm/SKILL.md
│       ├── experiment-design/SKILL.md
│       ├── validate/SKILL.md
│       ├── analyze/SKILL.md
│       ├── diagnose/SKILL.md
│       ├── document/SKILL.md
│       └── reflect/SKILL.md
├── .agent/
│   ├── rules/research-roles.md    ← Antigravity 역할 규칙
│   └── workflows/research-cycle.md ← 연구 사이클 워크플로우
├── .research/
│   ├── context.md         ← 현재 연구 맥락
│   ├── wisdom.md          ← 누적 인사이트
│   ├── decisions.md       ← 핵심 결정 기록
│   ├── scope-mode.txt     ← 현재 Scope Mode
│   ├── pipeline-status.md ← 실험 파이프라인 상태
│   ├── plans/             ← 가설, 실험 설계서
│   ├── feedback/          ← 교차 리뷰, 검증 결과
│   ├── retros/            ← 회고 기록
│   └── logs/              ← 실험 로그 요약
├── profiling/
│   ├── scripts/
│   └── results/           ← [FROZEN] 수정 금지
├── simulation/
│   ├── configs/
│   ├── scripts/
│   └── results/           ← [FROZEN] 수정 금지
└── docs/
    └── sections/          ← 논문 섹션별 draft/review/final
```

---

## 사용법

### 연구 사이클 전체 흐름

```
EXPLORATION ──→ REFINEMENT ──→ FOCUSED ──→ WRITING
   (가설)        (설계)       (실행)      (문서화)
     ↑                                      │
     └────────────── (회고 후 재탐색) ────────┘
```

### Quick Start

**1. 연구 주제 설정**

`.research/context.md`에 연구 주제와 현재 상황을 작성합니다.

**2. 가설 수립** (Scope Mode: `EXPLORATION`)

```
# Antigravity(Gemini)에서
/brainstorm

# → .research/plans/hypothesis-{topic}-draft.md 생성
# → 연구자가 Claude에게 review 요청
# → Claude가 hypothesis-{topic}-review.md 작성
# → Gemini가 반영하여 hypothesis-{topic}-final.md 생성
```

**3. 실험 설계** (Scope Mode: `REFINEMENT`)

```
# Claude Code에서
/experiment-design

# → Atomic Decision으로 파라미터를 하나씩 확인
# → .research/plans/experiment-{name}-draft.md 생성
```

**4. 실험 실행 + 검증** (Scope Mode: `FOCUSED`)

```
# Claude Code에서 시뮬레이션 스크립트 구현 및 실행
# 완료 후:
/validate

# → .research/feedback/validation-{name}.md 생성
# 문제 발견 시:
/diagnose    # 3-Strike Rule 적용
```

**5. 결과 분석**

```
# Antigravity(Gemini)에서
/analyze

# → .research/feedback/analysis-{name}-draft.md 생성
# → Claude가 수치 정확성 검증 review 작성
```

**6. 논문 작성** (Scope Mode: `WRITING`)

```
# Antigravity(Gemini)에서
/document

# → docs/sections/{section}-draft.md 생성
# → Claude가 기술적 정확성 교정 review 작성
```

**7. 회고**

```
# Claude Code에서
/reflect

# → .research/retros/{date}.md 생성
# → wisdom.md, context.md 자동 갱신
```

### Scope Mode 변경

`.research/scope-mode.txt`를 직접 편집합니다 (연구자만 변경 가능):

```
EXPLORATION    # 방향 탐색 — 자유 아이디어 탐색, 코드 작성 자제
REFINEMENT     # 구체화 — 실험 설계, 새 방향 자제
FOCUSED        # 집중 실행 — 코드/실험, 방향 전환 자제
WRITING        # 문서화 — 논문 작성, 새 실험 자제
```

---

## 7개 Skills 요약

| Skill | 호출 | Lead | Hard Gate (허용 도구) | 출력 |
|-------|------|------|----------------------|------|
| **brainstorm** | `/brainstorm` | Gemini | Read, Glob, Grep, WebSearch | `.research/plans/hypothesis-*.md` |
| **experiment-design** | `/experiment-design` | Claude | Read, Glob, Grep, WebSearch | `.research/plans/experiment-*.md` |
| **validate** | `/validate` | Claude | Read, Glob, Grep, Bash(읽기) | `.research/feedback/validation-*.md` |
| **analyze** | `/analyze` | Gemini | Read, Glob, Grep, WebSearch | `.research/feedback/analysis-*.md` |
| **diagnose** | `/diagnose` | Claude | Read, Glob, Grep, Bash, Edit | `.research/feedback/diagnosis-*.md` |
| **document** | `/document` | Gemini→Claude | Read, Glob, Grep, Edit, Write | `docs/sections/*-draft/review/final.md` |
| **reflect** | `/reflect` | Claude | Read, Glob, Grep, Edit, Write | `.research/retros/*.md` |

---

## Hooks

### check-freeze.sh (PreToolUse: Edit, Write)

`profiling/results/`와 `simulation/results/` 내 파일 편집을 **자동 차단**합니다.
실험 결과의 재현성을 보장합니다.

### check-careful.sh (PreToolUse: Bash)

위험한 명령을 감지하고 확인을 요청합니다:

| 패턴 | 동작 |
|------|------|
| `rm -r` / `rm -rf` | 확인 요청 (캐시/빌드 삭제는 예외) |
| `git reset --hard` | 확인 요청 |
| `git push -f` / `--force` | 확인 요청 |
| `kill -9` | 확인 요청 |
| `DROP TABLE` / `DROP DATABASE` | 확인 요청 |
| `git clean -f` | 확인 요청 |

---

## 커스터마이징

### 연구 분야 변경

`AGENTS.md`의 **섹션 1**에서 프로젝트 개요를 수정하세요.
컴퓨터 아키텍처 외의 분야에서도 동일한 프레임워크를 적용할 수 있습니다.

### FROZEN 디렉토리 추가

1. `AGENTS.md` 섹션 7에 경로 추가
2. `.claude/hooks/check-freeze.sh`의 `FROZEN_DIRS` 배열에 경로 추가

### Skill 추가

`.claude/skills/<name>/SKILL.md`를 생성하고 YAML frontmatter에 `allowed-tools`를 정의하세요.

### Careful hook 패턴 추가

`.claude/hooks/check-careful.sh`에 패턴 감지 블록을 추가하세요.

---

## 아키텍처 결정 기록

| 결정 | 선택 | 이유 |
|------|------|------|
| 레포 구조 | 별도 템플릿 레포 + init-project.sh 주입 | 연구 프로젝트와 환경 설정 분리 |
| 역할 분담 | 단계별 Lead/Support | 모델 강점에 따른 최적 배치 |
| 모드 시스템 | Scope Mode (4단계) + Category (참고 가이드) | 강제력 있는 모드 + 유연한 가이드 |
| 스킬 vs 커맨드 | Claude Code Skills | allowed-tools로 Hard Gate 물리적 강제 |
| 모델 간 통신 | 파일시스템 artifact | API 직접 통신 불가, 연구자 중재 |

---

## 참고 자료

- [Claude Code Skills](https://docs.anthropic.com/en/docs/claude-code/skills) — SKILL.md, allowed-tools
- [Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) — PreToolUse, permissionDecision
- [AGENTS.md 규격](https://google.github.io/adk-docsite/agents/agents-md/) — Antigravity/Gemini 자동 로딩
- [oh-my-openagent](https://github.com/nicekate/oh-my-openagent) — 크로스 툴 AI 에이전트 프레임워크
- [gstack](https://github.com/anthropics/gstack) — Claude Code 기반 풀스택 에이전트

---

## License

MIT
