---
name: lootswap-development
description: "Development skill for the LOOTSWAP Flutter game-item trading application. Use when building, modifying, debugging, testing, or extending LOOTSWAP features, including Flutter UI, Firebase Authentication, Cloud Firestore, game-item listings, trades, navigation, profiles, messaging, and related application functionality."
---

# LOOTSWAP Development

## Purpose

Use this skill to make focused, project-aware changes to LOOTSWAP, an early-stage Flutter application for online game-item trading. Its core concept is "Don't Need It? Swap It!": players can discover items, list items for trade, find potential trades, communicate, and manage accounts.

The requested feature areas describe the product's intended scope; do not assume every workflow or backend capability already exists. Confirm current behavior in the code before extending it.

## Project Context

The project currently uses Flutter and Dart, Flutter Material UI, Firebase Core, Firebase Authentication, Cloud Firestore, HTTP, Google Fonts, Flutter Lints, and `flutter_test`. Check `pubspec.yaml` before relying on a package or proposing a dependency.

The main application code is under `lib/`; the project also has `api/`, `assets/`, and `test/`. Inspect the relevant files and current tests for the task rather than assuming a fixed architecture or data model.

## Procedure

1. **Clarify the behavior.** Identify the requested user-visible outcome and any constraints. Separate confirmed current behavior from intended or proposed behavior. Ask a concise question if a missing product decision would materially change the implementation.
2. **Trace the owning code.** Search for the relevant screen, service, model, route, Firebase call, or test. Read the controlling implementation and a nearby call site or test. Treat existing code and data as authoritative.
3. **Choose a narrow change.** State a brief hypothesis about the behavior or failure and a focused check that could disconfirm it. Prefer the smallest root-cause fix that matches the current patterns.
4. **Preserve project boundaries.** Do not introduce a framework, state-management or routing package, major dependency, broad refactor, or unrelated cleanup unless explicitly requested or clearly necessary. Check existing Flutter, Dart, and Firebase capabilities before proposing a dependency. Do not invent Firestore collections, document fields, security assumptions, or API contracts; derive them from the repository or clarify requirements.
5. **Validate the touched behavior.** Run the most focused available test first. For broader Dart changes, use `flutter analyze`; run `flutter test` when relevant. For dependency or platform changes, choose an appropriate additional check. Report commands that could not run and distinguish pre-existing failures from regressions.
6. **Close the loop.** Summarize the behavior changed, the key files touched, validation results, and any remaining assumptions or follow-up decisions.

## Quality Checks

- Keep UI consistent with the existing Material patterns and usable across supported screen sizes.
- Handle Firebase authentication and Firestore loading, empty, success, and error states where they apply.
- Preserve existing navigation and user data behavior unless the request explicitly changes it.
- Add or update focused tests for changed behavior when the current test setup allows it.
- Avoid claiming a workflow is complete when its backend rules, data contract, or communication path is not implemented or verified.
