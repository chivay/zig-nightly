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
            version = "b87105c9217e41cb39c09d9a569ac8bc006c2eef";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-hMz13ctyv7K9zxaDfFONT5lJi/z5ROFTOQYKljBu9FE=";
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
