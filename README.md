# snakemake-checkpoint-benchmark
this test workflow is used for testing snakemake checkpoint speed.

这个workflow用于测试snakemake checkpoint的速度。

### 背景

使用snakemake编写流程时，会遇到“后续分析流程的执行需要依赖某个rule的执行结果“的情景。官方提供了[“数据依赖的条件执行“](https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#data-dependent-conditional-execution)来处理这个场景。其关键在于定义`checkpoint`，每个由`checkpoint`派生的job，在执行完毕后都会触发DAG的重新评估。

但是在实际使用中发现，当待分析的jobs有很多时（workflow很大），`checkpoint`触发的DAG评估会导致分析速度很慢。例如，分析998例病毒样本时。为此，使用本仓库对`checkpoint`的速度进行一个简单评估。

### 测试方案

所有评估的rules使用轻量级分析创建，例如`echo test`之类的。

分析流程模拟1000例样本的分析。用`A B`表示两种不同的情况，其中800例样本为`A`，走流程A。剩余200例样本为`B`，走流程B。

使用非`checkpoint`形式创建一个普通流程，测试其速度。

### 执行测试

用以下命令执行测试。

```bash
snakemake \
    --cores all \
    -s workflow/xxx.smk \
    -p \
    2>&1 | tee run.log
```
