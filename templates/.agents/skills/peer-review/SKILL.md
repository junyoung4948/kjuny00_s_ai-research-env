---
name: peer-review
description: Gets a peer review of your drafted response from Claude Sonnet via the `claude` CLI before delivering the final response to the user. Trigger this skill when tackling complex architectural problems, when the user explicitly requests "cross-review", "peer review", "상호 리뷰", or when you want a second LLM's perspective to prevent logical flaws.
---

# Cross-Model Peer Review Workflow (Antigravity -> Claude)

When you need to perform a cross-model review, follow this strict workflow before providing your final answer to the user.

## 1. Draft Your Initial Response
First, formulate your best answer to the user's request internally. Do not output this to the user yet. Write your draft to a scratch file, e.g., `/tmp/antigravity_draft.md`.

## 2. Prepare the Review Prompt
Create a prompt for Claude. The prompt must include:
- Context: "I am Antigravity (Gemini), an AI agent working on a request, and I need you to review my drafted response."
- The original user request.
- Reference files: Provide the absolute paths and relevant contents (or summaries) of any files the user referenced, so Claude has the full context.
- Your initial draft.
- Clear instructions on what to review (e.g., "Check for logical flaws, missing implementation details, or better architectural patterns").

Write this prompt to a temporary file, for example, `/tmp/review_request_for_claude.txt`.

## 3. Invoke Claude CLI
Invoke the Claude CLI in non-interactive mode using the Sonnet model. Read the prompt from the file and pass it to Claude using the `-p` flag:

```bash
claude -p "$(cat /tmp/review_request_for_claude.txt)" --model sonnet
```

Execute this command using your terminal execution tool. Wait for the tool to complete and return the output. Verify the exit code is 0, and read the stdout to get Claude's review. If your command execution tool runs asynchronously, use your command status tool to monitor it until completion.

## 4. Synthesize and Deliver Final Answer
Read Claude's feedback. Integrate valid points, corrections, or improvements into your initial draft. If you disagree with a suggestion, briefly note why but prioritize the user's original intent.

Deliver the final answer to the user. Include a short section at the end titled **[Peer Review Insights]** explaining what Claude suggested and how it improved the final result.
