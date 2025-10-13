# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

.config is a collection of directories whose contents contain configurations of
various tools. It should be simple, maintainable, and extensible.

## Development Commands

### Setup

install [`just`](https://just.systems/)

### Running the Application

```bash
just
```

## Architecture

### High-Level Structure

- each directory under this project's root should configure a tool.
- running this project should sync the contents of this project's directories
  with the *some* of the contents of a configured directory that defaults to
  the path `$HOME/.config/`. That is after running this project, the contents
  of this project's directories should be in the configured directory. The
  contents of the configure directory should not necessarily be 1-1 with the
  contents of this project.

### Key Components

- directories
  - each directory in this project contains configuration for a tool. Like
  neovim, fish, or wezterm.
- links
  - the contents of this project and the contents of a configured direcotry
  should be synced using linked files via `ln -s`.
- just
  - just is a command runner with shell scripts that sync contents.
