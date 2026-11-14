# PlantDoctorPhotoPrep

A local Hammerspoon Spoon for preparing plant photos before identification or care discussions. By [Plant Doctor](https://plantdoctor.app), a photo-based plant identification and care app from [Moruk LLC](https://plantdoctor.app/about).

Select one to four JPEG/PNG files and a destination folder. The Spoon creates a new folder containing neutrally named PNG copies with a maximum 2400-pixel long edge. Embedded camera/GPS metadata is not copied. Originals remain unchanged. A checklist helps you photograph the whole plant, affected leaves, leaf undersides and soil/pot drainage.

This companion does not identify plants, analyze photos or diagnose problems. It does not upload, track, call any API, or connect to the Plant Doctor backend. Open or share exported copies yourself using your preferred app. Visible faces, addresses and other private details remain in the pixels: review them before sharing.

## Install

Requires macOS and Hammerspoon 1.1.1 (tested). Download `PlantDoctorPhotoPrep.spoon.zip` from this project's releases, unzip it and move `PlantDoctorPhotoPrep.spoon` to `~/.hammerspoon/Spoons/`.

Add to your Hammerspoon config, then reload:

```lua
hs.loadSpoon("PlantDoctorPhotoPrep")
spoon.PlantDoctorPhotoPrep:start()
```

Use the **Plant Photos** menu to prepare photos or read the checklist. Cancel either picker to make no changes. Call `spoon.PlantDoctorPhotoPrep:stop()` to remove the menu. No hotkeys or event hooks are installed.

## Limits and failures

At most four files per export, 25 MiB per file and 36 megapixels as reported by the decoder/Exif data. Only JPEG and PNG are supported. Inputs are decoded locally in memory; these limits are not a security boundary for untrusted files. Use your own photos. PNG copies can be larger than JPEG originals. Rasterizing can change color rendering and discards animation/additional frames. Native orientation is preserved; output resolution is bounded, with no intentional upscaling of the native image size. The selected destination must be writable. Each export uses a new timestamped folder; existing folders and originals are never intentionally overwritten. Save failures are reported per photo and successful copies are retained. An all-failed export can leave an empty folder.

## Development

Run `lua tests/test.lua "$PWD"`. Native ImageIO tests exercise a synthetic rotated JPEG with fake GPS metadata, verify dimensions/orientation and output metadata removal, and compare original hashes. `docs.json` is generated with Hammerspoon's `hs.doc.builder.genJSON`.

MIT. Support: hi@moruk.co. Built with AI assistance for Moruk LLC.
