import urllib.request
from urllib.error import HTTPError, URLError
import sys

URL = "http://localhost"
STATE_FILE = "/var/lib/northstar-monitoring/failure_count.txt"
FAILURE_THRESHOLD = 3

def read_failure_count():
    try:
        with open(STATE_FILE, "r") as file:
            return int(file.read().strip())
    except FileNotFoundError:
        return 0

def write_failure_count(count):
    with open(STATE_FILE, 'w') as file:
        file.write(str(count))

def report_failure(reason, count):
    if count >= FAILURE_THRESHOLD:
        print(f"CRITICAL: {reason} - {count} consecutive failures")
    else:
        print(f"WARNING: {reason} - failure {count} of {FAILURE_THRESHOLD}")

failure_count = read_failure_count()

try:
    response = urllib.request.urlopen(URL, timeout=5)

    if response.status == 200:
        print("HEALTHY: Apache is responding")
        write_failure_count(0)
        sys.exit(0)
    else:
        failure_count += 1
        write_failure_count(failure_count)
        sys.exit(1)

except HTTPError as error:
    failure_count += 1
    write_failure_count(failure_count)
    report_failure(f"HTTP {error.code}", failure_count)
    sys.exit(1)

except TimeoutError as error:
    failure_count += 1
    write_failure_count(failure_count)
    report_failure(f"Request timed out: {error}", failure_count)
    sys.exit(1)

except URLError as error:
    failure_count += 1
    write_failure_count(failure_count)
    report_failure(f"Connection error: {error}", failure_count)
    sys.exit(1)
