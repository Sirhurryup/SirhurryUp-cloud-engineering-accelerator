# Test results and acceptance status

| Test | Observed evidence | Result |
|---|---|---|
| Healthy HTTP check | HEALTHY output; exit status `0` | PASS |
| Persistent counter initialization | State file contained `0` | PASS |
| First failed check | WARNING, failure 1 of 3 | PASS |
| Second failed check | WARNING, failure 2 of 3 | PASS |
| Third failed check | CRITICAL, 3 consecutive failures | PASS |
| Recovery | Apache restarted; HEALTHY; counter `0` | PASS |
| Timer active | `systemctl is-active northstart-health.timer` → `active` | PASS |
| Automated execution | journald entries at 22:49:30 and 22:50:30 UTC | PASS |
| SNS email subscription | Confirmed | PASS |
| SNS email delivery via console | Test email received | PASS |
| EC2 IAM role authentication | STS GetCallerIdentity succeeded | PASS |
| CLI SNS publish | `badly formed help string` | NOT WORKING |
| Automatic Python → SNS publishing | Not implemented | NOT TESTED |
| IT email within five minutes of outage | Not tested end to end | NOT VERIFIED |
| Instance shutdown | User confirmed stopped | PASS |

## Evidence boundaries

The four visuals in `images/` are reconstructed from the recorded outputs. They are not original terminal screenshots. The failure runs were manual controlled tests; the automated timer runs observed in the journal were healthy checks. Do not conflate these into an automated outage alert demonstration.
