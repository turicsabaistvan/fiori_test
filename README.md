# Fiori Trial Subaccount Lifecycle – E2E Test Suite

End-to-end test automation for the SAP Fiori trial subaccount lifecycle.
The same user journey is implemented in three independent stacks:

| Stack | Language / Framework | Location |
|-------|----------------------|----------|
| Robot Framework + Browser (Playwright) | Python / Robot | `robot-tests/` |
| Playwright Test | TypeScript | `playwright-test/` |
| pytest + Playwright | Python | `python-tests/` |

All three stacks follow the Page Object Model (POM) and share the same
logical steps:

1. Login with a negative empty-password check
2. Cookie banner handling
3. Conditional deletion of the `Tester` subaccount
4. Subaccount creation with region selection
5. Long-text edit / save
6. Restore default values

A code review of the initial state is available in `REVIEW.md`.

> **Security notice**
>
> Credentials are read from environment variables only. An earlier revision
> of this repository contained a hard-coded Fiori credential in
> `robot-tests/resources/data/credentials.resource`. The file has been removed,
> but it is still present in the Git history. Treat that password as
> compromised: rotate it, and purge the history with `git filter-repo` or
> BFG before publishing the repository.

---

## Table of contents

- [Repository layout](#repository-layout)
- [Installation and setup](#installation-and-setup)
  - [Prerequisites](#prerequisites)
  - [Linux](#linux)
  - [Windows](#windows)
  - [Common setup](#common-setup)
  - [Choose how to run](#choose-how-to-run)
  - [Verify the installation](#verify-the-installation)
- [Configuration](#configuration)
- [Quick start with Docker Compose](#quick-start-with-docker-compose)
- [Running the stacks locally](#running-the-stacks-locally)
  - [Robot Framework](#robot-framework)
  - [Playwright (TypeScript)](#playwright-typescript)
  - [pytest + Playwright](#pytest--playwright)
- [GitHub Actions](#github-actions)
- [Docker images](#docker-images)
- [Jenkins CI](#jenkins-ci)
  - [Architecture](#architecture)
  - [JCasC bootstrap](#jcasc-bootstrap)
  - [SSH key for GitHub](#ssh-key-for-github)
  - [Credentials](#credentials)
  - [Pipelines](#pipelines)
  - [Reports](#reports)
- [Troubleshooting](#troubleshooting)
- [Security notes](#security-notes)

---

## Repository layout

```
.
├── .github/
│   └── workflows/
│       └── e2e-tests.yml
├── .githooks/
│   └── pre-commit
├── compose.yml
├── Dockerfile.jenkins
├── Dockerfile.robot
├── Dockerfile.playwright
├── Dockerfile.python-tests
├── docker-entrypoint.sh
├── generate-ssh-key.sh
├── init.groovy.d/
│   └── 01-fiori-credentials.groovy
├── jenkins.yaml
├── plugins.txt
├── README.md
├── REVIEW.md
├── WINDOWS.md
├── playwright-test/
│   ├── Jenkinsfile
│   ├── package.json
│   ├── package-lock.json
│   ├── eslint.config.mjs
│   ├── playwright.config.ts
│   ├── tsconfig.json
│   ├── fixtures/
│   ├── pages/
│   ├── selectors/
│   ├── utils/
│   └── tests/
│       └── fiori-subaccount-lifecycle.spec.ts
├── python-tests/
│   ├── Jenkinsfile
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   ├── pyproject.toml
│   ├── pytest.ini
│   ├── conftest.py
│   ├── data.py
│   ├── locators/
│   ├── pages/
│   └── tests/
│       └── test_fiori_subaccount_lifecycle.py
└── robot-tests/
    ├── Jenkinsfile
    ├── requirements.txt
    ├── resources/
    │   ├── common/
    │   │   ├── browser_setup.resource
    │   │   └── common_variables.resource
    │   ├── pages/
    │   └── selectors/
    └── tests/
        └── fiori/
            └── fiori_subaccount_lifecycle.robot
```

`python-tests/locators/` was renamed from `selectors/` because a top-level
package named `selectors` shadows the Python standard library module and
breaks unrelated tooling (including `venv`).

---

## Installation and setup

This section takes you from a fresh machine to a running setup. The
project has three parts, and they can be used independently:

| Part | Runs on | Requires |
|------|---------|----------|
| Playwright/TypeScript, pytest, Robot | Linux or Windows | Node.js, Python |
| Docker Compose + Jenkins + dind | Linux; Windows via Docker Desktop/WSL2 | Docker 24+, Compose v2 |
| GitHub Actions + GitHub Pages | GitHub-hosted Ubuntu | A GitHub repository; `gh` optional |

On Windows, **WSL2 + Docker Desktop** is the recommended way to run the
Docker/Jenkins part; the test stacks can also run natively. The detailed
Windows caveats (line endings, WSL paths, pre-commit hook, etc.) are in
[WINDOWS.md](WINDOWS.md).

### Prerequisites

- Linux, or Windows with WSL2 (recommended) / native Windows for the test stacks
- Docker 24+ and Docker Compose v2 for the Jenkins/Compose path
- Node.js 24 LTS (or 22 LTS for Playwright/TS and 24 LTS for Robot; the
  Browser library requires >= 22.15)
- Python 3.10+ (3.12 recommended) with `venv` and `pip`
- Git
- A GitHub account with an SSH key (for the Jenkins checkout)
- A Fiori trial account
- `lockable-resources` is baked into the Jenkins image; no manual plugin setup

### Linux

Install:

- Git
- Docker Engine and the Compose v2 plugin (`docker compose`), following
  the official guide for your distribution:
  <https://docs.docker.com/engine/install/>
- Node.js via nvm (below)
- Python 3.10+ with `venv` and `pip`
- Optional: GitHub CLI (`gh`)

Distro packages:

```bash
# Fedora / RHEL
sudo dnf install -y git python3 python3-pip

# Ubuntu / Debian
sudo apt-get update
sudo apt-get install -y git python3 python3-venv python3-pip
```

Docker: after installing Docker Engine + the Compose plugin, add
yourself to the `docker` group and log out/in (or run `newgrp docker`):

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
docker --version
docker compose version
```

Node.js 22 and 24 with nvm:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
exec "$SHELL"
nvm install 22
nvm install 24
nvm use 24        # Node 24 works for both stacks; use 22 for Playwright-only
```

Optional GitHub CLI:

```bash
# Fedora
sudo dnf install -y gh
# Ubuntu
sudo apt-get install -y gh
```

### Windows

#### WSL2 (recommended)

1. Install WSL2 + Ubuntu from an admin PowerShell:
   ```powershell
   wsl --install -d Ubuntu
   ```
2. Install Docker Desktop and enable:
   - **Settings → General → Use the WSL 2 based engine**
   - **Settings → Resources → WSL Integration → Ubuntu**
3. Open Ubuntu and install Git, Node.js, Python and optional `gh` with the
   Linux commands above.
4. Clone the repository inside the WSL filesystem, not under `/mnt/c`:
   ```bash
   cd ~
   git clone git@github.com:turicsabaistvan/fiori.git
   cd fiori
   ```
5. Set LF line endings (important):
   ```bash
   git config core.autocrlf input
   ```
   Add the `.gitattributes` from [WINDOWS.md](WINDOWS.md) if it is not
   present, then renormalize:
   ```bash
   git add --renormalize .
   git commit -m "Normalize line endings"
   ```
6. Continue with [Common setup](#common-setup) from step 2 (create `.env`).

#### Native Windows (test stacks only)

Install:

- Git for Windows (includes Git Bash)
- Node.js 24 LTS (or 22 LTS + 24 LTS with nvm-windows)
- Python 3.12
- Optional: GitHub CLI (`winget install --id GitHub.cli`)
- Docker Desktop with the WSL2 backend if you also want Jenkins/Compose

The three test stacks run natively; use PowerShell and omit Linux-only
flags:

```powershell
# Playwright (TypeScript)
cd playwright-test
npm ci
npx playwright install chromium
npx playwright test --project=chromium

# pytest + Playwright
cd ..\python-tests
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
playwright install chromium
pytest -m fiori

# Robot Framework
cd ..\robot-tests
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
rfbrowser init
robot --outputdir results tests/
```

Set the credentials before running:

```powershell
$env:FIORI_USERNAME = "you@example.com"
$env:FIORI_PASSWORD = "secret"
$env:BASE_URL = "https://account.hanatrial.ondemand.com/"
```

Notes:

- `npx playwright install --with-deps` is a Linux-oriented flag; on
  Windows use `npx playwright install chromium`.
- The pre-commit hook is a Bash script; commit from Git Bash or WSL. The
  Python venv path is `.venv\Scripts\...` on Windows; see
  [WINDOWS.md](WINDOWS.md).
- The `gh` commands in this README use Bash line continuations; in
  PowerShell use one line or backticks.

### Common setup

These steps apply to Linux, WSL and native Windows (Git Bash/PowerShell
where noted).

1. Clone and enter the repository (skip this if you already cloned it in
   the WSL steps above):
   ```bash
   git clone git@github.com:turicsabaistvan/fiori.git
   cd fiori
   ```
   HTTPS also works.

2. Create the local configuration:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and set at least `FIORI_USERNAME`, `FIORI_PASSWORD` and
   `JENKINS_ADMIN_PASSWORD`. The optional test-data variables and their
   defaults are in [Configuration](#configuration). `.env` is ignored by
   Git; never commit it.

3. Enable the versioned pre-commit hook:
   ```bash
   git config core.hooksPath .githooks
   ```
   The hook runs `tsc` + ESLint for `playwright-test/` and `ruff` +
   `mypy` for `python-tests/` when the commit touches those directories.
   It skips commits that only change other files. If the toolchain is
   not available in the environment that runs the hook (for example a
   GUI commit helper with a minimal `PATH`), that stack's check is
   skipped with a warning instead of blocking the commit. Run the full
   check manually with:
   ```bash
   .githooks/pre-commit --all
   ```
   On Windows, use Git Bash or WSL; see [WINDOWS.md](WINDOWS.md).

### Choose how to run

The suites modify the same SAP trial account. **Do not run them in
parallel** — locally, in Jenkins and in GitHub Actions at the same time.
The tests delete and recreate the `Tester` subaccount; use a dedicated
trial account.

#### Docker Compose + Jenkins

The CI-like path: Jenkins builds the three runner images inside a `dind`
sidecar and runs each suite in a container.

```bash
docker compose build jenkins
docker compose up -d jenkins
docker compose logs -f jenkins
```

Open <http://localhost:8081> and log in with `JENKINS_ADMIN_ID` /
`JENKINS_ADMIN_PASSWORD`. Run the jobs:

- `fiori-playwright-e2e`
- `fiori-python-e2e`
- `fiori-robot-e2e`

The first start generates the SSH key and applies the JCasC jobs. See
[Quick start with Docker Compose](#quick-start-with-docker-compose) and
[Jenkins CI](#jenkins-ci) for the SSH credential and report details.

#### Run the suites locally

Use this for fast iteration:

```bash
# Playwright (TypeScript)
cd playwright-test
npm ci
npx playwright install --with-deps chromium   # Windows: omit --with-deps
npx playwright test --project=chromium
npx playwright show-report

# pytest + Playwright
cd ../python-tests
python -m venv .venv
source .venv/bin/activate                  # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements-dev.txt
playwright install --with-deps chromium    # Windows: omit --with-deps
pytest -m fiori

# Robot Framework
cd ../robot-tests
python -m venv .venv
source .venv/bin/activate                  # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
rfbrowser init --with-deps                 # Windows: rfbrowser init
robot --outputdir results tests/
```

Set the variables in the shell, or use `playwright-test/.env` /
`python-tests/.env`. Robot reads the process environment. The detailed
commands and report paths are in
[Running the stacks locally](#running-the-stacks-locally).

#### Cloud runs with GitHub Actions

The manual workflow runs on GitHub-hosted Ubuntu and publishes the
reports to GitHub Pages. It does **not** read `.env`; it uses repository
secrets.

1. Push the repository to GitHub.
2. Add the secrets (from the repository root):
   ```bash
   gh secret set -f .env
   ```
   or set them in **Settings → Secrets and variables → Actions**.
3. Enable Pages once:
   ```bash
   gh api \
     --method POST \
     -H "Accept: application/vnd.github+json" \
     /repos/turicsabaistvan/fiori/pages \
     -f build_type="workflow"
   ```
   If Pages is already enabled, use `PUT` (see
   [GitHub Pages reports](#github-pages-reports)). For a fork, replace
   `turicsabaistvan/fiori` with your own repository.
4. Run the workflow from the Actions tab or:
   ```bash
   gh workflow run e2e-tests.yml -f suite=all -f browser=chromium
   ```
5. Open the reports:
   <https://turicsabaistvan.github.io/fiori/>

See [GitHub Actions](#github-actions) for the secrets table, inputs,
concurrency rules and artifacts.

### Verify the installation

```bash
# Jenkins is up
docker compose ps
curl -fsS http://localhost:8081/login >/dev/null && echo "Jenkins OK"

# Playwright typecheck / lint
cd playwright-test
npm run typecheck
npm run lint

# Python lint / typecheck (inside the venv)
cd ../python-tests
ruff check .
mypy

# Robot parses the suite
cd ../robot-tests
robot --dryrun tests/
```

On Windows PowerShell, use `Invoke-WebRequest http://localhost:8081/login`
instead of `curl`. A full test run modifies the trial account; run it
only when you are ready. The first Playwright/pytest/Robot run downloads
browsers and is slower.

### Daily usage

- **Fast local run:** Playwright, pytest or Robot from the repository.
- **CI-like run:** the Jenkins pipelines.
- **Cloud run:** GitHub Actions; reports on GitHub Pages.
- **Before committing:** the pre-commit hook runs typecheck/lint; use
  `.githooks/pre-commit --all` for the full check.
- **Reports:** Playwright HTML report, pytest HTML report, Robot
  log/report; Jenkins publishes them, GitHub Actions uploads artifacts
  and deploys the Pages site.
- **Shared account:** run only one suite/workflow at a time; the account
  is destructive.

---

## Configuration

All settings come from environment variables. Copy the example file and
edit it:

```bash
cp .env.example .env
```

| Variable | Used by | Description |
|----------|---------|-------------|
| `FIORI_USERNAME` | all | Fiori trial username (required) |
| `FIORI_PASSWORD` | all | Fiori trial password (required) |
| `BASE_URL` | all | Fiori trial landing page |
| `BROWSER` | Robot, Python | `chromium` / `firefox` / `webkit` |
| `HEADLESS` | Robot, Python | `true` / `false` |
| `SUBACCOUNT_NAME` | all | Name of the test subaccount (default `Tester`) |
| `SUBACCOUNT_DESCRIPTION` | all | Description (default `Test`) |
| `SUBACCOUNT_REGION` | all | Region (default `US East (VA) - AWS`) |
| `DISPLAY_TEXT_REPEAT` | all | Long name repeat count (default `15`) |
| `DESC_TEXT_REPEAT` | all | Long description repeat count (default `10`) |
| `JENKINS_ADMIN_ID` | Jenkins | Local admin user (default `admin`) |
| `JENKINS_ADMIN_PASSWORD` | Jenkins | Local admin password (Compose falls back to `admin` if unset) |
| `JENKINS_UID` / `JENKINS_GID` | Jenkins | Container user |

`.env` is ignored by Git. Never commit real credentials.

When the Playwright or pytest suites run locally, they also load a
`.env` file from their own directory (`playwright-test/.env`, `python-tests/.env`)
via `dotenv`. In Jenkins the values are injected from the Jenkins
credential store. On GitHub Actions the workflow does **not** read
`.env`: it passes repository secrets as environment variables (see
[GitHub Actions](#github-actions)). The Robot suite reads the variables
directly from the process environment in every case.

---

## Quick start with Docker Compose

```bash
cp .env.example .env
# edit .env and set FIORI_USERNAME / FIORI_PASSWORD / JENKINS_ADMIN_PASSWORD

docker compose build jenkins
docker compose up -d jenkins
```

Jenkins automatically starts the `dind` sidecar (see
[Jenkins CI](#jenkins-ci)); the three pipelines build their
`robot-local:latest` / `playwright-local:latest` /
`python-tests-local:latest` images inside it and run each suite in a
container from its image.

Open Jenkins at <http://127.0.0.1:8081> — or at the host's IP on port
8081, because `compose.yml` publishes the port on `0.0.0.0` — and log in
with `JENKINS_ADMIN_ID` / `JENKINS_ADMIN_PASSWORD`. If
`JENKINS_ADMIN_PASSWORD` is not set, Compose falls back to `admin`.

On first start Jenkins:

1. Uses the plugins baked into the image (no runtime plugin installation)
2. Generates an SSH key for GitHub access
3. Applies `jenkins.yaml` through Configuration as Code:
   - local security realm and admin user
   - the three pipeline jobs
4. Runs `init.groovy.d/01-fiori-credentials.groovy`, which creates or
   updates only the `fiori-credentials` credential from
   `FIORI_USERNAME` / `FIORI_PASSWORD`; other credentials are untouched

The generated **public and private** SSH keys are printed to the
container log:

```bash
docker compose logs -f jenkins
```

Add the public key to GitHub, then add the matching **private** key as a
Jenkins credential (see [SSH key for GitHub](#ssh-key-for-github)).
Because the private key is written to the container log, treat the Docker
log as sensitive: anyone who can read it can use the GitHub deploy key.
Restrict access to the Docker daemon and its logs, and rotate the key if
the log was exposed.

Reload the JCasC configuration without restarting:

**Manage Jenkins → Configuration as Code → Reload existing configuration**

---

## Running the stacks locally

### Robot Framework

```bash
cd robot-tests
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
rfbrowser init

export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"

robot --outputdir results tests/
```

The HTML report is written to `robot-tests/results/report.html`.

Test data can be overridden with the environment variables listed in
[Configuration](#configuration).

### Playwright (TypeScript)

```bash
cd playwright-test
npm ci
npx playwright install --with-deps chromium   # or: chromium firefox webkit

export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"

npx playwright test
npx playwright show-report
```

The config defines `chromium`, `firefox` and `webkit` projects and runs
with a single worker because the trial account has shared state. The
browser locale is pinned to `hu-HU` so the Hungarian login selectors are
deterministic.

### pytest + Playwright

```bash
cd python-tests
python -m venv .venv
. .venv/bin/activate
pip install -r requirements-dev.txt
playwright install chromium

export FIORI_USERNAME="you@example.com"
export FIORI_PASSWORD="secret"
export BASE_URL="https://account.hanatrial.ondemand.com/"

pytest -m fiori
```

The HTML report is written to `python-tests/reports/report.html`.
On failure, a full-page screenshot and a Playwright trace are written to
`python-tests/test-results/`.

---

## GitHub Actions

`.github/workflows/e2e-tests.yml` runs the suites on a GitHub-hosted
runner. It is **manual only** (`workflow_dispatch`): the tests delete and
recreate the `Tester` subaccount, so they must not run on every push or
pull request. Lint/typecheck are handled separately by the pre-commit
hook.

The workflow runs the suites directly on the runner (Node/Python), not in
the project's Docker images; the [Jenkins CI](#jenkins-ci) path is
independent of it.

The workflow does **not** read the local `.env` files. It passes the
repository secrets below as environment variables; `.env` is only used
for local runs.

### Required secrets

Add the following in **Settings → Secrets and variables → Actions → New
repository secret**, or with the `gh` CLI:

| Secret | Required | Default | Description |
|--------|----------|---------|-------------|
| `FIORI_USERNAME` | yes | – | Fiori trial username |
| `FIORI_PASSWORD` | yes | – | Fiori trial password |
| `BASE_URL` | no | `https://account.hanatrial.ondemand.com/` | Fiori trial landing page |
| `SUBACCOUNT_NAME` | no | `Tester` | Test subaccount name |
| `SUBACCOUNT_DESCRIPTION` | no | `Test` | Test subaccount description |
| `SUBACCOUNT_REGION` | no | `US East (VA) - AWS` | Region for the subaccount |
| `DISPLAY_TEXT_REPEAT` | no | `15` | Long name repeat count |
| `DESC_TEXT_REPEAT` | no | `10` | Long description repeat count |

With the `gh` CLI:

```bash
gh secret set FIORI_USERNAME
gh secret set FIORI_PASSWORD

# Optional overrides:
gh secret set BASE_URL
gh secret set SUBACCOUNT_NAME
gh secret set SUBACCOUNT_DESCRIPTION
gh secret set SUBACCOUNT_REGION
gh secret set DISPLAY_TEXT_REPEAT
gh secret set DESC_TEXT_REPEAT
```

To upload every value from the local `.env` file in one command:

```bash
gh secret set -f .env
```

This reads the dotenv-formatted file locally and creates/updates
repository secrets for every key in it. It requires `gh auth login` and
must run from the repository root, or with `--repo owner/repo`. The
workflow only reads the keys listed in the table above; any extra keys
(for example `JENKINS_*`) are uploaded but unused. The `.env` file itself
stays local and is ignored by Git.

The workflow falls back to the defaults when an optional secret is not
set. Secrets are masked in the workflow log; never commit them to the
repository.

### Running the workflow

1. Open the repository on GitHub and go to **Actions**.
2. Select **Fiori E2E tests** in the left sidebar.
3. Click **Run workflow**, choose the suite and browser, and start the
   run.

If Actions is disabled for the repository, enable it first in
**Settings → Actions → General**.

Or from the `gh` CLI:

```bash
gh workflow run e2e-tests.yml -f suite=all -f browser=chromium
```

| Input | Values | Default | Description |
|-------|--------|---------|-------------|
| `suite` | `all`, `playwright`, `python`, `robot` | `all` | Which suite(s) to run |
| `browser` | `chromium`, `firefox`, `webkit` | `chromium` | Browser for the suite |

With `suite: all` the jobs run sequentially: Playwright → pytest →
Robot. If a suite fails, the remaining suites are skipped, because they
share the same trial account.

### Concurrency and safety

The workflow uses the `fiori-trial-account` concurrency group with
`cancel-in-progress: false`. This means:

- Only one workflow run touches the trial account at a time.
- Do not start a second run while one is in progress.
- Do not cancel a running workflow in the middle of a test; a cancelled
  deletion can leave the subaccount in a "Deletion in Progress" state.

The concurrency group only serializes GitHub Actions runs. It does not
coordinate with the Jenkins pipelines; do not run a GitHub Actions test
and a Jenkins job against the same trial account at the same time.

The tests are destructive: they delete the existing `Tester` subaccount
and create a new one. Use a dedicated trial account, not an account with
data you need to keep. The same caveat applies to local runs.

### Artifacts

Each job uploads its reports and failure artifacts (14-day retention):

- `playwright-report` — Playwright HTML report, traces, screenshots and
  video.
- `python-report` — pytest HTML report, screenshots and traces.
- `robot-report` — Robot log/report and `xunit.xml`.

The Robot log contains the Fiori username but not the password; treat
downloaded artifacts accordingly.

GitHub-hosted runners are ephemeral, so every run installs the
dependencies and browser binaries; the first run takes a few minutes
longer than a local run.

### GitHub Pages reports

The workflow publishes the reports to GitHub Pages. Enable Pages once
for the repository before the first run (requires `gh auth login` with
admin access):

```bash
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/turicsabaistvan/fiori/pages \
  -f build_type="workflow"
```

If Pages is already enabled, the POST returns `409`; update the build
type with `PUT` (or set **Settings → Pages → Build and deployment →
Source** to **GitHub Actions**):

```bash
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/turicsabaistvan/fiori/pages \
  -f build_type="workflow"
```

For a fork, replace `turicsabaistvan/fiori` with your own repository.
After the next workflow run, the reports are available at
<https://turicsabaistvan.github.io/fiori/>. The index links to the
Playwright, pytest and Robot reports that were generated; the `pages` job
deploys them with `actions/upload-pages-artifact` and
`actions/deploy-pages`.

---

## Docker images

| Image | Dockerfile | Purpose |
|-------|------------|---------|
| `jenkins-local:lts` | `Dockerfile.jenkins` | Jenkins controller + Docker CLI; orchestrates the pipelines |
| `robot-local:latest` | `Dockerfile.robot` | Robot Framework runner; built inside the `dind` sidecar by the Robot pipeline (also usable standalone) |
| `playwright-local:latest` | `Dockerfile.playwright` | Playwright (TypeScript) runner; built inside the `dind` sidecar by the Playwright pipeline (also usable standalone) |
| `python-tests-local:latest` | `Dockerfile.python-tests` | pytest + Playwright runner; built inside the `dind` sidecar by the pytest pipeline (also usable standalone) |

The Jenkins image only orchestrates. Every pipeline builds its suite's
image inside the `dind` sidecar and runs the tests in a container from
that image. Docker access is provided over TLS; the host Docker socket
is not mounted anywhere.

---

## Jenkins CI

### Architecture

All three pipelines are declared with `agent any`, so their stages run on
the Jenkins controller.

All three pipelines run their suites in containers from
`robot-local:latest` / `playwright-local:latest` /
`python-tests-local:latest`: they build the image with the Docker CLI
and start the tests with `docker run`, binding the pipeline workspace
into the container.

The Playwright tests keep `node_modules` in the `playwright_node_modules` named
volume, which the pipeline repopulates from the freshly built image on
every run, so the bind-mounted workspace is used with the image's
dependencies and no `npm ci` is needed at test time. The Robot and
pytest images install their dependencies at build time, so those suites
need no extra volume.

Jenkins reaches Docker through the **`dind` sidecar** (`docker:24-dind`,
`privileged`) over TLS, using client certificates from the `dind_certs`
volume. The host `/var/run/docker.sock` is not mounted anywhere. The
`dind` container mounts `jenkins_home/workspace` at the same path as
Jenkins (`/var/jenkins_home/workspace`), so the workspace bind mount
inside the test container resolves to the checked-out files.

Because the three jobs modify the same SAP trial account, each test stage
runs inside a shared lock:

```groovy
lock('fiori-trial-account') {
    // test execution
}
```

The `lockable-resources` plugin provides the `lock` step. Concurrent
builds of the same job are also disabled.

Plugin versions are pinned in `plugins.txt` and installed at **image build
time**. The runtime entrypoint no longer installs or upgrades plugins.

### JCasC bootstrap

`jenkins.yaml` is mounted into the container and loaded through the
`CASC_JENKINS_CONFIG` environment variable. It configures:

- the local security realm and the admin user
- the three pipeline jobs

The `fiori-credentials` credential is **not** managed by JCasC, so a
manual `git-ssh-credentials` is never removed by a JCasC reload.
`init.groovy.d/01-fiori-credentials.groovy` creates or updates only
`fiori-credentials` from `FIORI_USERNAME` / `FIORI_PASSWORD` at Jenkins
startup. Restart Jenkins after changing those values.

| Job | Jenkinsfile | Description |
|-----|-------------|-------------|
| `fiori-robot-e2e` | `robot-tests/Jenkinsfile` | Robot Framework suite |
| `fiori-playwright-e2e` | `playwright-test/Jenkinsfile` | Playwright (TypeScript) suite |
| `fiori-python-e2e` | `python-tests/Jenkinsfile` | pytest + Playwright suite |

### SSH key for GitHub

`generate-ssh-key.sh` runs from `docker-entrypoint.sh` on every start and:

1. Generates an ed25519 key at `/var/jenkins_home/.ssh/id_ed25519` if it
   does not exist yet (idempotent)
2. Adds `github.com` to `known_hosts`
3. Prints the **public and private** keys to the container log

Add the public key to GitHub:

**GitHub → Settings → SSH and GPG keys → New SSH key → paste → Add.**

Add the private key to Jenkins:

**Manage Jenkins → Credentials → System → Global credentials →
Add Credentials → SSH Username with private key:**

| Field | Value |
|-------|-------|
| ID | `git-ssh-credentials` |
| Username | `git` |
| Private Key | Enter directly → paste the key retrieved below |
| Passphrase | (empty) |

The private key is printed to the container log and is also available in
the mounted `jenkins_home` volume, so both `docker compose logs` and
`jenkins_home/.ssh/` must be treated as sensitive:

```bash
docker compose exec jenkins cat /var/jenkins_home/.ssh/id_ed25519
```

Rotate the key if either the log or the volume was exposed.

### Credentials

| ID | Kind | Created by | Used by |
|----|------|------------|---------|
| `git-ssh-credentials` | SSH Username with private key | Manual (see above) | All pipelines (checkout) |
| `fiori-credentials` | Username with password | `init.groovy.d/01-fiori-credentials.groovy`, from `FIORI_USERNAME` / `FIORI_PASSWORD` | All pipelines (test login) |

`fiori-credentials` is created or updated at Jenkins startup. If
`FIORI_USERNAME` / `FIORI_PASSWORD` are empty, the init script skips the
update; if the credential does not exist yet, the pipelines fail at
credential binding. Set the values in `.env` and restart Jenkins.

### Pipelines

| Pipeline | Agent | Runs |
|----------|-------|------|
| `fiori-robot-e2e` | controller + `robot-local` container via `dind` | `robot --xunit ... robot-tests/tests/` |
| `fiori-playwright-e2e` | controller + `playwright-local` container via `dind` | `npx playwright test` inside `playwright-test/` in the `playwright-local` container |
| `fiori-python-e2e` | controller + `python-tests-local` container via `dind` | `pytest -m fiori` inside `python-tests/` in the `python-tests-local` container |

Each pipeline:

1. Checks out the repository
2. Builds its suite's Docker image (`robot-local`, `playwright-local`,
   `python-tests-local`)
3. Runs the test suite under `lock('fiori-trial-account')`

Parameters such as `BROWSER`, `HEADLESS`, `BASE_URL`, `PW_PROJECT`,
`PW_GREP` and `PYTEST_MARKERS` are exposed to the shell as environment
variables; the suites read them from the environment.

### Reports

- **JUnit** – Robot uses `--xunit` to produce `results/xunit.xml`;
  Playwright and pytest produce JUnit XML under `test-results/`.
- **HTML Publisher** – Robot report, Playwright HTML report, pytest HTML
  report.
- **Archive Artifacts** – screenshots, videos, traces, Robot outputs.

---

## Troubleshooting

### Jenkins shows "Getting ready to work" forever

Check the container log:

```bash
docker compose logs -f jenkins
```

Look for `SEVERE` lines. The most common cause is a JCasC error — for
example a missing `JENKINS_ADMIN_ID`, `JENKINS_ADMIN_PASSWORD`,
`FIORI_USERNAME` or `FIORI_PASSWORD` environment variable. Fix `.env`
and restart:

```bash
docker compose restart jenkins
```

### `FIORI_USERNAME and FIORI_PASSWORD environment variables must be set`

The test suites fail fast when credentials are missing. Set them in
`.env` (Compose), in `playwright-test/.env` / `python-tests/.env` (local runs), or in
the Jenkins credential store (CI).

### `npm ci` fails while building the Playwright image

`playwright-test/package-lock.json` is committed and must stay in sync with
`package.json`. After changing dependencies, run `npm install` in `playwright-test/`
and commit the updated lockfile.

### `No such DSL method 'lock' found`

The `lockable-resources` plugin is missing. Rebuild the Jenkins image:

```bash
docker compose build --no-cache jenkins
docker compose up -d
```

### `No such DSL method 'publishHTML' found`

The `htmlpublisher` plugin is missing. Check `plugins.txt` and rebuild the
Jenkins image.

### `Cannot connect to the Docker daemon` in a test pipeline

The test pipelines use the `dind` sidecar, not the host Docker daemon.
Check that it is running and healthy:

```bash
docker compose ps dind
docker compose logs dind
```

The `dind` entrypoint generates the TLS certificates in the `dind_certs`
volume, and Jenkins waits for the sidecar's healthcheck. If that volume
was removed, restart both containers:

```bash
docker compose restart dind jenkins
```

### The test pipelines rebuild their images on every run

Build steps are cached in the `dind_storage` volume. If the volume was
removed, the first build downloads the base images and the Playwright
browsers again; later builds reuse the layers.

### Robot Framework reports missing resource files

Run Robot from the repository root and keep the paths relative to the
test file:

```bash
robot --outputdir results robot-tests/tests/
```

The suite imports its resources from `robot-tests/resources/`, relative to
`robot-tests/tests/fiori/`.

### `browserType.launch: Executable doesn't exist`

Install the browsers for the stack you are running:

```bash
# Playwright
cd playwright-test && npx playwright install chromium

# python-tests
cd python-tests && playwright install chromium
```

In the `playwright-local` and `python-tests-local` images the browsers
are already installed at `/ms-playwright`.

### Permission denied when writing to `jenkins_home`, `node_modules`, `reports` or `test-results`

An older container may have created these directories as root. Remove or
relocate them, or align the UID/GID values in `.env` with your host user.
The Playwright pipeline already uses a named volume for `node_modules` to
avoid this.

### GitHub clone fails with "does not appear to be a git repository"

This is the generic error the Jenkins Git plugin shows when the SSH
handshake fails. Check, in order:

1. The SSH key exists in `/var/jenkins_home/.ssh/` and is owned by the
   Jenkins user
2. `github.com` is in `/var/jenkins_home/.ssh/known_hosts`
3. The `git-ssh-credentials` credential contains the matching private key
4. The public key is registered on GitHub

---

## Security notes

- Credentials live only in environment variables / the Jenkins credential
  store / GitHub Actions secrets. `.env` is ignored by Git.
- Any credential that was ever committed must be rotated and purged from
  the Git history. Removing the file from HEAD is not enough.
- `compose.yml` publishes Jenkins on all host interfaces:
  `0.0.0.0:8081` for the UI and `0.0.0.0:50001` for the agent port. If the
  host is reachable from an untrusted network, change the mappings to
  `127.0.0.1:8081:8080` and remove the `50001` mapping, or place Jenkins
  behind TLS and a reverse proxy.
- Set `JENKINS_ADMIN_PASSWORD` explicitly. If it is unset, Compose falls
  back to `admin`, which is not safe.
- The private SSH key is stored in `jenkins_home/.ssh/` and is also printed
  to the container log by `generate-ssh-key.sh`. Protect both the volume
  and the Docker logs, and rotate the key if either was exposed.
- The `dind` sidecar runs `privileged: true` and is reachable only on the
  internal `test_network`, over TLS. The host Docker socket is not mounted
  into any container.

---

## License

Internal / portfolio project. Not intended for production use against
the SAP Fiori trial landscape without the account owner's consent.
