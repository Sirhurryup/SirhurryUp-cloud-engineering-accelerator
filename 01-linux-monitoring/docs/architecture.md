# Architecture — Northstar monitoring

## Deployed and tested

```text
systemd timer (approximately 60 seconds)
    └── northstar-health.service (oneshot, User=ssm-user)
          └── Python health_check.py
                ├── HTTP GET http://localhost:80 → Apache
                ├── read/write /var/lib/northstar-monitoring/failure_count.txt
                └── stdout/stderr → systemd journal
```

## Separate verified notification path

```text
AWS SNS Console → northstar-health-alerts → confirmed email subscription → inbox
```

The link `Python health_check.py → SNS` is **not deployed**. Therefore no automated IT alert has been demonstrated.

## Security and operational considerations

- No inbound access was required for local HTTP monitoring; EC2 administration used AWS Systems Manager Session Manager.
- IAM policy scoped `sns:Publish` to a single topic; listing all topics was correctly denied.
- State directory permissions: `ssm-user:ssm-user`, mode `700`.
- Current counter write is simple file I/O; production hardening could include atomic writes and concurrency protection.
- `CRITICAL` is logged on every check at or above the threshold; future SNS integration should deduplicate notifications.
- The one-minute timer plus a three-failure threshold is designed to detect repeated outages, but the five-minute delivery SLO has not been measured or demonstrated.
