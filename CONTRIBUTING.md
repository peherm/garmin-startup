# Contributing

This is a personal project, but the workflow below is followed consistently
by the maintainer (and any AI coding agent acting on the repo).

## Workflow

1. **Documentation-first.** When you change behavior, update the relevant
   `.md` files (`README.md`, `ARCHITECTURE.md`, `PLAN.md`, `RUNBOOK.md`,
   `CHANGELOG.md`) **in the same commit** as the code change.
2. **Atomic commits.** One logical change per commit. Don't bundle unrelated
   work.
3. **Conventional Commits.** Use one of:
   `feat:`, `fix:`, `chore:`, `ci:`, `docs:`, `refactor:`, `test:`, `perf:`.
   Add a scope when useful, e.g. `fix(ci): ...`.
4. **Keep CI green.** Every push to `main` runs the build job. A failing
   build should be fixed (or reverted) before moving on.

## Local Development

See [RUNBOOK.md](RUNBOOK.md) for environment setup, building, simulating, and
sideloading.

## Cutting a Release

Releases are published automatically when a `v*` tag is pushed. The full
procedure (bash and PowerShell variants) is in
[RUNBOOK.md](RUNBOOK.md#cutting-a-release).

Short version:

```bash
./scripts/update_version.sh 0.1.3
git add -A && git commit -m "chore(release): v0.1.3"
git tag v0.1.3
git push && git push --tags
```

## Reporting Issues

Use the GitHub issue templates under
[.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE) — bug report or feature
request.

## License

By contributing, you agree your contribution is licensed under the same terms
as the rest of the repository (see [LICENSE](LICENSE)).
