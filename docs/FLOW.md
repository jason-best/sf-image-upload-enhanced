# Flow configuration

Add **Image Upload Enhanced** to a Screen Flow screen. Configure inputs on the component; map or store outputs for later steps.

## Component names

| Install method | Name in Flow Builder |
|----------------|----------------------|
| Unlocked package (`ImageUploadEnhanced`) | `three_levers__imageUploadEnhanced` |
| Deploy from source (namespaced scratch) | `imageUploadEnhanced` |
| Unpackaged (`c:` namespace) | `c:imageUploadEnhanced` |

## Inputs

| Property | Type | Required | Notes |
|----------|------|----------|-------|
| `displayLabel` | String | Yes | Card title (default: "Image Upload") |
| `targetWidth` | Integer | Yes | Max width in pixels for `processImage` |
| `targetHeight` | Integer | Yes | Max height in pixels |
| `previewWidth` | Integer | Yes | Preview image width in the UI |
| `previewHeight` | Integer | Yes | Preview image height in the UI |
| `compressionQuality` | Integer | Yes | Passed to `processImage` as 0–1 quality; use `1` for maximum quality in Flow |
| `preserveTransparency` | Boolean | No | `true` → PNG output; `false` → JPEG |
| `backgroundColor` | String | No | Fill when flattening transparency (default `white`) |
| `previewMessage` | String | No | Rich text above the preview |
| `preserveAspectRatio` | Boolean | No | `object-fit: contain` on preview when true |

## Outputs

Store automatically on the screen element, or assign to Flow variables:

| Property | Description |
|----------|-------------|
| `imageData64` | Base64 body without `data:image/...;base64,` prefix |
| `fileName` | Original upload file name |
| `fileExtension` | `.jpg` or `.png` |
| `fileSize` | Processed size in bytes |
| `error` | Error message when processing fails |
| `imageData` | Blob URL for preview (internal; usually not needed in Flow) |

## Persist to ContentVersion

### Option A — Flow invocable (recommended)

Add action **Save Content Version** (`CreateContentVersion`):

| Input | Map from |
|-------|----------|
| File Base64 | `{!imageData64}` |
| File Name | `{!fileName}` or `{!fileName}{!fileExtension}` |
| Parent Record Id | record Id (e.g. `{!$Record.Id}` or a Flow variable) |
| Owner Id | optional |

Outputs: Status, File Size, Content Version Id.

Packaged API name: **`three_levers.CreateContentVersion`**.

### Option B — Flow Create Records

After the screen step:

1. **Create Records** → Object: **ContentVersion**
2. Map fields:
   - **Title** ← `{!fileName}` (or a formula without extension)
   - **PathOnClient** ← formula `{!fileName}{!fileExtension}`
   - **VersionData** ← `{!imageData64}` (base64; Flow handles encoding for this field)
3. Optional: **Create Records** on **ContentDocumentLink** to attach the file to a record.

Check `error` in a Decision if you need to branch on failed uploads.

## `reset()` API

The component exposes `@api reset()` to clear the file input and preview programmatically (e.g. from a parent Aura/LWC wrapper). Not exposed to Flow directly.

## Events

Fires `imageready` with `{ imageData64, fileName, fileExtension, fileSize, imageData }` for non-Flow embeds.
