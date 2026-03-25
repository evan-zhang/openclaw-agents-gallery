# OpenClaw Agents Gallery 🚀

A central hub for clonable, publishable, and continuously managed OpenClaw Agents. 
Developed under the **TPR-20260325-001 Protocol** (Smooth Migration & Privacy-First Cloning).

---

## 🏗️ Available Agents (The Gallery)

| Agent ID | Name | Role / Persona | Status | Link |
|---|---|---|---|---|
| `tpr-orchestrator` | TPR 智囊 (Orchestrator) | 项目编排、三省架构调度专家 | `v1.0-RC` | [View Folder](./tpr-orchestrator/) |

---

## ⚡ How to Clone & Install

Follow these steps to bring an Agent from this gallery into your own OpenClaw environment:

### 1. Clone this Gallery
```bash
git clone https://github.com/evan-zhang/openclaw-agents-gallery.git
```

### 2. Pick your Agent
Identify the subfolder of the Agent you want (e.g., `tpr-orchestrator`).

### 3. Add to your `openclaw.json`
Add a new Agent entry to your gateway config, pointing the `workspace` to the Agent's subfolder:
```json
{
  "id": "my-new-tpr-agent",
  "workspace": "/path/to/openclaw-agents-gallery/tpr-orchestrator",
  "model": { "primary": "your-model-here" }
}
```

### 4. Self-Activation
Restart your Gateway. Your new Agent will "wake up" and see a `BOOTSTRAP.md` file. It will automatically run the activation scripts to detect your local paths and complete the setup.

---

## 🛡️ Privacy & Security
All agents in this gallery have been processed using the **TPR Scrub Tool**.
- ✅ **No Private Data**: All `memory/` and `projects/` history have been physically deleted.
- ✅ **No Secrets**: All API keys and passwords have been replaced with `[REDACTED]`.
- ✅ **Environment Agnostic**: Absolute paths have been converted to environment placeholders.

---
*Maintained by Evan Zhang & the TPR Orchestrator.*
