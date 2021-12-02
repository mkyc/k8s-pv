# Rook

## Cluster of 3 Standard_D2s_v2 machines having 10G data disks 

```
TEST_FILE: /volume/test
TEST_OUTPUT_PREFIX: test_device
TEST_SIZE: 2G
Benchmarking iops.fio into test_device-iops.json
Benchmarking bandwidth.fio into test_device-bandwidth.json
Benchmarking latency.fio into test_device-latency.json

=====================
FIO Benchmark Summary
For: test_device
SIZE: 2G
QUICK MODE: DISABLED
=====================
IOPS (Read/Write)
        Random:              3,251 / 670
    Sequential:              1,486 / 720
  CPU Idleness:                      32%

Bandwidth in KiB/sec (Read/Write)
        Random:          12,261 / 13,263
    Sequential:          11,295 / 16,142
  CPU Idleness:                      72%

Latency in ns (Read/Write)
        Random:   2,477,795 / 23,194,670
    Sequential:   3,812,515 / 19,584,030
  CPU Idleness:                      48%
```

## Cluster of 3 Standard_D2s_v2 machines having 520G data disks

```
TEST_FILE: /volume/test
TEST_OUTPUT_PREFIX: test_device
TEST_SIZE: 2G
Benchmarking iops.fio into test_device-iops.json
Benchmarking bandwidth.fio into test_device-bandwidth.json
Benchmarking latency.fio into test_device-latency.json

=====================
FIO Benchmark Summary
For: test_device
SIZE: 2G
QUICK MODE: DISABLED
=====================
IOPS (Read/Write)
        Random:            5,502 / 1,043
    Sequential:            2,048 / 1,000
  CPU Idleness:                      36%

Bandwidth in KiB/sec (Read/Write)
        Random:           11,357 / 8,482
    Sequential:            8,321 / 9,489
  CPU Idleness:                      79%

Latency in ns (Read/Write)
        Random:   1,582,506 / 19,940,795
    Sequential:   2,396,627 / 18,736,267
  CPU Idleness:                      61%
```

## Cluster of 3 Standard_D8s_v3 machines having 520G data disks

### run 1
```
TEST_FILE: /volume/test
TEST_OUTPUT_PREFIX: test_device
TEST_SIZE: 2G
Benchmarking iops.fio into test_device-iops.json
Benchmarking bandwidth.fio into test_device-bandwidth.json
Benchmarking latency.fio into test_device-latency.json

=====================
FIO Benchmark Summary
For: test_device
SIZE: 2G
QUICK MODE: DISABLED
=====================
IOPS (Read/Write)
        Random:            7,127 / 1,665
    Sequential:            2,220 / 1,661
  CPU Idleness:                      73%

Bandwidth in KiB/sec (Read/Write)
        Random:          12,112 / 11,063
    Sequential:           19,063 / 9,880
  CPU Idleness:                      83%

Latency in ns (Read/Write)
        Random:   2,399,861 / 19,015,768
    Sequential:   2,797,465 / 19,399,847
  CPU Idleness:                      78%
```
### run 2
```
TEST_FILE: /volume/test
TEST_OUTPUT_PREFIX: test_device
TEST_SIZE: 2G
Benchmarking iops.fio into test_device-iops.json
Benchmarking bandwidth.fio into test_device-bandwidth.json
Benchmarking latency.fio into test_device-latency.json

=====================
FIO Benchmark Summary
For: test_device
SIZE: 2G
QUICK MODE: DISABLED
=====================
IOPS (Read/Write)
        Random:           10,177 / 1,715
    Sequential:            5,086 / 1,774
  CPU Idleness:                      85%

Bandwidth in KiB/sec (Read/Write)
        Random:         379,670 / 74,624
    Sequential:         332,010 / 61,974
  CPU Idleness:                      83%

Latency in ns (Read/Write)
        Random:   1,945,113 / 19,704,932
    Sequential:   1,949,226 / 17,767,582
  CPU Idleness:                      92%
```