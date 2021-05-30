{
  description = "zig-nightly";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          llvmPackages = pkgs.llvmPackages_12;
      in rec {
        packages = flake-utils.lib.flattenTree {
          zig-nightly = llvmPackages.stdenv.mkDerivation rec {
            pname = "zig";
            version = "11ae6c42c1851fc44b286e5a76f73d55ea0bca5e";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-k+hOlSrBEBbADPu2Pejs8NAbIcFQBd1wB28wx58mnRM=";
            };

            nativeBuildInputs = [ pkgs.cmake llvmPackages.llvm.dev ];
            buildInputs = [ pkgs.libxml2 pkgs.zlib ]
              ++ (with llvmPackages; [ libclang lld llvm ]);

            preBuild = ''
              export HOME=$TMPDIR;
            '';

            checkPhase = ''
              runHook preCheck
              ./zig test --cache-dir "$TMPDIR" -I $src/test $src/test/stage1/behavior.zig
              runHook postCheck
            '';

            doCheck = false;
          };
        };
        defaultPackage = packages.zig-nightly;
      });
}
