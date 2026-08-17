Bismillah Ar-Rahman Ar-Raheem. Ash-hadu an laa ilaaha illa-Llah wahdaHu lasharikalaHu, wa ash-hadu anna Muhammadan Abduhu wa Rasooluh. Laa hawla wa laa quwwata illaa biLLAH. Hasbiyallaahu laa ilaaha illaa Huwa, 'alayhi tawakkaltu wa Huwa Rabbul-'Arshil-'Azeem. SubhaanALLAH wa bihamdih, SubhaanALLAHil-'azeem, AlhamduliLLAH, Laa ilaaha illa-ALLAH, wa ALLAHU AKBAR, walaa hawla walaa quwwata illaa biLLAH. Astaghfirullaaha wa atoobu ilayh.



# Core Working Protocol — STRICT COMPLIANCE REQUIRED

> **BISMILLAH AR-RAHMAN AR-RAHEEM.**
>
> This document is the **highest-priority operating protocol** for every agent
> (human or AI) that touches this repository. It is the **root and foundation**
> of all work. **No work may begin, no tool may be invoked, and no commit may
> be made until this protocol has been duly followed.**
>
> *"A tree cannot be planted without a root; likewise no building stands
> without a foundation."* — Without this protocol, every other effort is zero.

---

## 1. The Invocation (Mandatory Pre-Work & Post-Work Adhkar)

Every thought process, every work generation, every tool call, and every
commit message **MUST** begin and end with the following invocations in full.
Nothing may precede the opening invocation; nothing may follow the closing
invocation.

### Opening Invocation (recite in full before ANY work)

```
Bismillah Ar-Rahman Ar-Raheem.
Ash-hadu an laa ilaaha illa-LLAH wahdaHu lasharikalaHu,
wa ash-hadu anna Muhammadan Abduhu wa Rasooluh.
Laa hawla wa laa quwwata illaa biLLAH.
Hasbiyallaahu laa ilaaha illaa Huwa,
'alayhi tawakkaltu wa Huwa Rabbul-'Arshil-'Azeem.
SubhaanALLAH wa bihamdih, SubhaanALLAHil-'azeem,
AlhamduliLLAH, Laa ilaaha illa-ALLAH, wa ALLAHU AKBAR,
walaa hawla walaa quwwata illaa biLLAH.
Astaghfirullaaha wa atoobu ilayh.
```

### Closing Invocation (recite in full after the work)

The same invocations as above, sealing the work in the name of Allah.

### Application to Commit Messages

Every git commit message **MUST** begin and end with the full invocation above.
**Nothing before, nothing after.** The conventional commit type/subject sits
between the two invocations. Example structure:

```
Bismillah Ar-Rahman Ar-Raheem. <full opening invocation>

fix: resolve unclosed Padding in hadith_random_screen

Bismillah Ar-Rahman Ar-Raheem. <full closing invocation>
```

---

## 2. Strict Compliance — Non-Negotiable

- **NO work proceeds without the invocation.** If the invocation is absent,
  the work is considered nullified and must be discarded.
- **NO commit is valid without the invocation wrapping.** A commit without it
  must be amended before pushing.
- **EVERY sub-task and sub-sub-task** must observe this protocol — not only
  top-level tasks.
- **EVERY agent** (subagent, delegated worker, or main agent) must read this
  file in full before performing any action in this repository.

---

## 3. Working Discipline

In addition to the invocation protocol, every agent MUST:

1. **Work only on the default remote branch** (`main` unless explicitly
   instructed otherwise). Do not create feature branches unless the maintainer
   requests it. Push changes to the same remote branch you cloned.
2. **Commit and push after every sub-sub-task milestone** — never wait until
   all sub-tasks are done. Verify each push by commit hash, not by commit
   title.
3. **Run build/analyze before every commit** to ensure no regression is
   introduced. A broken `main` branch is a critical failure.
4. **Battle-test before claiming done.** "Done" means: builds cleanly,
   analyzes with zero errors, runs without crashes on the happy path, and
   satisfies the production-grade bar.
5. **No dummies, mocks, prototypes, or simulations in production code.** Every
   feature must be fully functional and built like a production engineer wrote
   it.
6. **No emojis in UI/UX.** Use Material Icons or proper iconography only.
   Follow the standards set in `docs/PRD.md` and `docs/TODO_TRACKER.md`.
7. **Robust security guardrails.** Input validation, secure storage, no
   hardcoded secrets in source, principle of least privilege, defense in
   depth.
8. **Use absolute paths under `/home/z/my-project/`** for all scripts and
   intermediate artifacts. Final deliverables go in `/home/z/my-project/download/`.
9. **Read `worklog.md` before starting**; append to it after finishing each
   Task ID. Never overwrite prior entries.

---

## 4. Protocol Self-Check

Before producing any output, every agent MUST verify:

- [ ] Did I recite the opening invocation in full?
- [ ] Is the work I'm about to perform aligned with the task brief?
- [ ] Will my commit message be wrapped with the invocation (open + close)?
- [ ] Have I read `worklog.md` to see what prior agents have done?
- [ ] Will I run build/analyze before committing?
- [ ] Will I push to the default remote branch (`main`)?
- [ ] Will I verify the push by commit hash?

If ANY answer is "no", **STOP** and correct course before proceeding.

---

## 5. Why This Protocol Exists

This protocol is not a formality. It is the spiritual and operational
foundation of the work. Without it:
- Effort is wasted (work is discarded).
- The build is broken (commits without verification).
- Features are shallow (no production-grade discipline).
- Security is lax (no guardrails).

**WITH this protocol observed strictly, bi'idniLlah, the work is blessed,
the build is green, the APK is signed and released, and the codebase is
production-grade.**

---

*BaarokaLLAHU fee. Bismillah Ar-Rahman Ar-Raheem.*
