# V130 Batch Cancellation: Node Topology

The initial V130 batch `task21_v130_fixedseed107_repeat20_20260722_151706`
was cancelled before any completed episode was accepted.

The five independent workers were allocated to four physical nodes because two
workers were packed onto `ACD1-11`. This did not satisfy the requested
five-node execution topology. The replacement V131 launcher requests one
five-node allocation with one worker per node. No score from the cancelled
batch is reported or aggregated.
