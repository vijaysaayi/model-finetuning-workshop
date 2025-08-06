# GitHub Actions CI/CD Setup

This repository includes automated testing workflows for the model fine-tuning validation scripts.

## 🚀 Available Workflows

### 1. Quick Validation Test (`quick-validation.yml`)
**Simple, focused workflow for basic validation**

- **Triggers**: Push to main/develop, PRs, manual dispatch
- **Python versions**: 3.8, 3.9, 3.10, 3.11, 3.12, 3.13
- **Operating systems**: Ubuntu Latest, Windows Latest
- **Test script**: `validation/quick_test.py`
- **Runtime**: ~5-10 minutes per job

**What it does:**
1. Creates Python virtual environment
2. Installs packages from `prerequisites/requirements.txt`
3. Runs the quick validation test
4. Tests across all Python/OS combinations

### 2. Comprehensive Validation (`validation-ci.yml`)
**Full-featured workflow with advanced reporting and configuration**

- **Triggers**: Push, PRs, manual dispatch with custom parameters
- **Features**: 
  - Dynamic test matrix configuration
  - Detailed system information reporting  
  - Package verification steps
  - Output file checking
  - Test result summaries
  - Cleanup procedures
- **Timeout**: 30 minutes per job
- **Advanced**: Excludes problematic combinations, handles edge cases

## 🎯 Workflow Status

Add these badges to your README.md to show build status:

```markdown
[![Quick Validation](https://github.com/vijaysaayi/model-finetuning-workshop/actions/workflows/quick-validation.yml/badge.svg)](https://github.com/vijaysaayi/model-finetuning-workshop/actions/workflows/quick-validation.yml)

[![Validation CI](https://github.com/vijaysaayi/model-finetuning-workshop/actions/workflows/validation-ci.yml/badge.svg)](https://github.com/vijaysaayi/model-finetuning-workshop/actions/workflows/validation-ci.yml)
```

## 🛠️ Manual Workflow Execution

You can manually trigger workflows from the GitHub Actions tab:

1. Go to **Actions** tab in your repository
2. Select the workflow you want to run
3. Click **Run workflow**
4. For the comprehensive workflow, you can customize:
   - Python versions to test (e.g., "3.10,3.11,3.12")
   - Operating systems (e.g., "ubuntu-latest,windows-latest")

## 🔧 Workflow Configuration

### Environment Variables
Both workflows set these environment variables for consistent execution:
- `TOKENIZERS_PARALLELISM=false` - Prevents tokenizer warnings
- `HF_HUB_DISABLE_PROGRESS_BARS=1` - Cleaner CI output
- `HF_HUB_ENABLE_HF_TRANSFER=0` - Stable downloads in CI

### Python Version Compatibility
- **Python 3.8-3.12**: Full support on both Linux and Windows
- **Python 3.13**: Linux only (Windows excluded due to PyTorch limitations)

### Virtual Environment Setup
Each job:
1. Creates a fresh Python virtual environment
2. Activates it with OS-appropriate commands
3. Installs requirements in isolated environment
4. Runs validation tests

## 📊 Test Matrix Details

| OS | Python Versions | Total Jobs |
|---|---|---|
| Ubuntu Latest | 3.8, 3.9, 3.10, 3.11, 3.12, 3.13 | 6 |
| Windows Latest | 3.8, 3.9, 3.10, 3.11, 3.12 | 5 |
| **Total** | | **11 jobs** |

## 🐛 Troubleshooting

### Common Issues

1. **PyTorch Installation Failures**
   - Usually occurs with newer Python versions
   - Check PyTorch compatibility matrix
   - Consider excluding problematic combinations

2. **Memory Issues**
   - Models are small (0.5B parameters) but can still cause issues
   - CI runners have limited resources
   - Quick test uses minimal epochs to reduce resource usage

3. **Package Compatibility**
   - The `prerequisites/requirements.txt` includes version constraints
   - Some packages may not support the latest Python versions immediately

### Debugging Tips

1. **Check workflow logs**: Click on failed jobs to see detailed logs
2. **Test locally**: Run the same commands locally to reproduce issues
3. **Update requirements**: Keep package versions up-to-date
4. **Modify matrix**: Exclude problematic Python/OS combinations

## 🚀 Adding New Tests

To add more validation tests:

1. Create new Python test scripts in the `validation/` folder
2. Update the workflow YAML files to run your new scripts
3. Consider adding them to both quick and comprehensive workflows
4. Update requirements if new dependencies are needed

## 📈 Performance Optimization

Current optimizations:
- **Pip caching**: Speeds up dependency installation
- **Shallow git clone**: Faster repository checkout  
- **Environment variables**: Reduce unnecessary output
- **Timeout limits**: Prevent stuck jobs
- **Fail-fast disabled**: Continue testing other combinations even if one fails
- **Cleanup steps**: Remove large model files to save space

## 🔒 Security Considerations

- Workflows only trigger on push/PR to main branches
- No secrets or credentials required
- All dependencies installed from public repositories
- Virtual environments provide isolation

## 📝 Maintenance

Regular maintenance tasks:
1. **Update Python versions** in the matrix as new versions are released
2. **Update action versions** (checkout@v4, setup-python@v5, etc.)
3. **Review and update package versions** in requirements.txt
4. **Monitor workflow performance** and adjust timeouts if needed
5. **Clean up old workflow runs** to save storage space

## 🤝 Contributing

When contributing to this project:
1. Ensure your changes don't break the existing workflows
2. Test locally with multiple Python versions if possible
3. Update this documentation if you modify the workflows
4. Consider the impact on CI runtime and resource usage
