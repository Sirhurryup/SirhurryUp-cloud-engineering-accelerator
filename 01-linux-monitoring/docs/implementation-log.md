# Engineering decision log — Project 01

**Scenario:** Northstar Business Services is fictional. The lab and command outputs were real.

## Decisions

1. **Monitor Apache locally:** Python `urllib.request.urlopen("http://localhost", timeout=5)` avoids exposing Apache publicly just for health checks. An HTTP 200 indicates this specific endpoint responded; it is not a complete application health guarantee.
2. **Separate scheduler from logic:** A systemd oneshot service runs the Python script; a timer schedules it approximately once per minute. Journal captures output without a separate logging stack.
3. **Persist failures:** Store the counter in `/var/lib/northstar-monitoring/failure_count.txt`, outside the script process. This supports escalation across separate timer invocations.
4. **Threshold of three:** The first two failures warn; the third is critical. This reduces alerting on a single transient failure, at the cost of slower detection.
5. **Recovery resets state:** A successful HTTP 200 resets the counter to zero.
6. **Least-privilege IAM:** EC2 role was granted `sns:Publish` scoped to the Northstar SNS topic. `sns:ListTopics` was denied as expected; no broad permission was added.
7. **Evidence discipline:** SNS console email delivery succeeded, but the Python-to-SNS connection was not implemented. Therefore the five-minute IT notification target remains unverified.

## Debugging and verification narrative

- Script revisions introduced a duplicate failure increment and an incorrect variable reference inside the HTTPError exception branch. Both were corrected before deployment.
- `python3 -m py_compile` completed with no output; syntax passed.
- Timer was stopped for controlled testing, then restarted.
- Healthy run: `HEALTHY: Apache is responding`; exit `0`; counter `0`.
- Apache stopped intentionally. Three runs produced WARNING 1/3, WARNING 2/3, CRITICAL 3/3 with connection refused.
- Apache restarted; healthy check reset state to `0`.
- Journal showed scheduled HEALTHY checks at 22:49:30 and 22:50:30 UTC.
- AWS CLI installed and STS identity check succeeded, but `aws sns publish` repeatedly returned `badly formed help string`, including after reinstall. Root cause was **not determined**.
- SNS console publishing was successful and the test email arrived.
- EC2 was stopped after testing.

## Lessons

A successful manual check is not the same as successful automation; a journal CRITICAL message is not a delivered alert. Verify each system boundary separately and report the integration gaps accurately.
