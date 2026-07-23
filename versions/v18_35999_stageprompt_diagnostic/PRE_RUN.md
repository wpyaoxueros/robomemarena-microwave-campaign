# Task22 v18 Pre-Run Record

## Hypothesis

v17 failed because the VLM did not emit the two pour labels. Before changing
VLM data or relying on a partial rescue, prove that the original `35999` policy
can execute Task22's physical stages under correct primitive prompts.

## Single Change

The v18 evaluator replaces the prompt source with the diagnostic stage schedule
only. Stage transitions still require the latest remote physical checks; the
cookies transition requires the recorded EEF target, not an object anchor.

## Non-Goal

This run cannot be reported as VLM-autonomous success. It only determines
whether the following VLM-owned rescue can safely be limited to missing prompts
instead of replacing the whole policy stack.
