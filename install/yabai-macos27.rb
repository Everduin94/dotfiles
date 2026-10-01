# typed: strict
# frozen_string_literal: true

# Temporary pinned build for the reviewed macOS 27 Space gesture fix.
class YabaiMacos27 < Formula
  desc "Yabai with the reviewed SIP-enabled macOS 27 Space gesture fix"
  homepage "https://github.com/asmvik/yabai/issues/2822"
  url "https://github.com/asmvik/yabai/archive/dd845723416f5fe92af49fad5ebab00369e07edd.tar.gz"
  version "7.1.25-macos27.1"
  sha256 "b4b1f41bc044624ba1281ff2d132cab6456606aa9627c56ef649fc7f8f5cc5d1"
  license "MIT"

  depends_on :macos
  conflicts_with "yabai", because: "both install a yabai executable"

  # Reviewed fix from https://github.com/asmvik/yabai/issues/2822.
  # Confirmed by multiple users on macOS 27.0 build 26A428 with SIP enabled.
  patch do
    url "https://github.com/YazeedAlKhalaf/yabai/commit/9d6104a01fcba61ab4a19e5c19931da9efc76a7a.patch?full_index=1"
    sha256 "783e24b5adb0be6a3947f9de715a916d4b9ad771e6409d0cea1ed79e52221985"
  end

  def install
    system "make", "-j1", "install"
    system "codesign", "--force", "--sign", "-", "bin/yabai"

    bin.install "bin/yabai"
    (pkgshare/"examples").install "examples/yabairc"
    (pkgshare/"examples").install "examples/skhdrc"
    man1.install "doc/yabai.1"
  end

  def caveats
    <<~EOS
      This is a temporary, pinned build for the macOS 27 SIP-enabled Space
      switching regression. Replace it with official yabai once the fix from
      issue #2822 is released.

      Because this local build is ad-hoc signed, macOS may require yabai to be
      approved again in Privacy & Security -> Accessibility.
    EOS
  end

  test do
    assert_match "yabai-v7.1.25", shell_output("#{bin}/yabai --version")
  end
end
