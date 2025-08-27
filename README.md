# SOPHOS_TAMPER_PROTECTION_RECOVER
This tool was created for fun! And can help u to recover tamper protection Sophos and to uninstall Sophos later recover the tamper protection.

# 🔒 Sophos Tamper Protection Disabler (Offline + GUI Batch Script)

This repository contains a full-featured **Batch Script** to safely disable **Sophos Endpoint Tamper Protection** on Windows systems where administrative control of Sophos Central is no longer possible.

🛠 Ideal for system recovery, post-incident analysis, or when cleaning orphaned Sophos agents that can't be removed via standard procedures.

---

## 🧰 Requirements

- ⚠️ Must be run **as Administrator**
- Requires prior manual **renaming of the driver `SophosED.sys`** from **Windows Recovery Environment (WinRE)** or **Live USB**

---

## 📝 Usage

### 1. Rename Driver from Recovery Mode

1. Boot into Recovery Environment:
   - **Settings > System > Recovery > Advanced Startup > Restart Now**
2. Choose:
   - Troubleshoot → Advanced Options → **Command Prompt**
3. Identify Windows drive:

```cmd
diskpart
list volume
exit
