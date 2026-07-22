# V132 Batch Cancellation: Additional Slow Node

V132 correctly excluded `ACD1-39` and `ACD1-40`, but its five-node allocation
included `ACD1-1`. The same seed107 rollout showed the same sustained roughly
20-second first VLA chunk on `ACD1-1`; the other allocated nodes progressed at
the historical sub-second chunk rate.

The batch was cancelled before a completed episode was accepted because one
slow worker would make the four-repeat worker exceed the allocation time.
V133 pins the five nodes that have now directly demonstrated the expected
rollout speed: `ACD1-3`, `ACD1-4`, `ACD1-6`, `ACD1-9`, and `ACD1-38`.
No score from V132 is reported or aggregated.
