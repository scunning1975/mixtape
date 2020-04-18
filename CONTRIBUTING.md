# Contributing

Thank you for considering giving feedback or contributing to this project.

There are two ways you can contribute to this repository:

1. **Creating or commenting on issues**: If you spot a mistake or notice inconsistencies, please feel free to create a new issue [here](https://github.com/scunning1975/mixtape/issues). You are also welcome to read through the issues submitted by others and to contribute to the discussion.
1. **Proposing changes**: If you are familiar with how GitHub works (or are willing to try), you can submit a pull request with any additions or modifications to the files in this repository.

For more details on contributing via GitHub, read through the sections below.

## Contributing through GitHub

To open issues or pull requests, you will need to create an account on <https://github.com/>. For pull request, you will also need to have [set up Git](https://happygitwithr.com/install-git.html) on your local machine.

### Creating or commenting on issues

Issues are places to track ideas, enhancements, tasks, and to report errors or bugs. To create a new issue:

1. Go to [the issues tab](https://github.com/scunning1975/mixtape/issues).
1. Search the already posted issues to see if the feedback you are about to give is already posted.
1. If your feedback has not already been brought up, please press the green *New Issue* button to post a new issue.

### Proposing changes via pull requests

Changes or additions to files are made via *pull requests* or PRs. For major changes, please open an issue first to discuss what you would like to change.

To create a pull request, you will need to:

1. Create a [fork of this repository](https://github.com/scunning1975/mixtape/fork). Forking a repository allows you to freely experiment with changes without affecting the original project.
1. [Clone](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) your fork to your local machine.
  ```bash
  git clone https://github.com/<YOUR-GITHUB-USERNAME>/mixtape.git
  ```
1. Create and switch to a new branch. Make your changes. Commit, and push.
  ```bash
  git checkout -b new-branch
  # Make your changes
  git add "file-that-changed.do"
  git commit -m "The commit message"
  git push origin new-branch
  ```
1. Navigate back to GitHub. You will see a yellow banner near the top of your repository. Click on *Compare & Pull Request*. If your pull request closes an issue, add `Fixes #<ISSUE-NUMBER>` to the body of the PR so the issue is automatically closed once the PR is accepted.
