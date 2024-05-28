# bazzite-mesa

This repo builds a [Bazzite](https://github.com/ublue-os/bazzite) image where
the version of Mesa comes directly from the main branch, rather than a full
release.

The motivation for this is to have the bleeding-edge NVK (Nvidia) driver
present in my system.

## What's in this repo?

- `.github/workflows/build.yaml`: GitHub Actions workflow to build everything
- `Containerfile`: defines how to build the image. We just use an upstream
  Bazzite image then `rpm-ostree override replace ...` with the freshly built
  Mesa RPMs.
- `README.md`: That's this file 😄
- `mesa.spec` + everything else: taken from
  https://github.com/ublue-os/bazzite/tree/main/spec_files/mesa and slightly
  modified to allow building Mesa directly from git.

## I like breaking my computer too! How can I use this?

As seen in the GitHub Actions workflow, this image is pushed to:

`eu.gcr.io/trouter-public/aaron-trout/bazzite-mesa:latest`

If you want to use it:

- First make sure you are already using the Gnome flavour of Bazzite
  - (I am only building the Gnome flavour right now, because that's what I use)
- Have a hard think and decide you are really sure! This is an unreleased version
  of Mesa built by some random dude on the internet, do you trust it? There
  is no warranty 🙃 Things could break.
- `rpm-ostree rebase ostree-unverified-image:docker://eu.gcr.io/trouter-public/aaron-trout/bazzite-mesa:latest`
  - (The image is not signed, hence the `ostree-unverified-image` prefix)
