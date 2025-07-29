{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  openssl,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codex";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${finalAttrs.version}";
    # updated hash for v0.10.0 source tarball:
    hash = "sha256-ukQG6Ugc4lvJEdPmorNEdVh8XrgjuOO8x/8F+9jcw3U=";
  };

  sourceRoot = "${finalAttrs.src.name}/codex-rs";

  # updated Cargo vendor hash for dependencies of v0.10.0:
  cargoHash = "sha256-YZHmMRwJgZTPHyoB4GXlt6H2Igw1wh/4vMYt7+3Nz1Y=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  checkFlags = [
    "--skip=keeps_previous_response_id_between_tasks" # Requires network
    "--skip=retries_on_early_close" # Requires network
  ];

  doInstallCheck = true;
  doCheck = false;
  nativeInstallCheckInputs = [versionCheckHook];

  passthru.updateScript = nix-update-script {
    extraArgs = ["--version-regex" "^rust-v(\\d+\\.\\d+\\.\\d+)$"];
  };

  meta = with lib; {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/rust-v${finalAttrs.version}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "codex";
    maintainers = [maintainers.malo maintainers.delafthi];
    platforms = platforms.unix;
  };
})
