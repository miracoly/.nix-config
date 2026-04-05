final: prev: let
  inherit (prev.stdenv.hostPlatform) system;
  platform =
    {
      "x86_64-linux" = "linux-x64";
      "aarch64-linux" = "linux-arm64";
    }.${
      system
    } or (throw "claude-code-bin overlay: unsupported system ${system}");
  sha256 =
    {
      "x86_64-linux" = "sha256-4iMkUUln/y1en5Hw7jfkZ1v4tt/sJ/r7GcslzFsj/K8=";
      "aarch64-linux" = "sha256-CN6z1WR3SW65LmJPSS4lsSP0Un3VZ09xr/9YpI7M2VM=";
    }.${
      system
    } or (throw "claude-code-bin overlay: unsupported system ${system}");
in {
  claude-code-bin = prev.claude-code-bin.overrideAttrs (old: {
    version = "2.1.92";
    src = prev.fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.92/${platform}/claude";
      inherit sha256;
    };
  });
}
