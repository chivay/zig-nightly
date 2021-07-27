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
            version = "fc105f268149b195ea4a4189da59d40e96e455b4";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-eRUzGrhHub9FaVi25Ek1rp/gW09w4Riogd5nc8VpKI4=";
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
