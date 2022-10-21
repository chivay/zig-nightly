{
  description = "zig-nightly";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        llvmPackages = pkgs.llvmPackages_14;
        index = builtins.fromJSON (builtins.readFile ./index.json);
        bundle = builtins.fetchurl {
            url = index.master.${system}.tarball;
            sha256 = index.master.${system}.shasum;
        };

      in
      rec {
        packages = flake-utils.lib.flattenTree {
          zig-nightly-bin = pkgs.stdenv.mkDerivation {
            pname = "zig-nightly-bin";
            version = index.master.version;

            dontFixup = true;

            unpackPhase = "tar xvf ${bundle}";
            installPhase = ''
            mkdir $out
            cp -r zig-*/* $out

            mkdir $out/bin
            ln -s $out/zig $out/bin/zig
            '';
          };

          zig-nightly = llvmPackages.stdenv.mkDerivation rec {
            pname = "zig";
            version = "5b9c8d1d6fed333486d15a5ad7ba2699c6bdb01f";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-75KvVqDSbpNzNBxwQ+xUiyvD0QaNmx9JVJzVz65J/28=";
            };

            # https://github.com/ziglang/zig/issues/12069 workaround
            cmakeFlags = "
            -DZIG_STATIC_ZLIB=on
            ";

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
