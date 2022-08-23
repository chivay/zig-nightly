# Zig nightly

Freshly baked Zig. Updated every night, hopefully.

## How to

0. Enable flakes
1. (Optional) Use binary cache:

```bash
cachix use zig-nightly
```

2. Install to your profile:

```
nix profile install github:chivay/zig-nightly
```

3. Use in your project:

Add new input 
```
  inputs.zig-nightly.url = "github:chivay/zig-nightly";
```

Use package:
```
  zig = zig-nightly.packages.${system}.zig-nightly;
  zig-bin = zig-nightly.packages.${system}.zig-nightly-bin;
```
