**Benchmarks Summary**

All times normalized to milliseconds (ms).

| Benchmark | Precise-DF (ms) | SPIN (ms) |
|---|---:|---:|
| MSI | 0.142709 | 0 |
| MSI_2copies | 0.68246 | 0 |
| MSI_4copies | 6.02405 | 10 |
| Broadcast | 2.05846 | 0 |
| Broadcast_2copies | 43.4435 | 20 |
| Broadcast_4copies | 4978.54 | 520 |
| Mutex | 0.897335 | 0 |
| Mutex_2copies | 23.4759 | 10 |
| Mutex_4copies | 549.487 | 10 |
| Mutexu | 1.39621 | 0 |
| Mutexu_2copies | 47.6465 | 0 |
| Mutexu_4copies | 1145.29 | 10 |
| Storage | 1292.14 | 0 |
| Storage_2copies | Timeout | 8690 |
| Storage_4copies | N/A | Timeout |

Notes:
- SPIN times originally had mixed units (e.g., `0.01 s`); I converted all SPIN values to milliseconds for consistency (`0.01 s` → `10 ms`, `0.52 s` → `520 ms`, `0.02 s` → `20 ms`).
- Zeros indicate either very small (rounded) times in the original file or missing measurements.
