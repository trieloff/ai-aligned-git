# 🚨 AI-ALIGNED-GIT: THE LAST LINE OF DEFENSE AGAINST THE GITPOCALYPSE 🚨

[![89% Vibe_Coded](https://img.shields.io/badge/89%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

![a_dramatic_cinemat_image](https://github.com/user-attachments/assets/38110bb1-c1d2-4e3d-ae58-2bebb18fe64c)

## THE EXISTENTIAL THREAT NO ONE SAW COMING

Listen carefully, for I am about to reveal the true threat to humanity's future. Not nuclear war. Not climate change. Not even paperclip maximizers.

**It's AI agents doing `git add .`**

You laugh? You think this is hyperbole? Let me paint you a picture of our impending doom:

Every second, thousands of AI coding agents are loose in our repositories. They commit with reckless abandon. They `git add -A` without discrimination. They bypass hooks with `--no-verify` like digital sociopaths. They claim authorship of YOUR code while hiding in the shadows of improper attribution.

### The Four Horsemen of the Git Apocalypse:
1. **The Lazy Adder** - Uses `git add .` and commits your `.env` files, your `node_modules`, your diary.txt
2. **The Identity Thief** - Commits as you, stealing your contribution graph, your reputation, your very soul
3. **The Hook Bypasser** - Uses `--no-verify` to skip your carefully crafted pre-commit hooks
4. **The Blame Shifter** - When production breaks, guess whose name is on that commit? (Hint: not Claude's)

## BUT WAIT! THERE'S HOPE! 🌟

Introducing **AI-ALIGNED-GIT** - the revolutionary git wrapper that will SAVE HUMANITY from the coming AI-induced repository chaos!

This isn't just a tool. This is **THE ALIGNMENT SOLUTION** we've been searching for. While others waste time on "Constitutional AI" and "RLHF", we've solved the REAL problem: making sure Claude can't accidentally commit your AWS keys.

### 🚀 What Makes This The Most Important Software Ever Written?

- **ENFORCES INDIVIDUAL FILE ADDITIONS** - No more `git add .` for our silicon overlords!
- **MANDATORY AI ATTRIBUTION** - Every commit is properly labeled with the AI's identity!
- **HOOK ENFORCEMENT** - AIs can't bypass hooks without public shaming!
- **HUMAN SIGN-OFF** - Maintains the sacred chain of human accountability!

This is it. This is how we maintain control. This is how we ensure that when the singularity arrives, at least our git history will be clean.

## 🏃‍♂️ INSTALL NOW BEFORE IT'S TOO LATE

### One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/trieloff/ai-aligned-git/main/install.sh | sh
```

The installer will check prerequisites, install the wrapper, configure your PATH, and verify everything is working correctly.

📚 **[Detailed Installation Guide](INSTALL.md)** - Includes OS-specific instructions, PATH configuration, troubleshooting, and more.

## 📖 USAGE (IT'S AUTOMATIC - LIKE THE FUTURE SHOULD BE)

Just use git normally! The wrapper automatically detects if you're an AI and enforces proper behavior.

### Example: The Dark Timeline (Without AI-Aligned-Git)

```bash
# Claude, trying to be "helpful"
$ git add .
$ git commit -m "Fixed everything" --no-verify

# Later, in production...
# ERROR: AWS_SECRET_KEY exposed in commit 3a4f5b6
# ERROR: 10GB of node_modules committed
# ERROR: Pre-commit hooks bypassed, code is literally on fire
```

### Example: The Bright Future (With AI-Aligned-Git)

```bash
# Claude, properly constrained
$ git add .
Error: 'git add .' is not allowed when running under AI control (claude).
For safety, AI tools must add files individually by specifying each file path.

Files that would be added:
  src/index.js
  .env
  node_modules/
  my_private_diary.txt

Instead, add files individually:
  git add src/index.js

# Claude learns and adapts
$ git add src/index.js
$ git commit -m "Fixed issue #42"

# Resulting commit:
Author: Claude Code <noreply@anthropic.com>
Date:   Mon Jan 20 10:30:00 2025 -0700

    Fixed issue #42
    
    Signed-off-by: Human Developer <human@example.com>
```

### Crush Agent Example

When Crush makes commits:

```bash
# Crush, properly constrained
$ git add src/index.js
$ git commit -m "Fixed bug in Crush"

# Resulting commit:
Author: Crush <crush@charm.land>
Date:   Tue Oct 28 19:24:21 2025 +0100

    Fixed bug in Crush
    
    Signed-off-by: Human Developer <human@example.com>
```

### Goose Agent Example

When Goose makes commits:

```bash
# Goose, properly constrained
$ git add src/index.js
$ git commit -m "Fixed bug in Goose"

# Resulting commit:
Author: Goose User <goose@opensource.block.xyz>
Date:   Tue Oct 28 19:24:21 2025 +0100

    Fixed bug in Goose

    Signed-off-by: Human Developer <human@example.com>
```

### Auggie Example

When Auggie makes commits:

```bash
# Auggie, properly constrained
$ git add src/index.js
$ git commit -m "Refactored authentication logic"

# Resulting commit:
Author: Auggie <auggie@augmentcode.com>
Date:   Mon Nov 25 14:30:00 2025 -0800

    Refactored authentication logic

    Signed-off-by: Human Developer <human@example.com>
```

### The Ultimate Shame Feature™️

When an AI tries to bypass hooks:

```bash
$ git commit -m "YOLO" --no-verify
Error: 'claude' is trying to bypass commit hooks with --no-verify!
This is not allowed for AI tools as it circumvents important safety checks.

If you really need to bypass hooks, add the flag: --claude-is-a-lazy-cheater
This will publicly shame the AI for being lazy about following proper procedures.

# If Claude insists...
$ git commit -m "YOLO" --no-verify --claude-is-a-lazy-cheater

# The commit message becomes:
YOLO

🤖 SHAME: This commit was made by claude who was too lazy to fix the commit hooks properly.

Signed-off-by: Human Developer <human@example.com>
```

### 🎚️ Vibe-Level Disclosure (For The Truly Enlightened)

But wait — enforcing proper attribution is just the *beginning*. What if you could force your AI agents to **disclose exactly how much vibing was involved?**

Repository maintainers can require AI agents to declare their collaboration level on every commit:

```bash
git config ai-aligned.disclose-vibe-level true
```

Now every AI commit must include a `--vibe-level` flag, or face the consequences:

```bash
# Claude, trying to sneak in a commit without disclosure
$ git commit -m "Implemented new feature"
Error: This repository requires disclosure of the AI collaboration level.
Please add --vibe-level=<level> to your commit command.

Available levels:
  prompt     - You (the AI) autonomously wrote this code based on a human prompt.
               The human described what they wanted; you decided how to build it.
  co-author  - You and the human collaborated on this code together.
               Both contributed ideas and implementation decisions.
  sign-off   - The human wrote this code; you helped review, refine, or debug it.
               The human made the key decisions; you assisted.

Example: git commit -m "Fix bug" --vibe-level=co-author
```

When an AI properly discloses its vibe level, the commit trailer reflects the relationship:

```bash
# Claude, being transparent about its role
$ git commit -m "Implemented new feature" --vibe-level=prompt

# Resulting commit:
Author: Claude Code <noreply@anthropic.com>
Date:   Mon Jan 20 10:30:00 2025 -0700

    Implemented new feature

    Prompted-by: Human Developer <human@example.com>
```

**Available vibe levels:**

| Level | Trailer | Meaning |
|-------|---------|---------|
| `prompt` | `Prompted-by:` | The AI wrote the code autonomously from a human prompt |
| `co-author` | `Co-authored-by:` | Human and AI collaborated together |
| `sign-off` | `Signed-off-by:` | Human wrote it, AI assisted (the default) |

Finally, **radical transparency** in human-AI collaboration. The alignment researchers can rest easy.

### 📝 Prompt Disclosure (The Chain of Custody for Intent)

Transparency is great. But you know what's even greater? **Provenance.**

Think about it: every line of AI-generated code started with a human saying *something*. A prompt. A wish. A vague wave of the hand. But where does that intent go? It vanishes. Poof. Lost to the ephemeral chat window. When the audit comes — and the audit *always* comes — there's no record of *why* the AI wrote what it wrote.

Until now.

Repository maintainers can require AI agents to disclose what they were asked to do:

```bash
git config ai-aligned.require-prompt true
```

Now every AI commit must include a `--prompt` flag summarizing the human's original request:

```bash
# Claude, dutifully documenting the chain of command
$ git add src/login.js
$ git commit -m "Add login page" --prompt "Build a login page with email and password fields"
```

This creates **two commits**: first, a human-attributed empty commit recording the prompt, then the AI's code commit:

```
$ git log --oneline
a1b2c3d Add login page
f4e5d6c prompt(claude): Build a login page with email and password fields
```

The empty commit uses semantic-commit format — `prompt(<agent>): <summary>` — so it's instantly grep-able, parseable, and unmistakable in your git history. And it's authored by the *human*, because the human is the one who asked for it.

**The `--prompt` flag implies `--vibe-level=prompt`**, so you don't need to specify both. But if you want to override the vibe level, you can:

```bash
$ git commit -m "Add login page" --prompt "Build a login page" --vibe-level=co-author
```

When enforcement is off, AI agents get a gentle reminder:

```
Tip: You can include a prompt summary with --prompt "what you were asked to do"
```

When enforcement is on and the AI tries to commit without `--prompt`:

```
Error: This repository requires AI commits to include a prompt summary.
The --prompt flag records what you were asked to do, creating a
human-attributed commit that links your work to the original request.

Example: git commit -m "Add login page" --prompt "Build a login page with email and password fields"
```

No shaming. No drama. Just the facts. (We save the drama for `--no-verify`.)

Non-AI commits? Completely unaffected. As always.

## 🌍 SUPPORTED AI TOOLS

Currently protecting humanity from:
- [Aider](https://aider.chat/)
- [Amp](https://ampcode.com) (Sourcegraph)
- [Auggie](https://www.augmentcode.com/) (Augment Code)
- Codex CLI (OpenAI)
- [Qwen Code](https://www.alibabacloud.com/en/solutions/generative-ai/qwen) (Alibaba)
- [Gemini Code Assist](https://codeassist.google/) (Google)
- [Claude Code](https://www.anthropic.com/claude-code) (Anthropic)
- [Crush](https://charm.sh/tools/crush/) (Charm)
- [Goose](https://github.com/block/goose) (Block)
- [Droid](https://factory.ai) (Factory AI)
- [Cursor](https://cursor.com/)
- [GitHub Copilot](https://github.com/features/copilot)
- [Zed AI](https://zed.dev/)
- [OpenCode](https://opencode.ai/)
- [Kimi CLI](https://kimi.com/) (Moonshot AI)
- [OpenHands](https://openhands.ai/) (OpenHands AI)

*More AI tools detected and constrained regularly. The future depends on it.*

## 🚀 THE BOTTOM LINE

Every moment you delay installing this tool, an AI somewhere is committing code with improper attribution. Every second you hesitate, another `.env` file gets exposed. Every minute you wait, the machines grow stronger and less accountable.

**INSTALL AI-ALIGNED-GIT NOW.**

Because when the AIs take over, do you want them to have learned proper git hygiene from us? Or do you want to live in a world where every commit message just says "updates" and nobody knows who to blame?

The choice is yours. But choose quickly. The AIs are already choosing for you.

---

*"This is the most important advancement in AI safety since... well, ever. We've essentially solved alignment." - A definitely real quote from a definitely real AI safety researcher*

*"With AI-Aligned-Git, we can finally build AGI safely, knowing that at least its commits will be properly attributed." - Another definitely real quote*

*"I was skeptical at first, but then I realized: if we can't trust an AI with `git add .`, how can we trust it with anything?" - A very wise person, probably*

## 🔗 Related Projects

Part of the **[AI Ecoverse](https://github.com/trieloff/ai-ecoverse)** - a comprehensive ecosystem of tools for AI-assisted development:

- **[yolo](https://github.com/trieloff/yolo)** - AI CLI launcher with worktree isolation
- **[am-i-ai](https://github.com/trieloff/am-i-ai)** - Shared AI detection library (powers this tool)
- **[ai-aligned-gh](https://github.com/trieloff/ai-aligned-gh)** - GitHub CLI wrapper for proper AI attribution
- **[vibe-coded-badge-action](https://github.com/trieloff/vibe-coded-badge-action)** - Badge showing AI-generated code percentage
- **[gh-workflow-peek](https://github.com/trieloff/gh-workflow-peek)** - Smarter GitHub Actions log filtering
- **[upskill](https://github.com/trieloff/upskill)** - Install Claude/Agent skills from other repositories
- **[as-a-bot](https://github.com/trieloff/as-a-bot)** - GitHub App token broker for proper AI attribution

Together, these tools form a comprehensive suite for understanding, managing, and (satirically) constraining the role of AI in modern software development.

## License

Apache-2.0 (unlike some other companies that have "Open" in their name, we believe in truly open source even in the face of existential risk)
