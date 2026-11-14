# Plant Doctor Photo Prep Implementation Plan

> Use superpowers:executing-plans inline. User opts out of routine questions.

**Goal:** Build, verify and submit a local plant-photo preparation Spoon.
**Architecture:** One Lua module, native Hammerspoon image/file/menu APIs and native dialogs. Explicit three-file package plus generated docs.
**Tech Stack:** Lua, Hammerspoon1.1.1, Python standard library packaging, Apple ImageIO fixture verification.
**Spec:** ../specs/2026-11-14-photo-prep-design.md

## Global Constraints
No backend, external calls, originals modified, shell execution, third-party Spoons, or new security permissions. Moruk LLC / hi@moruk.co. Keep plantdoctor.app backlinks.

## Review Focus
Cancel and invalid input leave no new outputs. Existing output folders/files survive. Image orientation and metadata privacy must be verified on actual raster outputs. Batch failures must not claim success. Stop removes only the Spoon's own menu.

### Task 1
- [ ] Write failing Lua tests in tests/test.lua.
- [ ] Implement Source/PlantDoctorPhotoPrep.spoon/init.lua, README and license.
- [ ] Run Lua tests and native ImageIO end-to-end verification.
### Task 2
- [ ] Generate docs.json with native builder; build allowlisted deterministic ZIP.
- [ ] Create canonical MR, complete four read-only review slots and resolve findings.
- [ ] Publish exact tested release, submit one source-only Spoons PR, verify receipt and cleanup.
