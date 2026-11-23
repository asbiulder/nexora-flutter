#!/usr/bin/env python3
"""Retired Finger Soccer owner-asset importer.

This file intentionally does not modify assets. The old importer restored seven obsolete fields, twelve obsolete balls,
and incomplete v11 badge crops, violating the final owner catalogue contract.

Use ``tool/build_fs_v12_owner_assets.py <upload-directory>`` for the 174 final transparent team discs. The sole v12
Sockerbox field and four v12 NX balls are checked-in source-of-truth assets and must not be replaced by this legacy
workflow.
"""

raise SystemExit(
    'Retired importer: use tool/build_fs_v12_owner_assets.py <upload-directory>; '
    'the final field and four balls are already tracked assets.'
)
