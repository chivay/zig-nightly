{
  description = "zig-nightly";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        llvmPackages = pkgs.llvmPackages_13;
      in
      rec {
        packages = flake-utils.lib.flattenTree {
          zig-nightly = llvmPackages.stdenv.mkDerivation rec {
            pname = "zig";
            version = "d66c97d0ef0434ce0814d1921877b9ffa877a645";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-xbqhcsJlcEwYPMgB4D8BXqLU/OsNTP7CiohQAu5EH8U=";
            };

            nativeBuildInputs = [ pkgs.cmake llvmPackages.llvm.dev ];
            buildInputs = [ pkgs.libxml2 pkgs.zlib ]
              ++ (with llvmPackages; [ libclang lld llvm ]);

            preBuild = ''
              export HOME=$TMPDIR;
            '';
          };
        };
        defaultPackage = packages.zig-nightly;
      });
}
