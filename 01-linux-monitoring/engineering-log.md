
# Project 01 — Engineering Log

## Day 1: Customer Discovery
**Date:** November 5, 2026

### Customer
Northstar Business Services (fictional case study)

### Business Problem
Northstar operates a customer-facing application on an Ubuntu Linux EC2 instance.

Customers experienced approximately 40 minutes of service interruption. The application was restarted, restoring service, but the underlying cause remains unknown.

The customer needs earlier failure detection, useful diagnostic information, and a cost-conscious solution.

### Discovery Questions
1. Were server or application changes made before the failure?
2. Did customers experience additional outages or slowdowns after service was restored?
3. Were server or application logs reviewed before restarting?

### Information Reported
- An application update was deployed the evening before the outage.
- The deployment was reported as successful.
- An engineer restarted the application.
- The application appeared to operate normally afterward.

### Investigation Hypothesis
The deployment may have contributed to the outage.

**Status:** Unverified. No root cause has been established.

### Initial Investigation Approach
Review application logs and correlate relevant events with the deployment and outage timeline.

### Outstanding Questions
- What errors or unusual events occurred before the outage?
- Were system resources exhausted?
- Did the application experience additional failures after restarting?
- What monitoring currently exists?
- How quickly must the team detect an outage?
- Who should receive alerts?

### Engineering Decision
Do not select or deploy monitoring tools until the initial requirements and investigation needs are understood.

### Evidence Status
Customer statements are simulated scenario information. No production logs, metrics, or technical test results have been collected.



## Day 1: Monitoring Requirements and Design

### Customer Requirements
- Notify the IT team within five minutes of an outage beginning.
- Detect failures affecting customer service-request submissions.
- Provide useful information for investigating failures.
- Keep monitoring costs reasonable.

### Proposed Monitoring Design
- Check application health every 60 seconds.
- Consider triggering a critical alert after three consecutive failed checks.
- Monitor both application availability and critical business functionality.

### Risks and Tradeoffs
- Waiting for three failed checks reduces alert noise but delays detection.
- A successful basic health check does not guarantee customers can submit requests.
- Automated test submissions could create unnecessary work for employees.
- Monitoring and notification delays must be tested against the five-minute requirement.

### Decisions Still Pending
- Confirm which application health checks are available.
- Determine how to test service-request submissions safely.
- Identify who receives alerts and through which channel.
- Validate monitoring costs and alert delivery time.

### Evidence Status
These are proposed design decisions based on fictional customer discovery. No monitoring implementation or performance testing has been completed.
