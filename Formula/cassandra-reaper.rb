class CassandraReaper < Formula
  desc "Management interface for Cassandra"
  homepage "https://cassandra-reaper.io/"
  url "https://github.com/thelastpickle/cassandra-reaper/releases/download/3.0.0/cassandra-reaper-3.0.0-release.tar.gz"
  sha256 "df185a83b1af26ff0c16105aad3d6a38916234ec375284c1f2103445020ac6c9"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "fb19757d6d28a30eed71836a8e674e366ca4ac809fddc845f9f2a4f7cd602414"
  end

  depends_on "openjdk@8"

  def install
    inreplace "bin/cassandra-reaper", "/usr/share", prefix
    prefix.install "bin"
    etc.install "resource" => "cassandra-reaper"
    share.install "server/target" => "cassandra-reaper"
    inreplace Dir[etc/"cassandra-reaper/*.yaml"], " /var/log", " #{var}/log"
  end

  service do
    run opt_bin/"cassandra-reaper"
    environment_variables JAVA_HOME: Formula["openjdk@8"].opt_prefix
    keep_alive true
    error_log_path var/"log/cassandra-reaper/service.err"
    log_path var/"log/cassandra-reaper/service.log"
  end

  test do
    ENV["JAVA_HOME"] = Formula["openjdk@8"].opt_prefix
    cp etc/"cassandra-reaper/cassandra-reaper.yaml", testpath
    port = free_port
    inreplace "cassandra-reaper.yaml" do |s|
      s.gsub! "port: 8080", "port: #{port}"
      s.gsub! "port: 8081", "port: #{free_port}"
    end
    fork do
      exec "#{bin}/cassandra-reaper", "#{testpath}/cassandra-reaper.yaml"
    end
    sleep 30
    assert_match "200 OK", shell_output("curl -Im3 -o- http://localhost:#{port}/webui/login.html")
  end
end
