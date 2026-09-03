# Installation

## Option A — Install unlocked package (recommended)

**Version:** `0.2.0-1` (released)  
**Subscriber package version Id:** `04tgL000000Rn4fQAC`

| Org type | Install URL |
|----------|-------------|
| Production | https://login.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000Rn4fQAC |
| Sandbox | https://test.salesforce.com/packaging/installPackage.apexp?p0=04tgL000000Rn4fQAC |

CLI:

```bash
sf package install --package 04tgL000000Rn4fQAC --target-org <alias>
```

No installation key. After install, use **`three_levers__imageUploadEnhanced`** in Flow Builder and Flow action **Save Content Version** (`three_levers.CreateContentVersion`).

## Option B — Deploy from source

### Namespaced scratch org (matches package)

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias image-upload-scratch --set-default
sf project deploy start --manifest manifest/package.xml --target-org image-upload-scratch
```

Component name in Flow: **`imageUploadEnhanced`** (scratch namespace) or **`three_levers__imageUploadEnhanced`** when installed from package.

### Unpackaged deploy (no namespace)

Remove or omit `"namespace"` in `sfdx-project.json`, then deploy to your dev org:

```bash
sf project deploy start --manifest manifest/package.xml --target-org <alias>
```

Component name in Flow: **`c:imageUploadEnhanced`**.

## Post-install

Nothing required beyond Flow access. No Sites, guest profiles, or Named Credentials.

To persist uploads in Flow, see [FLOW.md](FLOW.md) (ContentVersion example).

## Upgrade

Install a newer package version from the [README](../README.md#install-package) or redeploy from source. Unlocked packages allow subscriber customization of the LWC after install.
