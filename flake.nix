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
            version = "673ae5b457479760ff8e08b3e06917a4b2651436";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-GmNDvBO9IGHcz5BaJ+0AL+63/7ZA3hpWdSJEXS/nTzQ=";
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
