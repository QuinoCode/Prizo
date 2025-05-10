# Contribution Guidelines

## 🚀 Branch Workflow for Contributors
All PRs must target the `develop` branch. Follow these branch naming and usage rules:

### 1. Branch Types and Purposes

| Branch Type       | Naming Pattern            | When to Use                                                                 | Example                  |
|-------------------|---------------------------|-----------------------------------------------------------------------------|--------------------------|
| **Feature**       | `feature/descriptive-name`| Add new functionality (e.g., APIs, UI components).                          | `feature/user-dashboard` |
| **Enhancement**   | `enhancement/description` | Improve existing code (refactors, optimizations, non-bugfix changes).       | `enhancement/cache-speed`|
| **Bugfix**        | `bugfix/issue-description`| Fix unintended behavior (bugs, crashes, incorrect outputs).                 | `bugfix/login-timeout`   |

---

### 2. Creating a PR

1. **Branch from `develop`:**
   ```sh
   git checkout develop
   git pull origin develop
   git checkout -b type/your-change  # e.g., `feature/dark-mode`
   ```

2. **Commit messages:**
    - Use imperative tense ("Add", "Fix", "Optimize")
    - Explain _why_ in the body (optional but appreciated)
    ```sh
    Title: (UI): Add Dark mode toggle 
    Body: Found it useful to have an easy way to go from light mode to dark mode. 
    ```
3. **Open a PR:**
    - Target: **develop**
    - Title: [Type] Short description (e.g., [Feature] Dark mode toggle)
    - Description: Link issues, describe changes and mention impacts.
### 3. PR Approval Rules 
- ✅ Required: 1 maintainer approval

- ✅ Tests passing (CI must be green)

- ✅ No merge conflicts with develop

- 🚫 No direct pushes to develop/main
### 4. After Merging
- Your branch will be **squash-merged** into **develop** (1 commit per PR)
- Delete your branch post-merge (GitHub option)
