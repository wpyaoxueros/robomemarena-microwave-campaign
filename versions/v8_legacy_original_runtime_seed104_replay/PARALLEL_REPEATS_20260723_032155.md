# Task22 v8 Parallel Seed104 Repeats

## Contract

Three independent processes reused the exact v8 original-runtime snapshot and
the same Task22 seed104 inputs. No oracle prompt injection was enabled.

## Results

| Run ID | Node | Legacy CSR | Legacy TSR |
| --- | --- | ---: | ---: |
| `20260723_032155` | ACD1-8 | 66.7 | 0 |
| `20260723_032226` | ACD1-24 | 66.7 | 0 |
| `20260723_032256` | ACD1-2 | 66.7 | 0 |

All three completed the first four legacy stages and failed the cookies and
close stages. None is a historical six-stage reproduction.

## Evidence Hashes

| Run ID | Summary SHA256 | Main video SHA256 | Sync log SHA256 |
| --- | --- | --- | --- |
| `20260723_032155` | `0a4847fdec6a9c6961445ab7b367922c6f18d8b81a430755b375553abf423b86` | `507d88fa62243feda6c2addae29b1150f569403656c0a2ef08e80c642e5f035c` | `1fe9514d9f5b0bf79253d40671d4ca19ec72bc94f7aac0901b1262ab1b8afc5b` |
| `20260723_032226` | `6c05ffd95dd8d2c500ee8b524f5188174c05cc02c822adb146f75879f341eb99` | `a66bc2b67006fcd91a1c327028767db454b4d0c5deb9ad76a89d312a5096fb9f` | `ca714bc4ca35d596d162277b1fc0a04e3637716b9e11e8e4d2740a34339ce53d` |
| `20260723_032256` | `8aea2f280f19b6bff47e51b9031806e9754399b69f8fdd92c20f07a7f5de13b5` | `9b8a724aa19e1f158e8d71806c4a51cee81d2d77e13da9efe2d0b0a7aa6577b4` | `9994b415622599bcaf585b84773c46c597c44e1695fe179514b5cc7506dc5833` |

The original-node v9 watcher remains the next controlled test.
