class LeafProxy < Formula
  desc "Lightweight and fast proxy utility"
  homepage "https://github.com/eycorsican/leaf"
  url "https://github.com/eycorsican/leaf/archive/v0.4.4.tar.gz"
  sha256 "6ce46ba0eb4b357fccc36b3be5bdab32dd6879b53130a496b7a8790a47b14f26"
  license "Apache-2.0"
  head "https://github.com/eycorsican/leaf.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "acc4a8c8487712d5db2a72194e2c4b03cdd75213a5fecc633506fbc21aa29a10"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "e7ef8f08738a67a5265628383a21ab6414fdfd28b5e2f115dd53a88891d2419a"
    sha256 cellar: :any_skip_relocation, monterey:       "bf017ba320a47d0c6fc3f0a6168eecc192f39cfd98b689e663dbbfe081273fa6"
    sha256 cellar: :any_skip_relocation, big_sur:        "d4d7310f34443db217c7a2e23a7f71e252d19be4a944f926e55c5e786858ce44"
    sha256 cellar: :any_skip_relocation, catalina:       "342ce1276e6cb762562084e16d43d174faefd2fed2f2f26561b4d525f7a597ad"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0fbf8f868201b7efac5bb66eeeda782993c8ce90e370349704373cf2f7c7ef3b"
  end

  depends_on "rust" => :build

  conflicts_with "leaf", because: "both install a `leaf` binary"

  resource "lwip" do
    url "https://github.com/eycorsican/lwip-leaf.git",
        revision: "86632e2747c926a75d32be8bd9af059aa38ae75e"
  end

  def install
    (buildpath/"leaf/src/proxy/tun/netstack/lwip").install resource("lwip")

    cd "leaf-bin" do
      system "cargo", "install", *std_cargo_args
    end
  end

  test do
    (testpath/"config.conf").write <<~EOS
      [General]
      dns-server = 8.8.8.8

      [Proxy]
      SS = ss, 127.0.0.1, #{free_port}, encrypt-method=chacha20-ietf-poly1305, password=123456
    EOS
    output = shell_output "#{bin}/leaf -c #{testpath}/config.conf -t SS"

    assert_match "dispatch to outbound SS failed", output
  end
end
