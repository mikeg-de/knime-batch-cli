# Reference: Headless Execution of KNIME Analytics Platform

> Archived from [reneamendes/knime-headless](https://github.com/reneamendes/knime-headless) (2024-08-09)

## Headless Execution Command

A headless execution runs KNIME via command line with no GUI.

### Linux

```shell
./knime -consoleLog -reset -nosave -nosplash \
  -application org.knime.product.KNIME_BATCH_APPLICATION \
  -workflowDir=/absolute/path/to/workflow \
  -workflow.variable=name,"value",type
```

### Windows

```bat
set KNIME_PATH=C:\APP\knime_5.3.0\knime.exe
set WORKFLOW_DIR=C:\APP\knime_workspace\MyWorkflow
set PREFERENCES=C:\APP\knime_workspace\530.epf
set LOG_FILE_PATH=C:\APP\knime_log.txt

"%KNIME_PATH%" -nosplash -nosave -reset ^
  -application org.knime.product.KNIME_BATCH_APPLICATION ^
  -workflowDir="%WORKFLOW_DIR%" ^
  -workflow.variable=myVar,myValue,String ^
  -preferences=%PREFERENCES% > "%LOG_FILE_PATH%" 2>&1
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Successful execution |
| 2 | Parameters wrong or missing |
| 3 | Error during workflow loading |
| 4 | Error during execution |

## Production Example (PeopleSoft Integration)

Wrapper script hiding batch complexity:

```shell
/u01/app/knime_4.4.0/knime -nosplash -nosave -reset \
  -application org.knime.product.KNIME_BATCH_APPLICATION \
  -workflowDir=$1 \
  -workflow.variable=$2 \
  -preferences=/u01/app/knime_4.4.0/preferences440.epf
```

Called from PeopleSoft via SSH with two parameters: workflow path and variable definition.

## Key Notes

- Paths with spaces cause issues — avoid them
- Error windows may open on failure even in "headless" mode
- Not officially recommended by KNIME AG (works fine in practice)
- Security managed by OS user accounts and groups
- Preference files (`.epf`) are optional

## References

- [Marcus Lauber: KNIME Batch Processing on Windows and macOS](https://medium.com/low-code-for-advanced-data-science/knime-batch-processing-on-windows-and-macos-caacde067bd0)
- [KNIME Forum: Execute Workflow in Batch Mode Windows 10](https://forum.knime.com/t/execute-workflow-in-batch-mode-windows-10/13986/24)
- [Archived KNIME FAQ](https://web.archive.org/web/20231208203103/https://www.knime.com/faq#q12)
