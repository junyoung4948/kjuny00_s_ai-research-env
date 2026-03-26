# Handoff Protocol

Signal file system for asynchronous handoff between agents.

---

## Directory Structure

```
handoff/
├── queue/    # Pending signals (pending/processing)
├── done/     # Completed signals (archive)
└── README.md
```

## Signal File Format

**Filename**: `{YYYYMMDD-HHmmss}-{from}-to-{to}-{action}.json`

```json
{
  "id": "20260326-143052",
  "from": "claude",
  "to": "antigravity",
  "action": "review",
  "skill": "experiment-design",
  "artifact": ".research/plans/experiment-cache-draft.md",
  "context": "Request logical verification of experiment design",
  "requires_human": false,
  "status": "pending",
  "created_at": "2026-03-26T14:30:52+09:00"
}
```

### Field Descriptions

| Field | Description |
|-------|-------------|
| `id` | Timestamp-based unique ID |
| `from` / `to` | `"claude"` or `"antigravity"` |
| `action` | `"review"`, `"incorporate"`, `"validate"`, `"analyze"`, `"custom"` |
| `skill` | Skill context to apply (brainstorm, experiment-design, etc.) |
| `artifact` | File path of the target artifact |
| `context` | Request description (free text) |
| `requires_human` | If `true`, do not auto-process — request researcher confirmation |
| `status` | `"pending"` → `"processing"` → `"done"` / `"failed"` |

### Additional Fields on Completion/Failure

```json
{
  "result_artifact": ".research/plans/experiment-cache-review.md",
  "completed_at": "2026-03-26T14:35:10+09:00"
}
```

```json
{
  "failure_reason": "Artifact file not found",
  "failed_at": "2026-03-26T14:32:00+09:00"
}
```

## Signal Lifecycle

1. **Sender** creates signal in `queue/` (`status: "pending"`)
2. **Receiver** starts processing (`status: "processing"`)
3. On success → moved to `done/` (`status: "done"`)
4. On failure → remains in `queue/` (`status: "failed"`)

## Call Direction Mechanisms

| Direction | Mechanism |
|-----------|-----------|
| **Antigravity → Claude** | Direct call via `invoke-claude.sh` (signal is for audit trail) |
| **Claude → Antigravity** | Signal creation → user runs `/pickup` in Antigravity |

## `requires_human` Criteria

Set to `true` when the decision falls under "Taste" (AGENTS.md §8):
- Hypothesis selection, research direction changes
- Parameter value decisions
- Methodology trade-offs

---

*See AGENTS.md §5.1 for the full Auto-Handoff Protocol.*
