#!/usr/bin/env python3
"""Inject CPU and memory stress to simulate a failure scenario."""
import subprocess, sys, time, json

def inject_failure(duration=30):
    """Run stress-ng to cause CPU and memory pressure."""
    print(f"Injecting failure: CPU + memory stress for {duration}s...")
    start = time.time()
    try:
        proc = subprocess.run(
            ["stress-ng", "--cpu", "2", "--vm", "1", "--vm-bytes", "256M",
             "--timeout", f"{duration}s", "--metrics-brief"],
            capture_output=True, text=True, timeout=duration + 10
        )
        elapsed = round(time.time() - start, 1)
        result = {
            "type": "stress_injection",
            "duration_seconds": elapsed,
            "cpu_stressors": 2,
            "memory_stressors": 1,
            "memory_bytes": "256M",
            "exit_code": proc.returncode,
            "stderr": proc.stderr.strip()[-500:] if proc.stderr else ""
        }
    except subprocess.TimeoutExpired:
        elapsed = round(time.time() - start, 1)
        result = {
            "type": "stress_injection",
            "duration_seconds": elapsed,
            "status": "timeout",
            "exit_code": -1
        }
    except FileNotFoundError:
        result = {
            "type": "stress_injection",
            "status": "error",
            "message": "stress-ng not found. Install with: apt-get install -y stress-ng",
            "exit_code": -1
        }

    print(json.dumps(result, indent=2))
    return result

if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    inject_failure(duration)
