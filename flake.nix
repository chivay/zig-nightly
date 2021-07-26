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
            version = "24bfd7bdddbf045c5568c1bb67a3f754c24eb8c4";

            src = pkgs.fetchFromGitHub {
              owner = "ziglang";
              repo = pname;
              rev = version;
              hash = "sha256-0jMo3LlUv/4aeEZCljkNUWfk0NjOHnqKbCeex1Q9fhI=";
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
