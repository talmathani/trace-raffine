# TRACÉ RAFFINÉ Five-Step Project Completion Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the agreed five-step stabilization workflow for the designer/customer app, admin web app, and their Appwrite integration without losing local work or guessing.

**Architecture:** Keep `D:\TR` (designer/customer Android+iOS app) separate from `D:\TR_ADMIN` (admin web app). Treat Appwrite project `trace-raffine` and database `tr_database` as shared backend resources only where actual source configuration proves they are shared. Use focused tests and live evidence at each boundary.

**Tech Stack:** Flutter/Dart, Python Appwrite Functions, Appwrite TablesDB/Storage, PowerShell, GitHub, Linear, Notion, Figma, Ansight, Amplitude, Superpowers.

**Spec:** `docs/decisions/PROJECT_OPERATING_DECISIONS.md`

## Global Constraints
- No guessing: inspect the current source/configuration and logs before changes.
- Never mix `D:\TR` and `D:\TR_ADMIN` during inspection, build, or deployment.
- Preserve existing local modifications and untracked files; do not reset, clean, commit, or push the full working tree without a reviewed change set.
- Do not change Appwrite project ID, endpoint, schemas, permissions, or data without direct evidence and a reviewed migration/rollback plan.
- Do not update dependencies unless compatibility and required code changes are established.
- Follow luxury Editorial / High-Fashion identity; avoid generic traditional Material Design patterns.
- Tests and live verification are separate gates. A successful build/analyzer/unit test does not prove end-to-end behavior.
- Update Notion, Linear, and `docs/operations/PROJECT_STATUS.md` at meaningful checkpoints.

## Task 1 — Baseline and configuration evidence
- [x] Confirm app paths and project/repository identities.
- [x] Confirm Appwrite project, database, active function deployment path, storage bucket, admin site, and latest deployments.
- [x] Record current `git status`; preserve the existing dirty working tree.
- [x] Document the agreed operating rules and tool/component responsibilities.
- [ ] Before implementation work, re-check only files and state relevant to the selected issue.

**Exit criteria:** The active source/configuration path and resource IDs are evidenced; no unknown is filled by guesswork.

## Task 2 — Review designer lists
- [ ] Inspect designer shell navigation, list screens, routes, providers, repositories, and tests from the current working tree.
- [ ] Build an item-by-item decision list: keep / modify / remove, with source references and dependent routes/actions.
- [ ] Write/adjust focused regression tests before changing behavior.
- [ ] Implement only the approved/clearly supported list changes and run targeted tests, analyzer, and relevant build.
- [ ] Record all remaining uncertainty rather than deleting an item based on its label alone.

**Exit criteria:** Every changed item has a rationale, dependency check, and test evidence; no unrelated list is changed.

## Task 3 — Review customer lists independently
- [ ] Inspect customer navigation/list screens and their data contracts separately from designer/admin UI.
- [ ] Map each list item to route, query/provider, action, and test.
- [ ] Classify keep / modify / remove, implement the smallest justified changes, and test.
- [ ] Verify no designer/admin route or role behavior was changed accidentally.

**Exit criteria:** Customer list decisions and tests are recorded independently.

## Task 4 — Verify cross-app/backend flows
- [ ] Trace authenticated identity, roles, permissions, records, and storage across `D:\TR`, `D:\TR_ADMIN`, and Appwrite.
- [ ] Test message flow with authenticated accounts: designer sends, admin receives/replies, designer receives/marks read.
- [ ] Test design review flow: submission reaches admin, decision/comment persists, designer status and notification refresh correctly.
- [ ] Verify reload/reopen behavior and authorization boundaries; do not fabricate an authenticated user header to simulate a real session.
- [ ] Use Ansight only when an exact connected session exists. If no session or SDK integration is available, record the specific blocker and use the strongest safe alternative.

**Exit criteria:** Each flow has reproducible evidence from UI/API/database where applicable, with identity and permission checks; any unavailable live test is explicitly marked blocked.

## Task 5 — Real verification and release readiness
- [ ] Run focused Python backend tests and relevant Flutter tests/analyzer.
- [ ] Build the correct target from the correct root: mobile APK from `D:\TR`, admin web from `D:\TR_ADMIN`.
- [ ] Review diffs and ensure no secret, backup, generated artifact, or unrelated change is included in the release set.
- [ ] Verify deployment status and perform post-deployment smoke checks.
- [ ] Test on a real Android/iOS device when available; never equate APK build success with device verification.
- [ ] Record exact commands, exit codes, passed/failed tests, limitations, and next three actions in Notion and Linear.

**Exit criteria:** All required checks have explicit results; unresolved live/device tests remain open and are not described as complete.

## Current baseline and next action
- Appwrite project `trace-raffine` is active; `tr_database` is ready; `design-files`, `create-order`, `admin-user-control`, and `tr-admin` are present.
- Latest visible `create-order` deployment: `6acbf4193832a1e0dc07`, state `ready`.
- Backend suite most recently run: 13/13 passed. `git diff --check` exit code 0 (line-ending warnings only).
- The local tree contains many unrelated modifications; no commit/push was performed.
- The real message/review E2E flow remains unverified. Linear issue: `TRA-7`.
- Next action: execute Task 4 with authenticated UI sessions; current Ansight host is stopped, app list is empty, and connected sessions count is zero. Do not install SDK or optional tooling without proving it is needed.
