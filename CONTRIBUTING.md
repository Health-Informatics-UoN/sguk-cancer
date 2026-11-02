# Contributing

## Making a change

1. Create a branch from `main`.
2. Make your change and open a pull request.
3. Give the pull request a title in [Conventional Commits](https://www.conventionalcommits.org/) format. A check on the pull request enforces this.
4. Merge the pull request. The pull request title becomes the commit message on `main`.

## Releases

Releases are automatic. On each push to `main`, the release workflow:

1. Reads the new commit messages.
2. Calculates the next version.
3. Creates a git tag (for example `0.3.0`, with no `v` prefix).
4. Creates a GitHub release with notes from the commits.

Nothing in the code holds a version number. The git tag is the version.

