# Contributing

Thanks for helping with FlClash. This page covers what you need to build the app, run the checks CI runs, and write a
commit the repository accepts. For how the code is laid out, read [docs/architecture.md](docs/architecture.md).

## What you need

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47. Release builds use 3.47.4, and a local SDK on another
  3.47 patch works.
- [Go](https://go.dev/dl/) 1.27 for the core, and [Rust](https://rustup.rs/) through rustup for the native libraries.
  Go is needed even for `flutter test`, because a build hook compiles the core.
- On Windows and Linux, `cargo` as well; the privileged Helper is built with it.
- Platform extras: the Android SDK with the NDK, GCC and Inno Setup on Windows, Xcode and Node.js on macOS,
  `libayatana-appindicator3-dev` on Linux. [README](README.md#build-from-source) has the table.

Clone with submodules, because the Xray-core sources live in `core/Xray-core/`:

```bash
git clone --recursive https://github.com/wyusgw/FlClash.git
cd FlClash
flutter pub get
```

## Run the app

```bash
flutter run
```

A development build takes over the machine exactly like a release: it creates the TUN device, sets the system proxy,
and on macOS rewrites the system DNS. To try the app without any of that, start it in **safe mode**:

```bash
flutter run --dart-define=SAFE_MODE=true
```

Safe mode keeps the host changes off: no TUN device, no system proxy or system DNS change, no login item and no global
hotkeys. The window is bannered `SAFE MODE`, and the settings keep their values.

To build installable packages, use `setup.dart`:

```bash
dart setup.dart macos      # or windows, linux, android
```

The Go core and the Rust libraries are compiled by a Flutter build hook, and are rebuilt only when their sources change.
To force a rebuild, delete `.dart_tool/setup_build_cache`.

## Generated code

Run code generation after you change a model, a provider or the database schema, and commit the output:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Do not edit generated files by hand: `lib/models/generated/`, `lib/providers/generated/`, `lib/database/generated/` and
`lib/l10n/`. Strings live in `arb/intl_{en,zh_CN,ja,ru}.arb`; add a key to **all four**, then regenerate with
`dart run intl_utils:generate`.

## Style

The lint rules are in `lint_options.yaml`, and every package in the repository includes them. The ones you will notice:
single quotes, trailing commas, `child:` last in a widget's arguments, no `print()`, `const` and `final` wherever
possible, and declared return types.

Format with `dart format` before you commit; CI fails on a file that is not formatted.

**Corners are superellipses.** Use the shapes from `lib/common/shape.dart` (`AppShape` and `AppRadius`), and not
`RoundedRectangleBorder`, `StadiumBorder`, `ClipRRect`, `drawRRect` or `BoxDecoration.borderRadius`.
`test/lint/superellipse_corners_test.dart` fails on them.

**Comments carry what the code cannot say.** Keep a comment for a constraint that is not obvious, an upstream behavior you
work around, or a reason a reader would get wrong. Do not restate what the code does or narrate your change. The
`comment-density` hook rejects a file whose added lines are more than 5% standalone comments (changes under 20 added lines
are never checked). Raise the ceiling for one commit with `COMMENT_DENSITY_MAX=20 git commit` when a change really needs it.

## Tests and checks

Use `flutter test`, not `dart test`, because the models pull in Flutter types:

```bash
flutter test                       # everything in test/
flutter test test/models/          # one directory
```

Before you open a pull request, run what CI runs:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool plugins setup.dart
flutter analyze --no-fatal-infos
flutter test
bash tool/check_plugins.sh         # analyzes and tests every package under plugins/
```

The Go core has its own tests:

```bash
cd core
CGO_ENABLED=0 go test .
CGO_ENABLED=0 go vet .
```

Native Android, Windows Helper and macOS code is compiled by CI on every push; it cannot be proven by `flutter test`, so
try those paths on a real device when you change them. The coverage gate is 75%.

## Commit messages

Subjects follow [Conventional Commits](https://www.conventionalcommits.org/) and are checked by a `commit-msg` hook:

```text
<type>[(scope)][!]: <description>
```

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- The scope is optional and lower case; list several with a comma, as in `fix(core,android)`.
- `!` before the colon marks a breaking change, and needs a `BREAKING CHANGE:` footer.
- The description starts in lower case, has no trailing period, and keeps the whole subject within 100 characters.
- Say what the change does, not that something changed: `perf(views): stop redoing per-frame work in build`, not
  `Optimize more details`.

Install the hooks once:

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg
```

### Release notes come from the commit message

The changelog is built from the history by `tool/changelog.dart`, so a `Changelog:` trailer is the text users read:

```text
feat(profiles): support per-profile override script

Changelog: Per-profile override scripts
```

- `feat`, `fix`, `perf`, `revert` and breaking commits are collected. Any other type is left out unless it carries a
  `Changelog:` trailer.
- `Changelog: skip` leaves a commit out.
- The changelog is English only; do not add translated trailers.
- `Changelog-Type:` moves an entry into another group (`breaking`, `feat`, `fix`, `perf` or `revert`).

A follow-up to a change that has not shipped in a stable release can be a `git commit --fixup=<commit>`.

## Releasing

`tool/release.sh` drives a release so the order cannot go wrong by hand; `--dry-run` prints the plan and the notes
without changing anything:

```bash
tool/release.sh pre --dry-run      # a pre-release tag, vX.Y.Z-pre.N
tool/release.sh stable --push      # changelog, chore(release) commit, tag, push
```

The release commit comes before the tag, so the generated wording can be reviewed in the diff. The tag then starts the
release workflow in `.github/workflows/build.yaml`, which builds every package and publishes them with the notes. Push
the tag by name; `--follow-tags` skips lightweight tags.

Each package is also uploaded without its version in the name (`FlClash-android-arm64-v8a.apk` beside
`FlClash-0.9.3-android-arm64-v8a.apk`), by `tool/release_aliases.sh`. The download buttons in the READMEs link to
`releases/latest/download/FlClash-<name>`, so they follow every release without being edited. To add the copies to a release
that was published without them, run the `release-aliases` workflow from the Actions tab.

## Reporting a problem

Use [GitHub Issues](https://github.com/wyusgw/FlClash/issues). Say which platform and version you run, the steps that
lead to it, and attach the log from **Data → Logs → Export logs**.
