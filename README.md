<div align="center">
    <img src="Ice/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" width=200 height=200>
    <h1>Ice</h1>
</div>

Ice is a powerful menu bar management tool. While its primary function is hiding and showing menu bar items, it aims to cover a wide variety of additional features to make it one of the most versatile menu bar tools available.

![Banner](https://github.com/user-attachments/assets/4423085c-4e4b-4f3d-ad0f-90a217c03470)

[![Download](https://img.shields.io/github/v/release/Zak-Roz/Ice?label=download&style=flat-square)](https://github.com/Zak-Roz/Ice/releases/latest)
![Platform](https://img.shields.io/badge/platform-macOS-blue?style=flat-square)
![Requirements](https://img.shields.io/badge/requirements-macOS%2014%2B-fa4e49?style=flat-square)
[![License](https://img.shields.io/github/license/Zak-Roz/Ice?style=flat-square)](LICENSE)

> [!IMPORTANT]
> **This is a community fork of [jordanbaird/Ice](https://github.com/jordanbaird/Ice) that works on macOS 27.**
> The original project has not had a release since macOS 27 broke it. This fork builds on the
> original author's unreleased `macos-26` work and the macOS 27 port by
> [@RabenkoYevhenii](https://github.com/RabenkoYevhenii) ([jordanbaird/Ice#995](https://github.com/jordanbaird/Ice/pull/995)),
> with fixes from the people testing it. Report problems with this build
> [here](https://github.com/Zak-Roz/Ice/issues), not on the original issue tracker.
>
> If you like Ice, consider [sponsoring its original author](https://github.com/sponsors/jordanbaird).

## Install

### Homebrew

```sh
brew tap zak-roz/tap
brew trust --cask zak-roz/tap/ice
brew install --cask zak-roz/tap/ice
```

Homebrew 7 and later only load casks from third-party taps that you trust; `brew trust` above trusts this
one cask, not the whole tap. If the original Ice is installed through Homebrew, remove it first with
`brew uninstall --cask jordanbaird-ice`.
Your settings carry over: this build uses the same bundle identifier.

### Manual installation

Download `Ice.zip` from the [latest release](https://github.com/Zak-Roz/Ice/releases/latest) and move the unzipped app into your `Applications` folder.

### First launch

Releases are signed with this fork's own certificate but are **not notarized** by Apple, so macOS blocks
the first launch. Open **System Settings › Privacy & Security** and click **Open Anyway** next to the
message about Ice.

Ice needs **Accessibility** and **Screen Recording**. If you ran another build of Ice before, remove its
entries from both lists (select it and click **−**) and grant them again: macOS keeps a grant for the exact
signature it was given to, and a switch left over from another build looks on but does nothing. Updates of
this build keep the grants, because every release is signed with the same certificate.

### Updates

Ice checks for updates itself (Settings › About) and installs releases signed with this fork's update key.
`brew upgrade --cask --greedy ice` works too.

## On macOS 27

macOS 27 moved the menu bar items into a system process, MenuBarAgent, so the way Ice used to hide them no
longer works. On macOS 27 this build:

- **Hides whole applications.** By default it switches applications off under the "Allow in the Menu Bar"
  switches in System Settings, the same switches you can flip by hand. Ice turns them back on when it
  quits, and again the next time it starts if it was killed. If you remove Ice while it is not running,
  start it once and quit it, or turn the switches back on in System Settings. Settings › Advanced offers a
  second method that hides items through MenuBarAgent instead.
- **Arranges sections per application**: an application with several items keeps them together. The order
  of items within a section follows the menu bar; ⌘-drag them there to reorder.
- **Shows the Ice Bar** with pictures of the hidden items taken from the menu bar, which needs Screen
  Recording. Clicking an item opens it.
- **Does not offer item spacing**, which macOS 27 ignores for most items.

On macOS 14 to 26, Ice works as it always has.

## Features/Roadmap

### Menu bar item management

- [x] Hide menu bar items
- [x] "Always-hidden" menu bar section
- [x] Show hidden menu bar items when hovering over the menu bar
- [x] Show hidden menu bar items when an empty area in the menu bar is clicked
- [x] Show hidden menu bar items by scrolling or swiping in the menu bar
- [x] Automatically rehide menu bar items
- [x] Hide application menus when they overlap with shown menu bar items
- [x] Drag and drop interface to arrange individual menu bar items
- [x] Display hidden menu bar items in a separate bar (e.g. for MacBooks with the notch)
- [x] Search menu bar items
- [x] Menu bar item spacing (BETA)
- [ ] Profiles for menu bar layout
- [ ] Individual spacer items
- [ ] Menu bar item groups
- [ ] Show menu bar items when trigger conditions are met

### Menu bar appearance

- [x] Menu bar tint (solid and gradient)
- [x] Menu bar shadow
- [x] Menu bar border
- [x] Custom menu bar shapes (rounded and/or split)
- [ ] Remove background behind menu bar
- [ ] Rounded screen corners
- [ ] Different settings for light/dark mode

### Hotkeys

- [x] Toggle individual menu bar sections
- [x] Show the search panel
- [x] Enable/disable the Ice Bar
- [x] Show/hide section divider icons
- [x] Toggle application menus
- [ ] Enable/disable auto rehide
- [ ] Temporarily show individual menu bar items

### Other

- [x] Launch at login
- [x] Automatic updates
- [ ] Menu bar widgets

## Why does Ice only support macOS 14 and later?

Ice uses a number of system APIs that are available starting in macOS 14. As such, there are no plans to support earlier versions of macOS.

## Gallery

#### Show hidden menu bar items below the menu bar

![Ice Bar](https://github.com/user-attachments/assets/f1429589-6186-4e1b-8aef-592219d49b9b)

#### Drag-and-drop interface to arrange menu bar items

![Menu Bar Layout](https://github.com/user-attachments/assets/095442ba-f2d0-4bb4-9632-91e26ef8d45b)

#### Customize the menu bar's appearance

![Menu Bar Appearance](https://github.com/user-attachments/assets/8c22c185-c3d2-49bb-971e-e1fc17df04b3)

#### Menu bar item search

![Menu Bar Item Search](https://github.com/user-attachments/assets/d1a7df3a-4989-4077-a0b1-8e7d5a1ba5b8)

#### Custom menu bar item spacing

![Menu Bar Item Spacing](https://github.com/user-attachments/assets/b196aa7e-184a-4d4c-b040-502f4aae40a6)

## Building

Open `Ice.xcodeproj` in Xcode 27 and run the `Ice` scheme. Local builds are signed ad hoc, so macOS asks for
Accessibility and Screen Recording again after every build.

Unit tests for the macOS 27 logic run with `swift test`.

## Releasing

Push a tag such as `v0.12.1`. The [release workflow](.github/workflows/release.yml) builds Ice, signs it
(hardened runtime, this fork's certificate), publishes `Ice.zip` and a Sparkle `appcast.xml` to a GitHub
release, and updates the cask in [Zak-Roz/homebrew-tap](https://github.com/Zak-Roz/homebrew-tap). A tag with
a suffix, such as `v0.12.1-beta.1`, becomes a pre-release that neither Sparkle nor Homebrew offer.

## Credits

- [Jordan Baird](https://github.com/jordanbaird), who wrote Ice.
- [@RabenkoYevhenii](https://github.com/RabenkoYevhenii) for the macOS 27 port, and the testers and
  contributors on [jordanbaird/Ice#995](https://github.com/jordanbaird/Ice/pull/995), including
  @jasonsmithio, @Theralley, @carlossantos74 and Michael Yu.
- The release pipeline was informed by [cavaldos/Ice](https://github.com/cavaldos/Ice).

## License

Ice is available under the [GPL-3.0 license](LICENSE).
