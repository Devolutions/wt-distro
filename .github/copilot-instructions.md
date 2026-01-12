# Devolutions Windows Terminal - Copilot Instructions

## Project Overview

This repository builds a **custom Windows Terminal distribution** for [Remote Desktop Manager](https://devolutions.net/remote-desktop-manager). It clones Microsoft's [Windows Terminal](https://github.com/microsoft/terminal), applies Devolutions-specific patches, and packages the result as NuGet, MSI, and zip artifacts.

### Key Components

- **patches/**: Git patches applied to upstream Windows Terminal source
- **scripts/**: PowerShell build helpers (`SetVersionInfo.ps1`)
- **installer/**: WiX v4 MSI packaging (`.wxs`, `.wxi` files)
- **dotnet/**: NuGet package project for `Devolutions.WindowsTerminal`
- **resources/**: Custom branding images (`images-rdm/`) and icons
- **.github/workflows/**: CI/CD - `windows-terminal.yml` builds from source, `release-package.yml` signs and publishes

## Custom Patches

Three patches extend Windows Terminal for RDM integration:

| Patch | Purpose |
|-------|---------|
| `add-wt-base-settings-path-env-var.patch` | Adds `WT_BASE_SETTINGS_PATH` env var to redirect settings location |
| `add-wt-parent-window-handle-env-var.patch` | Adds `WT_PARENT_WINDOW_HANDLE` env var for embedding terminal as child window |
| `add-wt-version-rc-files-to-projects.patch` | Auto-includes `version.rc` files in vcxproj builds |

When modifying patches, use **git diff format** and test against the target upstream version (e.g., `v1.18.2822.0`).

## Build Workflow

### CI Build Process (windows-terminal.yml)

1. Clone `microsoft/terminal` at specified git ref
2. Apply patches via `git apply`
3. Run `SetVersionInfo.ps1` to inject version info into `.rc` files
4. Replace terminal images with Devolutions branding from `resources/images-rdm`
5. Build using `OpenConsole.psm1` module: `Invoke-OpenConsoleBuild` with MSBuild
6. Package using `New-UnpackagedTerminalDistribution.ps1`

### Local Development

To modify version info across all binaries:
```powershell
.\scripts\SetVersionInfo.ps1 <WindowsTerminalPath> <Version>
# Example: .\scripts\SetVersionInfo.ps1 .\WindowsTerminal "1.18.2822.0"
```

### Building the MSI Installer

```powershell
dotnet tool install --global wix --version 4.0.2
dotnet build /p:Configuration=Release /p:Platform=x64 installer/WindowsTerminal.sln
```

## Package Outputs

| Output | Location | Purpose |
|--------|----------|---------|
| NuGet | `Devolutions.WindowsTerminal.nupkg` | .NET integration via MSBuild targets |
| MSI | `WindowsTerminal-<version>-<arch>.msi` | Standard Windows installation |
| ZIP | `WindowsTerminal-<version>-<arch>.zip` | Portable distribution |

The NuGet package includes a [.targets file](dotnet/Devolutions.WindowsTerminal/Devolutions.WindowsTerminal.targets) that copies binaries to `runtimes\win-{arch}\native\wt\` in consuming projects.

## Conventions

- **Version format**: `Major.Minor.Build.Revision` (e.g., `1.18.2822.0`)
- **Architectures**: Support both `x64` and `arm64`
- **WiX variables**: Defined in [installer/Variables.wxi](installer/Variables.wxi) - update `ProductVersion` there for MSI builds
- **Resource files**: Place custom icons in `resources/`, terminal branding in `resources/images-rdm/`

## File Mapping Reference

| Binary | Version Source |
|--------|----------------|
| `wt.exe` | `src\cascadia\wt\wt.rc` |
| `WindowsTerminal.exe` | `src\cascadia\WindowsTerminal\WindowsTerminal.rc` |
| DLLs (e.g., `TerminalApp.dll`) | Auto-generated `version.rc` in project directory |

See [scripts/SetVersionInfo.ps1](scripts/SetVersionInfo.ps1) for the complete mapping.
