# Image Upload Enhanced

Flow screen Lightning Web Component for **image pick, resize, compression, preview**, and **base64 output**, plus Apex **`CreateContentVersion`** to save files to Salesforce Files.

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE)
[![Salesforce API](https://img.shields.io/badge/Salesforce_API-65.0-00A1E0)](https://developer.salesforce.com)

---

## Features

- Screen Flow component with configurable label, dimensions, and preview size
- Client-side resize and compression via [`lightning/mediaUtils`](https://developer.salesforce.com/docs/component-library/bundle/lightning-media-utils) `processImage` (API 57+)
- Optional transparency (PNG) or JPEG with background color
- Outputs **base64** (`imageData64`), file name, extension, size, and error text for Flow
- Works on App, Record, Home, and Flow Screen targets
- Apex invocable **Save Content Version** (`CreateContentVersion`) — persist base64 to ContentVersion with parent + optional owner
- **Unlocked 2GP package** — install in any org; no Sites or Named Credentials required

---

## Quick start

1. **Install** the unlocked package ([Install](#install-package)) or [deploy from source](docs/INSTALL.md).
2. Open a **Screen Flow** and add **Image Upload Enhanced** to a screen.
3. Set inputs (width, height, compression, preview size). Store outputs automatically or map to variables.
4. After the screen, add Flow action **Save Content Version** (or Create Records on ContentVersion) with `imageData64` and `fileName`.

See [Flow configuration](docs/FLOW.md) for property reference and persistence options.

---

## Install package

**Version `0.2.0-1` (released)** · Subscriber version Id `04tgL000000Rn4fQAC`

| Org | URL |
|-----|-----|
| Production | https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000Rn4fQAC |
| Sandbox | https://test.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000Rn4fQAC |

```bash
sf package install --package 04tgL000000Rn4fQAC --target-org <alias>
```

After install:
- Flow component: **`three_levers__imageUploadEnhanced`**
- Apex / Flow action: **`three_levers.CreateContentVersion`** (**Save Content Version**)

**Deploy from source:** [docs/INSTALL.md](docs/INSTALL.md)

---

## Flow outputs

| Output | Description |
|--------|-------------|
| `imageData64` | Base64-encoded image body (no data-URL prefix) |
| `fileName` | Original file name from the upload |
| `fileExtension` | `.jpg` or `.png` depending on transparency setting |
| `fileSize` | Processed blob size in bytes |
| `error` | User-facing error message, if any |

---

## Apex: CreateContentVersion

Flow action **Save Content Version**:

| Input | Required |
|-------|----------|
| File Base64 | Yes |
| File Name | Yes |
| Parent Record Id | Yes |
| Owner Id | No (defaults to running user) |

Outputs: Status, File Size, Content Version Id. See [docs/FLOW.md](docs/FLOW.md).

---

## Requirements

- Salesforce **API 57.0+** (for `lightning/mediaUtils`)
- Screen Flow (or Lightning page targets)
- No Sites or Named Credentials; assign Apex access if using `CreateContentVersion` from Flow/LWC

---

## Development

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias image-upload-scratch --set-default
sf project deploy start --manifest manifest/package.xml --target-org image-upload-scratch
```

Packaging and 2GP releases are maintained in the private [ThreeLeversDevOrg](https://github.com/jason-best/ThreeLeversDevOrg) monorepo. Source and docs: [jason-best/sf-image-upload-enhanced](https://github.com/jason-best/sf-image-upload-enhanced). See [docs/PACKAGING.md](docs/PACKAGING.md).

---

## License

[BSD 3-Clause](LICENSE) · Copyright Three Levers

---

## Support

Questions or consulting: [threelevers.com/contact](https://threelevers.com/contact/)
