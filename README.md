# ai-research-env

컴퓨터 아키텍처/시스템 연구를 위한 **AI 멀티 에이전트 협업 환경** 템플릿.

[Claude Code](https://docs.anthropic.com/en/docs/claude-code)(Opus/Sonnet)와 [Antigravity](https://blog.google/technology/google-deepmind/project-mariner-gemini/)(Gemini)가 **파일시스템 기반 비동기 통신**으로 협업하며, 연구자(human-in-the-loop)가 모든 핵심 결정을 통제합니다.

---

## 왜 만들었나?

Claude Code와 Gemini를 하나의 연구 프로젝트에서 함께 사용하기 위한 설정 파일 모음입니다.

이 템플릿은:
- 두 모델의 **역할 분담**과 **통신 규약**을 정의합니다
- **파라미터 결정, 실험 결과 보호, 디버깅 한도** 등의 안전장치를 설정 파일과 hook으로 강제합니다
- AI 슬롭(scope inflation, hallucinated expertise 등)을 방지하는 **규율 시스템**을 포함합니다
- 연구 맥락을 `.research/`에 보존하여 세션 간 연속성을 유지합니다

---

## 어떻게 만들어졌나?

이 프레임워크는 세 오픈소스 프로젝트를 분석하여 설계되었습니다:

1. **[oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)** — AGENTS.md를 활용한 크로스 툴 브릿지 패턴, Wisdom 누적 시스템, Category 기반 모델 흐름 가이드
2. **[gstack](https://github.com/garrytan/gstack)** — Claude Code Skills(Hard Gate), PreToolUse hooks(freeze/careful), artifact 기반 비동기 통신, 3-Strike Rule
3. **[superpowers](https://github.com/obra/superpowers)** — Rationalization Prevention Tables, CSO Description Convention, Forced-Invocation Directive, Verification Gate Function

세 프로젝트의 패턴을 참고하여 연구 환경에 맞게 설계했습니다.

> 📖 **상세 가이드**: [docs/GUIDE.md](docs/GUIDE.md)에 아키텍처, 스킬 사용법, 안전 메커니즘의 내부 동작이 자세히 정리되어 있습니다.
> 
> 🧠 **오픈소스 레퍼런스 및 아키텍처 분석**: [docs/REFERENCES.md](docs/REFERENCES.md)에 3개의 주요 오픈소스 프로젝트가 어떻게 현재 환경에 적용되었는지 상세한 설명이 있습니다.

---

## 핵심 개념

### 1. Artifact 기반 비동기 통신

두 모델은 API 직접 통신 없이 **파일시스템 artifact로 비동기 소통**합니다.

**수동 방식** (기본):
```
Lead 모델 → *-draft.md    (초안)
    ↓ (연구자가 Support에게 review 요청)
Support 모델 → *-review.md  (검증/피드백)
    ↓ (연구자가 Lead에게 반영 요청)
Lead 모델 → *-final.md    (최종본)
```

연구자가 매 handoff를 직접 중재하여 모든 결정을 통제합니다. 루틴 review 사이클은 **Auto-Handoff(§3)** 로 자동화할 수 있으며, 이 경우에도 가설 선택·파라미터 값 등 중요한 결정은 `requires_human` 플래그로 연구자 확인이 강제됩니다.

### 3. Auto-Handoff (자동 오케스트레이션)

기존 파이프라인에 존재하던 Auto-Handoff(signal 기반 리뷰 사이클 자동화) 메커니즘은 새 파이프라인 구축을 위해 현재 제거된 상태입니다.

### 4. Hard Gate (Skills)

Claude Code의 Skills 시스템(`allowed-tools`)으로 **물리적으로** 도구를 차단합니다.

예: `/brainstorm`에서는 `Read`, `Glob`, `Grep`, `AskUserQuestion`만 허용 → 코드 작성/실행 불가

프롬프트 수준의 "하지 마세요"가 아니라, 도구 자체가 차단되므로 우회 불가능합니다.

### 5. Dynamic Model Selection

환경은 `aistupidlevel.info`의 실시간 벤치마크를 기반으로 항상 최고의 성능과 안정성을 가진 모델을 사용하도록 1시간 단위로(10:00 ~ 20:00) 자동 갱신됩니다.
- 기준 모델은 `opusplan`(Plan: Opus, Execution: Sonnet 자동 전환)
- `sync-models.py`가 7-day 평균 55점 이상인 후보 중 `currentScore` 기준으로 최적의 Opus/Sonnet 버전을 찾아 셸 환경변수 갱신

### 6. 안전 메커니즘

- **Atomic Decision**: 파라미터를 한 번에 하나씩 확인
- **3-Strike Rule**: `/diagnose` 등에서 3회 실패 시 에스컬레이션
- **FROZEN 디렉토리**: 결과물(`profiling/results/` 등) 수정 차단
- **Careful hook**: 위험 명령(`rm -rf` 등) 감지 시 확인
- **Scope Mode**: 현재 연구 단계에 맞는 행동만 허용
- **Verification Gate Function**: 완료 전 5단계(IDENTIFY→VERIFY 등) 강제 — `safety.md` + `AGENTS.md §8`
- **Forced-Invocation Directive**: 특정 키워드 작업 시 필수 스킬 invoke
- **Rationalization Prevention**: LLM의 임의 우회 논리 사전 차단
- **Required Reading by Phase**: AGENTS.md를 통째로 주입하지 않고 "X할 때 §Y를 읽어라" 지시어로 on-demand 로딩 — `CLAUDE.md`/`GEMINI.md`에 포함

### 7. 세션 간 연속성

`.research/` 디렉토리가 연구 맥락을 영구 보존합니다:

| 파일 | 용도 |
|------|------|
| `context.md` | 현재 연구 맥락, 진행 상황 (세션 시작 시 필수 읽기) |
| `wisdom.md` | 누적 인사이트 — 실패 교훈, 도구 팁 (추가만, 삭제 금지) |
| `decisions.md` | 핵심 설계/방법론 결정 기록 |
| `scope-mode.txt` | 현재 Scope Mode (연구자만 변경) |
| `pipeline-status.md` | 활성/완료 실험 상태 추적 |

### 8. 토큰 최적화 시스템

**[OpenWolf](https://github.com/nikhilweee/OpenWolf)**와 **[Aspens](https://github.com/acenolaza/aspens)** 오픈소스 프로젝트를 참고하여 구현한 토큰 효율성 시스템입니다.

**대폭 토큰 절감** — 매번 반복되는 디렉토리 탐색, 중복 파일 접근을 제거:

| 컴포넌트 | 기능 | 절감 효과 |
|----------|------|----------|
| **Project Map** | 파일 구조 + 토큰 추정 사전 인덱싱 | 디렉토리 탐색 반복 제거 |
| **Pre-Read Guard** | 중복 읽기 감지 Hook + 경고 | 세션 내 재독 방지 |

**완전 자동 동작** — `init-project.sh` 실행 시 자동 설치되어, 에이전트들이 즉시 효율적으로 협업할 수 있습니다.

> **스킬 검색**: Claude Code와 Antigravity는 이미 SKILL.md의 YAML frontmatter를 자동으로 읽어 트리거 여부를 판단합니다. 별도의 스킬 인덱스 없이도 효율적으로 작동합니다.

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

### 2단계: 전역 설정 설치 (권장)

```bash
bash setup.sh
```

다음을 설치합니다:
- `~/.claude/CLAUDE.md`, `~/.claude/settings.json` — Claude Code 기본 설정
- `~/.claude/skills/*`, `~/.agents/skills/*` — Shared Skills (global)
- Dynamic Model Selection — 1시간 단위 자동 모델 업데이트

**Shared Skills를 global로 설치**하면 모든 프로젝트에서 공통으로 사용 가능하며, 업데이트도 한 곳에서만 하면 됩니다.
기존 파일이 있으면 건너뜁니다 (`--update` 플래그로 강제 업데이트 가능).

### 3단계: 연구 프로젝트에 적용

```bash
cd /path/to/your/research-project
bash /path/to/ai-research-env/init-project.sh
```

이 명령이 생성하는 구조:

```
your-research-project/
├── AGENTS.md              ← 양쪽 모델 공유 규칙 (지시어 기반 lazy loading)
├── CLAUDE.md              ← Claude Code 전용 지침
├── GEMINI.md              ← Antigravity 전용 지침
├── .gitignore
├── .aiexclude             ← Gemini에서 민감 파일 제외
├── .claude/
│   ├── settings.json      ← hooks, permissions
│   ├── hooks/
│   │   ├── check-freeze.sh   ← FROZEN 디렉토리 보호
│   │   ├── check-careful.sh  ← 위험 명령 감지
│   │   └── pre-read-guard.sh ← 중복 파일 읽기 감지 및 경고
│   └── skills/            ← brainstorm-arch, build-motivation, peer-review
├── .agents/
│   ├── skills/            ← brainstorm-arch, build-motivation, peer-review
├── scripts/               ← 토큰 최적화 및 모델 동기화 스크립트
│   ├── generate-project-map.sh
│   ├── install-cron.sh
│   └── sync-models.py
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
├── tests/                 ← Hook 단위 테스트 (init-project.sh가 복사)
│   ├── test-check-freeze.sh
│   └── test-check-careful.sh
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

**현재 파이프라인 및 스킬셋 재설계 중입니다.** 
연구 사이클(`EXPLORATION`, `REFINEMENT`, `FOCUSED`, `WRITING`)에 맞춘 새로운 가이드와 전용 스킬들이 곧 안내될 예정입니다.

### Scope Mode 변경

`.research/scope-mode.txt`를 직접 편집합니다 (연구자만 변경 가능):

```
EXPLORATION    # 방향 탐색 — 자유 아이디어 탐색, 코드 작성 자제
REFINEMENT     # 구체화 — 실험 설계, 새 방향 자제
FOCUSED        # 집중 실행 — 코드/실험, 방향 전환 자제
WRITING        # 문서화 — 논문 작성, 새 실험 자제
```

---

> **`/sync-docs`는 환경 유지보수 스킬입니다.** (현재 `shared-skills`에 위치)
> 스킬 추가, hook 수정, 스크립트 변경 후 실행하면 README, GUIDE.md, AGENTS.md 등의 문서를 실제 프로젝트 상태에 맞게 자동 동기화합니다.
> 실행 시 프로젝트 유형을 자동 감지합니다:
> - `templates/` + `init-project.sh` 존재 → **Template Mode**: README, docs/GUIDE.md, docs/REFERENCES.md 감사
> - `.research/` + `AGENTS.md` 존재 → **Research Mode**: AGENTS.md, CLAUDE.md, GEMINI.md 감사
> 스킬 수 변경, 파일 경로 수정 등 사실적 변경은 자동 적용하고, 서술적 변경은 확인 후 적용합니다.

## Shared Skills (범용 생산성 스킬)

연구 전용 스킬(10개) 외에도, 모든 프로젝트와 일상 업무에서 유용한 **범용 생산성 스킬 12개**가 포함되어 있습니다. 이 스킬들은 Claude와 Antigravity 양쪽 에이전트에서 동일하게 사용할 수 있습니다.

### 설치 및 업데이트
- **Claude 전역**: `setup.sh` 실행 시 `~/.claude/skills/`에 설치되어 어떤 프로젝트에서든 사용 가능합니다.
- **프로젝트별**: `init-project.sh` 실행 시 해당 프로젝트의 `.claude/skills/`와 `.agents/skills/`에 각각 복사됩니다.
- **업데이트**: `setup.sh --update` 또는 `init-project.sh --update`로 최신 버전으로 갱신할 수 있습니다.

### 제공되는 스킬 목록

| 소스 | 스킬 | 용도 |
|------|------|------|
| **Official (Anthropic)** | `pdf` | 논문 및 PDF 문서 읽기, 데이터 추출 |
| | `skill-creator` | **핵심**: 새 스킬 생성, 테스트, 평가 도구 |
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

이 스킬들은 [anthropic/skills](https://github.com/anthropics/anthropic-quickstarts/tree/main/computer-use-demo/skills)와 [antigravity-awesome-skills](https://github.com/antigravity-ai/awesome-skills)에서 엄선하여 통합되었습니다.

## Hooks


### check-freeze.sh (PreToolUse: Edit, Write)

`profiling/results/`와 `simulation/results/` 내 파일 편집을 **자동 차단**합니다.
실험 결과의 재현성을 보장합니다.

### check-careful.sh (PreToolUse: Bash)

위험한 명령을 감지하고 확인을 요청합니다:

| 패턴 | 동작 |
|------|------|
| `rm -r` / `rm -rf` | 확인 요청 (캐시/빌드/`.venv`/`.tox` 삭제는 예외) |
| `git reset --hard` | 확인 요청 |
| `git push -f` / `--force` | 확인 요청 |
| `kill -9` | 확인 요청 |
| `DROP TABLE` / `DROP DATABASE` | 확인 요청 |
| `git clean -f` | 확인 요청 |
| `git checkout .` / `git restore .` | 확인 요청 |
| `docker system prune` / `docker rm -f` | 확인 요청 |

### pre-read-guard.sh (PreToolUse: Read)

파일 중복 읽기를 감지하여 경고합니다. 세션 내에서 이미 읽은 파일에 대해 반복적인 도구 호출을 줄여 **토큰을 최적화**합니다.

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
스킬 추가 후에는 `/sync-docs`를 실행하여 README, GUIDE.md 등의 문서를 자동으로 갱신하세요.

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
- [oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent) — 크로스 툴 AI 에이전트 프레임워크
- [gstack](https://github.com/garrytan/gstack) — Claude Code 기반 풀스택 에이전트

---

## License

MIT
