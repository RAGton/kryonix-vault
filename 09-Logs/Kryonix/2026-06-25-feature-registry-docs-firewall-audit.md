---
title: Feature registry, gaming docs, and firewall overlap audit
date: 2026-06-25
project: Kryonix
type: log
status: completed
---

# Feature registry, gaming docs, and firewall overlap audit

## Summary

Completed the documentation and audit follow-up batch after the canonical feature foundation merge.

## Merged PRs

| PR | Scope | Result |
|---:|---|---|
| #107 | Feature Registry audit | merged + validated |
| #108 | Legacy gamer docs cleanup | merged + validated |
| #109 | Firewall feature overlap audit | merged + validated |

## Outcomes

- `registry.nix` now documents feature metadata status more accurately.
- `docs/FEATURE_REGISTRY.md` documents the registry contract.
- Active docs now use canonical `gaming` instead of `gamer` / `profile-gamer`.
- `docs/FIREWALL_FEATURE_AUDIT.md` documents the overlap between `security.firewall` and `network.firewall.strict`.

## Firewall status

No firewall runtime behavior was changed.

Current architectural direction:

- `network.firewall.strict` is the recommended future canonical firewall feature.
- `security.firewall` should be treated as a candidate for legacy/compat/deprecation.
- Any future migration must preserve SSH, Tailscale, bridge/VLAN, libvirt and installer/live ISO safety.

## Remaining work

1. Design a firewall migration plan.
2. Define compat/deprecation path for `security.firewall`.
3. Add safety defaults for SSH/Tailscale/bridge/libvirt.
4. Use `nixos-rebuild test` before any `switch` in real hosts.
5. Continue feature migrations only after sensitive network decisions are explicit.
