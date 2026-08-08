# Vendor directory

`scripts/bootstrap.sh` clones [open-wearables](https://github.com/the-momentum/open-wearables)
into `vendor/open-wearables` at a pinned revision recorded in `OPEN_WEARABLES_PIN.txt`.

That clone is gitignored — it is upstream source, not part of this glue repo.
