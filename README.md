# Continuation Orb
[![CircleCI Build Status](https://circleci.com/gh/CircleCI-Public/continuation-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/CircleCI-Public/continuation-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/circleci/continuation.svg)](https://circleci.com/orbs/registry/orb/circleci/continuation) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/CircleCI-Public/continuation-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

Makes requests to the continuation API for setup workflows.

## Resources

[CircleCI Orb Registry Page](https://circleci.com/orbs/registry/orb/circleci/continuation) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/2.0/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

### How to Contribute

We welcome [issues](https://github.com/CircleCI-Public/continuation-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/continuation-orb/pulls) against this repository!

### How to Publish An Update
1. Merge pull requests with desired changes to the main branch.
    - For the best experience, squash-and-merge and use [Conventional Commit Messages](https://conventionalcommits.org/).
2. Find the current version of the orb.
    - You can run `circleci orb info circleci/continuation | grep "Latest"` to see the current version.
3. Create a [new Release](https://github.com/CircleCI-Public/continuation-orb/releases/new) on GitHub.
    - Click "Choose a tag" and _create_ a new [semantically versioned](http://semver.org/) tag. (ex: v1.0.0)
      - We will have an opportunity to change this before we publish if needed after the next step.
4.  Click _"+ Auto-generate release notes"_.
    - This will create a summary of all of the merged pull requests since the previous release.
    - If you have used _[Conventional Commit Messages](https://conventionalcommits.org/)_ it will be easy to determine what types of changes were made, allowing you to ensure the correct version tag is being published.
5. Now ensure the version tag selected is semantically accurate based on the changes included.
6. Click _"Publish Release"_.
    - This will push a new tag and trigger your publishing pipeline on CircleCI.
