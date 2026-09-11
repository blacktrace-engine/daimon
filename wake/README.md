# Wake surface

Changes under this directory are explicit external wake events for the reference Daimon controller.

A wake event does not itself establish any claimed outcome. It only causes a fresh worker to reconstruct durable identity state, execute within the runtime contract, verify the requested postcondition externally, and persist a new state generation if verification succeeds.

This file intentionally exercised the wake path after introduction of the append-only lineage journal, proving that a subsequent generation links to the preceding history record.
