# Rook

## Cluster of 3 Standard_D2s_v3 machines having 10G data disks 

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

## Cluster of 3 Standard_D2s_v3 machines having 520G data disks

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
        Random:              3,752 / 945
    Sequential:            2,003 / 1,028
  CPU Idleness:                      36%

Bandwidth in KiB/sec (Read/Write)
        Random:         243,478 / 50,182
    Sequential:         194,908 / 48,013
  CPU Idleness:                      36%

Latency in ns (Read/Write)
        Random:   3,286,926 / 23,785,866
    Sequential:   3,565,337 / 23,334,738
  CPU Idleness:                      58%
```

### run 3

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
        Random:              4,185 / 874
    Sequential:              1,939 / 945
  CPU Idleness:                      35%

Bandwidth in KiB/sec (Read/Write)
        Random:         248,741 / 52,498
    Sequential:         196,253 / 50,359
  CPU Idleness:                      31%

Latency in ns (Read/Write)
        Random:   3,385,304 / 24,696,991
    Sequential:   3,156,543 / 23,944,356
  CPU Idleness:                      60%
```

### run 4 

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
        Random:              4,121 / 857
    Sequential:              1,971 / 940
  CPU Idleness:                      36%

Bandwidth in KiB/sec (Read/Write)
        Random:         243,074 / 44,169
    Sequential:         193,588 / 44,671
  CPU Idleness:                      30%

Latency in ns (Read/Write)
        Random:   3,027,055 / 24,088,501
    Sequential:   2,975,124 / 22,944,103
  CPU Idleness:                      53%
```

### run 5

#### ceph

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
        Random:            6,108 / 1,241
    Sequential:            2,364 / 1,360
  CPU Idleness:                      51%

Bandwidth in KiB/sec (Read/Write)
        Random:         273,609 / 55,301
    Sequential:         199,709 / 55,038
  CPU Idleness:                      42%

Latency in ns (Read/Write)
        Random:   2,170,697 / 19,277,143
    Sequential:   2,678,029 / 18,493,130
  CPU Idleness:                      66%
```

#### local

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
        Random:            3,449 / 3,435
    Sequential:            4,042 / 4,043
  CPU Idleness:                      76%

Bandwidth in KiB/sec (Read/Write)
        Random:        176,626 / 197,811
    Sequential:        181,858 / 199,842
  CPU Idleness:                      76%

Latency in ns (Read/Write)
        Random:        986,032 / 984,581
    Sequential:        986,476 / 980,091
  CPU Idleness:                      77%
```

### run 6

#### ceph

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
        Random:            6,011 / 1,259
    Sequential:            2,713 / 1,537
  CPU Idleness:                      51%

Bandwidth in KiB/sec (Read/Write)
        Random:         249,121 / 65,624
    Sequential:         207,133 / 62,063
  CPU Idleness:                      38%

Latency in ns (Read/Write)
        Random:   2,643,995 / 19,387,999
    Sequential:   2,397,507 / 19,358,555
  CPU Idleness:                      72%
```

#### local

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
        Random:            3,411 / 3,163
    Sequential:            3,668 / 4,064
  CPU Idleness:                      93%

Bandwidth in KiB/sec (Read/Write)
        Random:        172,062 / 173,437
    Sequential:        175,809 / 198,995
  CPU Idleness:                      75%

Latency in ns (Read/Write)
        Random:        981,422 / 982,978
    Sequential:        981,212 / 980,000
  CPU Idleness:                      72%
```

### run 7

#### ceph

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
        Random:            6,331 / 1,337
    Sequential:            2,153 / 1,444
  CPU Idleness:                      52%

Bandwidth in KiB/sec (Read/Write)
        Random:         272,488 / 63,621
    Sequential:         219,700 / 62,038
  CPU Idleness:                      39%

Latency in ns (Read/Write)
        Random:   1,948,856 / 20,033,301
    Sequential:   3,020,260 / 18,031,163
  CPU Idleness:                      68%
```

#### local

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
        Random:            3,956 / 3,437
    Sequential:            3,741 / 4,086
  CPU Idleness:                      85%

Bandwidth in KiB/sec (Read/Write)
        Random:        167,619 / 198,430
    Sequential:        199,160 / 198,982
  CPU Idleness:                      77%

Latency in ns (Read/Write)
        Random:        983,734 / 982,065
    Sequential:        986,765 / 987,656
  CPU Idleness:                      78%
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

### run 3

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
        Random:            6,070 / 1,592
    Sequential:            2,142 / 1,576
  CPU Idleness:                      78%

Bandwidth in KiB/sec (Read/Write)
        Random:         367,727 / 68,259
    Sequential:         283,939 / 64,873
  CPU Idleness:                      72%

Latency in ns (Read/Write)
        Random:   2,981,756 / 20,505,163
    Sequential:   3,021,128 / 20,583,944
  CPU Idleness:                      87%
```

### run 4

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
        Random:            5,593 / 1,636
    Sequential:            2,156 / 1,568
  CPU Idleness:                      77%

Bandwidth in KiB/sec (Read/Write)
        Random:         401,413 / 68,591
    Sequential:         336,813 / 68,321
  CPU Idleness:                      73%

Latency in ns (Read/Write)
        Random:   2,882,205 / 19,496,418
    Sequential:   3,640,014 / 20,598,309
  CPU Idleness:                      87%
```

### run 5

#### ceph

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
        Random:            9,900 / 1,510
    Sequential:            4,968 / 1,800
  CPU Idleness:                      83%

Bandwidth in KiB/sec (Read/Write)
        Random:         302,016 / 63,415
    Sequential:         253,343 / 72,729
  CPU Idleness:                      81%

Latency in ns (Read/Write)
        Random:   2,346,406 / 20,377,493
    Sequential:   2,313,359 / 17,427,530
  CPU Idleness:                      90%
```

#### local

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
        Random:           13,696 / 6,132
    Sequential:           12,962 / 7,508
  CPU Idleness:                      92%

Bandwidth in KiB/sec (Read/Write)
        Random:        331,745 / 259,698
    Sequential:        332,695 / 258,848
  CPU Idleness:                      92%

Latency in ns (Read/Write)
        Random:        262,842 / 531,242
    Sequential:        273,775 / 532,376
  CPU Idleness:                      91%
```

### run 6

#### ceph

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
        Random:            8,805 / 1,428
    Sequential:            4,113 / 1,652
  CPU Idleness:                      83%

Bandwidth in KiB/sec (Read/Write)
        Random:         321,074 / 61,869
    Sequential:         260,488 / 71,201
  CPU Idleness:                      80%

Latency in ns (Read/Write)
        Random:   2,264,720 / 18,158,480
    Sequential:   2,261,720 / 22,455,133
  CPU Idleness:                      88%
```

#### local

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
        Random:           13,266 / 5,750
    Sequential:           12,779 / 7,508
  CPU Idleness:                      91%

Bandwidth in KiB/sec (Read/Write)
        Random:        327,275 / 251,896
    Sequential:        323,834 / 258,300
  CPU Idleness:                      92%

Latency in ns (Read/Write)
        Random:        258,104 / 532,395
    Sequential:        268,725 / 532,849
  CPU Idleness:                      89%
```

# OpenEBS

## Cluster of 3 Standard_D2s_v3 machines having 10G data disks

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
        Random:                583 / 272
    Sequential:              1,086 / 463
  CPU Idleness:                      65%

Bandwidth in KiB/sec (Read/Write)
        Random:          33,792 / 20,883
    Sequential:          45,406 / 24,075
  CPU Idleness:                      56%

Latency in ns (Read/Write)
        Random:   7,541,059 / 15,269,521
    Sequential:   7,222,059 / 16,635,017
  CPU Idleness:                      59%
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
        Random:                569 / 247
    Sequential:              1,097 / 510
  CPU Idleness:                      62%

Bandwidth in KiB/sec (Read/Write)
        Random:          35,133 / 19,757
    Sequential:          49,429 / 26,202
  CPU Idleness:                      62%

Latency in ns (Read/Write)
        Random:   7,144,839 / 14,620,555
    Sequential:   7,268,928 / 15,117,373
  CPU Idleness:                      64%
```

### run 3

#### jiva

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
        Random:                180 / 146
    Sequential:                363 / 234
  CPU Idleness:                      62%

Bandwidth in KiB/sec (Read/Write)
        Random:          14,936 / 12,933
    Sequential:          22,242 / 17,412
  CPU Idleness:                      50%

Latency in ns (Read/Write)
        Random:  14,065,368 / 23,724,930
    Sequential:  14,277,129 / 22,206,062
  CPU Idleness:                      56%
```

#### local

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
        Random:            4,084 / 3,378
    Sequential:            4,044 / 3,534
  CPU Idleness:                      73%

Bandwidth in KiB/sec (Read/Write)
        Random:        199,332 / 169,570
    Sequential:        198,884 / 169,772
  CPU Idleness:                      71%

Latency in ns (Read/Write)
        Random:      983,243 / 1,124,193
    Sequential:      979,969 / 1,122,373
  CPU Idleness:                      70%
```

### run 4

#### jiva

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
        Random:                403 / 219
    Sequential:                728 / 372
  CPU Idleness:                      71%

Bandwidth in KiB/sec (Read/Write)
        Random:          25,114 / 16,261
    Sequential:          32,281 / 21,669
  CPU Idleness:                      59%

Latency in ns (Read/Write)
        Random:  11,381,428 / 20,230,124
    Sequential:  10,798,122 / 19,800,755
  CPU Idleness:                      60%
```

#### local

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
        Random:            4,075 / 3,411
    Sequential:            4,018 / 3,563
  CPU Idleness:                      68%

Bandwidth in KiB/sec (Read/Write)
        Random:        198,832 / 166,095
    Sequential:        199,171 / 170,273
  CPU Idleness:                      71%

Latency in ns (Read/Write)
        Random:      984,506 / 1,119,923
    Sequential:      980,985 / 1,123,484
  CPU Idleness:                      69%
```

## Cluster of 3 Standard_D2s_v3 machines having 520G data disks

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
        Random:                765 / 535
    Sequential:              1,515 / 969
  CPU Idleness:                      77%

Bandwidth in KiB/sec (Read/Write)
        Random:          45,996 / 34,769
    Sequential:          64,936 / 44,653
  CPU Idleness:                      72%

Latency in ns (Read/Write)
        Random:    5,139,246 / 7,606,002
    Sequential:    4,922,650 / 7,778,861
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
        Random:                743 / 522
    Sequential:              1,432 / 966
  CPU Idleness:                      79%

Bandwidth in KiB/sec (Read/Write)
        Random:          44,536 / 34,983
    Sequential:          62,615 / 44,584
  CPU Idleness:                      72%

Latency in ns (Read/Write)
        Random:    5,332,422 / 8,926,154
    Sequential:    4,990,483 / 8,212,557
  CPU Idleness:                      80%
```

### run 3

#### jiva

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
        Random:                282 / 259
    Sequential:                548 / 491
  CPU Idleness:                      74%

Bandwidth in KiB/sec (Read/Write)
        Random:          22,476 / 19,586
    Sequential:          33,210 / 23,639
  CPU Idleness:                      67%

Latency in ns (Read/Write)
        Random:   7,715,235 / 11,550,736
    Sequential:   7,599,625 / 11,428,751
  CPU Idleness:                      70%
```

#### local

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
        Random:            4,077 / 4,083
    Sequential:            4,079 / 4,064
  CPU Idleness:                      88%

Bandwidth in KiB/sec (Read/Write)
        Random:        198,910 / 197,744
    Sequential:        198,957 / 199,859
  CPU Idleness:                      84%

Latency in ns (Read/Write)
        Random:        985,205 / 991,146
    Sequential:        989,599 / 980,328
  CPU Idleness:                      86%
```

### run 4

#### jiva

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
        Random:                985 / 578
    Sequential:            1,779 / 1,005
  CPU Idleness:                      76%

Bandwidth in KiB/sec (Read/Write)
        Random:          47,096 / 33,803
    Sequential:          66,398 / 41,837
  CPU Idleness:                      74%

Latency in ns (Read/Write)
        Random:    4,309,644 / 7,420,274
    Sequential:    4,169,770 / 7,252,073
  CPU Idleness:                      76%
```

#### local

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
        Random:            4,082 / 3,927
    Sequential:            4,041 / 4,054
  CPU Idleness:                      83%

Bandwidth in KiB/sec (Read/Write)
        Random:        199,432 / 199,635
    Sequential:        199,127 / 199,089
  CPU Idleness:                      85%

Latency in ns (Read/Write)
        Random:        980,206 / 980,906
    Sequential:        983,644 / 985,772
  CPU Idleness:                      85%
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
        Random:                149 / 127
    Sequential:                306 / 244
  CPU Idleness:                      85%

Bandwidth in KiB/sec (Read/Write)
        Random:          16,091 / 14,857
    Sequential:          27,279 / 19,776
  CPU Idleness:                      79%

Latency in ns (Read/Write)
        Random:   8,348,068 / 16,195,546
    Sequential:   8,099,740 / 16,266,047
  CPU Idleness:                      81%
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
        Random:                163 / 125
    Sequential:                311 / 237
  CPU Idleness:                      87%

Bandwidth in KiB/sec (Read/Write)
        Random:          16,038 / 14,839
    Sequential:          27,061 / 20,892
  CPU Idleness:                      80%

Latency in ns (Read/Write)
        Random:   8,352,943 / 15,838,018
    Sequential:   8,027,652 / 15,738,814
  CPU Idleness:                      84%
```

### run 3

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
        Random:                154 / 130
    Sequential:                317 / 263
  CPU Idleness:                      95%

Bandwidth in KiB/sec (Read/Write)
        Random:          17,444 / 16,387
    Sequential:          29,502 / 23,082
  CPU Idleness:                      91%

Latency in ns (Read/Write)
        Random:   5,219,870 / 10,887,548
    Sequential:   5,859,156 / 10,827,253
  CPU Idleness:                      91%
```

### run 4

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
        Random:                154 / 132
    Sequential:                392 / 258
  CPU Idleness:                      94%

Bandwidth in KiB/sec (Read/Write)
        Random:          16,995 / 16,106
    Sequential:          31,296 / 20,555
  CPU Idleness:                      90%

Latency in ns (Read/Write)
        Random:   5,907,461 / 11,519,162
    Sequential:   5,389,604 / 11,519,820
  CPU Idleness:                      90%
```

### run 5

#### jiva
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
        Random:                150 / 133
    Sequential:                341 / 265
  CPU Idleness:                      94%

Bandwidth in KiB/sec (Read/Write)
        Random:          16,650 / 15,986
    Sequential:          31,435 / 21,169
  CPU Idleness:                      91%

Latency in ns (Read/Write)
        Random:   6,940,498 / 13,482,968
    Sequential:   6,682,318 / 13,668,829
  CPU Idleness:                      92%
```

#### local

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
        Random:           15,933 / 7,405
    Sequential:           16,068 / 7,527
  CPU Idleness:                      93%

Bandwidth in KiB/sec (Read/Write)
        Random:        399,357 / 306,860
    Sequential:        394,431 / 258,002
  CPU Idleness:                      95%

Latency in ns (Read/Write)
        Random:        244,612 / 532,910
    Sequential:        245,417 / 532,942
  CPU Idleness:                      94%
```

### run 6

#### jiva

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
        Random:                153 / 129
    Sequential:                306 / 258
  CPU Idleness:                      92%

Bandwidth in KiB/sec (Read/Write)
        Random:          16,782 / 15,920
    Sequential:          28,405 / 22,953
  CPU Idleness:                      91%

Latency in ns (Read/Write)
        Random:   7,260,800 / 15,312,169
    Sequential:   6,676,476 / 12,953,619
  CPU Idleness:                      92%
```

#### local

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
        Random:           16,153 / 7,436
    Sequential:           16,311 / 7,508
  CPU Idleness:                      95%

Bandwidth in KiB/sec (Read/Write)
        Random:        396,654 / 310,952
    Sequential:        399,047 / 256,392
  CPU Idleness:                      95%

Latency in ns (Read/Write)
        Random:        245,664 / 532,730
    Sequential:        245,248 / 532,375
  CPU Idleness:                      93%
```
