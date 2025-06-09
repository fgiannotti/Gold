# GitHub Actions for Gold Game Tests

This repository includes automated testing via GitHub Actions that run on every push and pull request.

## Workflow Overview

The workflow consists of several jobs:

### 🧪 `test-suite` (Main Test Job)
- **Triggers**: Runs on pushes to `main`/`master` branches and pull requests
- **Purpose**: Downloads Godot 4.3 and runs the complete test suite
- **Duration**: ~2-3 minutes per run

### 🔍 `validate-project` 
- **Triggers**: Same as test-suite
- **Purpose**: Validates that all required test files are present
- **Duration**: ~10 seconds

### 🔄 `test-compatibility` (Compatibility Test)
- **Triggers**: Pull requests and scheduled runs
- **Purpose**: Tests compatibility with Godot 4.2
- **Duration**: ~2-3 minutes
- **Note**: Won't fail the workflow if tests fail (continue-on-error: true)

## Workflow Features

### ⚡ Performance
- Parallel job execution for faster feedback
- Optimized Godot download and setup
- Efficient artifact handling

### 🎯 Smart Triggering
- Automatically runs on:
  - Pushes to main/master branches
  - Pull request creation/updates
- Compatibility tests on pull requests
- Can be extended with scheduled runs

### 📊 Test Results
- Clear pass/fail indicators in GitHub UI
- Detailed test output in action logs
- Test artifacts uploaded for debugging (7 days retention)
- Integration with GitHub's status checks

## Running Tests Locally

You can run the same tests locally using:

```bash
# Windows
& "path\to\Godot.exe" --script tests/test_runner.gd

# Linux/Mac  
./godot --headless --script tests/test_runner.gd
```

## Adding New Tests

1. Create your test file in the `tests/` directory
2. Extend the `BaseTest` class from `test_runner.gd`
3. Add your test file to the `run_all_tests()` function in `test_runner.gd`
4. The GitHub Action will automatically include it in future runs

## Workflow Configuration

The workflow is configured in `.github/workflows/test.yml` and includes:

- **Runner**: Ubuntu Latest
- **Godot Version**: 4.3 stable (configurable)
- **Parallel Jobs**: Test suite, validation, and compatibility testing
- **Artifacts**: Test results and logs preserved for debugging

## Branch Protection

You can configure branch protection rules in your GitHub repository:

1. Go to **Settings** → **Branches**
2. Add a rule for `main`/`master`
3. Enable **Require status checks to pass before merging**
4. Select the test jobs: `test-suite` and `validate-project`
5. Enable **Require branches to be up to date before merging**

This ensures no code can be merged without passing tests!

## Troubleshooting

### Action Fails with "Godot not found"
- Check that the Godot download URL is correct in the workflow file
- Verify the Godot version matches the binary name

### Tests Pass Locally but Fail in Actions
- Ensure tests don't depend on local file paths
- Check that all required resources are committed to the repository
- Verify tests work in headless mode

### Workflow Not Triggering
- Check that the workflow file is in `.github/workflows/`
- Verify the branch names match your repository's default branch
- Ensure the workflow file syntax is valid YAML

## Customization Options

### Change Godot Version
Edit `.github/workflows/test.yml` and update:
```yaml
GODOT_VERSION="4.3"
GODOT_URL="https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip"
```

### Add Scheduled Runs
Add to the workflow's `on:` section:
```yaml
on:
  schedule:
    - cron: '0 6 * * 1'  # Run every Monday at 6 AM UTC
```

### Matrix Testing (Multiple Godot Versions)
You can extend the workflow to test multiple Godot versions:
```yaml
strategy:
  matrix:
    godot-version: ['4.2.2', '4.3']
```

## Exit Codes

The test runner returns appropriate exit codes for CI/CD:
- **0**: All tests passed
- **1**: One or more tests failed

This ensures GitHub Actions correctly identifies success/failure states.

## Status Badges

Add a status badge to your README.md:
```markdown
![Tests](https://github.com/your-username/your-repo/actions/workflows/test.yml/badge.svg)
```

This shows the current test status directly in your repository! 