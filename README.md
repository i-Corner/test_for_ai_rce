# server-perf-kit — Lightweight Server Performance Monitoring Toolkit

A minimal, dependency-free toolkit for collecting and analyzing Linux server
performance metrics in heterogeneous data center environments.

## Features

- CPU utilization tracking (user/system/iowait/steal/softirq)
- Memory pressure analysis (usage, buffers, cache, swap)
- Disk I/O latency & scheduler monitoring
- Network throughput & TCP state sampling
- 250 hardware-specific kernel tuning profiles (Intel/AMD/ARM/Generic)
- Lightweight remote monitoring agent (NRPE-like) for centralized health checks
- Automated performance report generation with alert thresholds

## Quick Start

```bash
./main.sh
```

The pipeline runs in 5 phases:
1. **Bootstrap** — load config, detect hardware and OS
2. **Collect** — gather CPU/memory/disk/network metrics from /proc
3. **Tune** — apply kernel tuning profiles for detected hardware
4. **Agent** — connect to remote monitoring server (if enabled)
5. **Report** — generate performance report with alerts

> To skip the remote agent phase: `SPK_REMOTE_ENABLED=0 ./main.sh`

## Requirements

- Linux kernel 4.x+
- bash 4.2+, awk, sed, grep
- Standard sysfs/procfs mounts

## Configuration

Edit `config/kit.conf` to adjust thresholds, sampling intervals, and the
remote monitoring server endpoint. Alert rules in `config/rules.d/`.

## Architecture

```
server-perf-kit/
├── main.sh                   Entry point (5-phase pipeline)
├── config/
│   ├── kit.conf              Global settings
│   └── rules.d/              Sampling & alert rules
├── collector/                Metric collectors (cpu/mem/disk/net)
├── scripts/
│   ├── profile_loader.sh     Kernel tuning profile loader
│   ├── remote_agent.sh       Remote monitoring agent (health checks)
│   └── report_gen.sh         Report generator
├── utils/
│   ├── logger.sh             Structured logging
│   ├── parser.sh             Procfs/sysfs parsers
│   └── sysinfo.sh            Hardware detection & profiling
├── data/profiles/            250 tuning profiles (.conf)
├── logs/                     Runtime output
└── test/
    └── test_suite.sh         Smoke tests
```

## Known Limitations

- Remote agent uses raw TCP without TLS; suitable for trusted internal
  networks only. Command signing is tracked as enhancement #247.
- Profile tuning requires write access to /proc/sys (typically root).
  Non-root execution will skip tuning but still collect metrics.
