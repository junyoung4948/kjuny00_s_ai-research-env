# Open-Source References & Architecture Design

이 문서는 `ai-research-env` 아키텍처 설계의 뼈대가 된 3개의 핵심 오픈소스 프로젝트(`oh-my-openagent`, `gstack`, `superpowers`)를 심층 분석하고, 각 프로젝트의 아키텍처적 강점과 주요 철학이 현재 실험실 환경에 어떻게 이식(Mimic)되었는지 상세히 설명합니다.

---

## 1. oh-my-openagent (OmO)
**저장소**: [code-yeongyu/oh-my-openagent](https://github.com/code-yeongyu/oh-my-openagent)

### 📌 프로젝트 핵심 철학
"하나의 AI를 고르지 말고, 모두를 오케스트레이션하라"
다양한 오픈소스 LLM을 엮어 하나의 조직적인 가상 개발팀으로 구성하는 프레임워크입니다. 11개의 세부 에이전트를 역할별로 배치하고, 작업 카테고리에 최적의 모델을 자동 매칭하는 라우팅 최적화가 특징입니다.

### 💡 주요 아키텍처 및 강점
- **Intent Gate & Category System**: 모든 사용자 메시지를 'Intent Gate'가 먼저 분석해 진짜 의도를 파악하고, 작업 카테고리(`visual-engineering`, `ultrabrain`, `deep` 등)에 맞춰 최적의 모델과 에이전트를 매핑합니다.
- **Wisdom Accumulation (학습 누적)**: 서브 에이전트들의 stateless 한계를 극복하기 위해 `.sisyphus/notepads/` 아래에 `learnings.md`, `decisions.md` 등을 영구 누적 기록하여 컨텍스트를 보존합니다.
- **Metis (AI 슬롭 방지기)**: 과도한 추상화, 불필요한 기능 추가(Scope Inflation), 문서 비대화 등의 'AI 슬롭(Slop)'을 기획 단계에서부터 선제 차단합니다.

### 🚀 ai-research-env 적용 (Mimic)
- **크로스 툴 브릿지 패턴 (`AGENTS.md`)**: Claude Code와 Antigravity가 충돌 없이 협업할 수 있도록, 시스템 최상단에 `AGENTS.md`를 배치하여 공통 규약과 모델 간 흐름을 통제하는 기법을 도입했습니다.
- **Wisdom 누적 시스템**: 노트패드 시스템을 단순화하여 `.research/wisdom.md`와 `.research/decisions.md`로 차용했습니다. 세션 간 인사이트가 휘발되지 않고 강제 주입되도록 보존합니다.
- **카테고리 기반 작업 지시 (Scope Mode)**: 8개의 카테고리 시스템을 연구 환경에 맞춰 4단계 Scope Mode(`EXPLORATION`, `REFINEMENT`, `FOCUSED`, `WRITING`)로 축소하고 각 단계별로 에이전트의 강점 구간(Lead/Support)을 매핑했습니다.

---

## 2. gstack
**저장소**: [garrytan/gstack](https://github.com/garrytan/gstack)

### 📌 프로젝트 핵심 철학
"명확한 역할을 부여받은 AI 조직은 가장 완벽하고 끈질기게 소프트웨어를 산출해낸다."
CEO, 엔지니어링 매니저, 디자이너, QA 리드 등 전문화된 역할(Skill)들로 Sprint 사이클을 순차적으로 수행하게 하는 고강도 스킬셋 프로젝트입니다.

### 💡 주요 아키텍처 및 강점
- **역할 기반 분리 (Skill Personas)**: 업무를 수행하는 다양한 페르소나들(`/qa`, `/cso`, `/review` 등)을 스킬(SKILL.md)로 명확히 분리해 오케스트레이션합니다.
- **강력한 안전장치 (PreToolUse Hooks)**: `/careful`, `/freeze` 등을 통해 작업 영역을 디렉토리 단위로 가두고, 파괴적 명령어(`rm -rf` 등) 실행 직전에 확인을 거치도록 강제(Hook)합니다.
- **3-Strike Rule & WTF-Likelihood**: 3회 연속 실패 시 에스컬레이션을 강제하며, 작업이 난항에 빠질 때 상승하는 혼란도 수치(WTF-Likelihood)를 통해 무한 루프를 방지합니다.
- **Anti-Sycophancy (안티-아부)**: "좋은 접근입니다"와 같은 AI 특유의 빈말을 엄격히 금지하고, 무조건 명확한 입장과 반박 근거를 제시하도록 강요합니다.
- **Completion Status Protocol**: 완료 시 단순히 끝내지 않고 `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT` 상태를 명확히 출력하도록 지시합니다.

### 🚀 ai-research-env 적용 (Mimic)
- **Hard Gate (물리적 차단 툴링)**: gstack의 스킬 구조를 차용해 `.claude/skills/`를 통해 프롬프트 수준이 아닌 시스템 수준(`allowed-tools` 제한)에서 잘못된 도구 실행을 막는 Hard Gate를 도입했습니다.
- **안전 훅 통합**: `check-freeze.sh`, `check-careful.sh`를 적용해 실험 데이터(`profiling/results/` 등)를 격리하고 프로덕션 환경의 안전을 확보했습니다.
- **에스컬레이션 메커니즘 (3-Strike & Confusion Score)**: 실패 및 에러 로그 해결 시나리오(`/diagnose`)에서 무한 루프를 막고 일정 혼란 시 즉시 연구자에게 판단을 넘기는 프로토콜을 시스템 상에 심었습니다.
- **Anti-Sycophancy 및 Completion Status**: AI 간 피드백 품질을 높이기 위해 빈말 금지와 명확한 작업 결과 상태를 `AGENTS.md` 전역 룰로 채택했습니다.

---

## 3. superpowers
**저장소**: [obra/superpowers](https://github.com/obra/superpowers)

### 📌 프로젝트 핵심 철학
"추측하지 말고 증명하라. 성공을 선언하기 전 반드시 시스템이 요구하는 절차로 검증하라."
사람 수준의 강도 높은 Test-Driven Development (TDD) 와 격리된 워크플로우를 AI 에이전트에 이식하는 프레임워크입니다.

### 💡 주요 아키텍처 및 강점
- **Session Bootstrap Hooks**: 세션 시작 시 `using-superpowers`와 같은 코어 인스트럭션을 시스템 프롬프트에 자동 주입하여, 프레임워크가 강제로 켜지게 만듭니다.
- **Design Enforcement (HARD-GATE)**: 설계가 승인되기 전까지 구현 기술이나 코드를 일절 작성하지 못하게 막는 강력한 `<HARD-GATE>` 태그가 존재합니다.
- **Verification Gate Function**: 완료를 선언하기 전에 IDENTIFY → RUN → READ → VERIFY → CLAIM의 명문화된 강제 증명 절차를 필수적으로 거칩니다.
- **Rationalization Prevention**: "이 수정은 작아서 TDD가 필요 없다" 등 AI의 규칙 회피 논리를 사전 예측하고 반박하는 테이블을 가지고 있습니다.
- **Forced-Invocation Directive**: 작업을 진행하기 전 특정 스킬(워크플로우)을 필수적으로 Invoke하게 묶어둡니다.

### 🚀 ai-research-env 적용 (Mimic)
- **Verification Gate & 증거 우선주의**: 모델이 임의로 성공을 보고하는(Hallucinated success) 현상을 없애고자 완료 주장을 하기 전 반드시 실행 결과나 로그를 제시하도록 강제(`AGENTS.md`)했습니다.
- **Rationalization Prevention (우회 차단)**: `anti-slop.md`와 `rationalization-prevention.md` 규칙을 도입해 AI가 자신의 편의대로 연구 절차를 합리화하고 뛰어넘으려는 시도를 방어했습니다.
- **Forced-Invocation 및 CSO 적용**: 특정 작업 키워드(예: analyze, debug) 감지 시 해당 절차를 담은 스킬(`/analyze`, `/diagnose`) 강제 호출 규칙으로 발전시켰으며, 스킬 설명을 일관성 있게 구성하여 라우팅 성능을 향상시켰습니다.
- **서브 에이전트 교차 리뷰 영감**: 1회성 작업을 분해하고 독립된 단계적 검증(Spec Compliance → Code Quality)을 갖는 철학을 받아들여, Gemini와 Claude 간의 리뷰-반영 사이클 모델(Lead/Support 핸드오프)을 구축했습니다.
