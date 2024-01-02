{
  description = "A nix flake for the zfs-multi-mount script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.zfs-multi-mount = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
      pname = "zfs-multi-mount";
      version = "master";
      src = self;
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.bash ];
      dontBuild = true;
      installPhase = ''
        install -D zfs-multi-mount.sh $out/bin/zfs-multi-mount
      '';
    };

    packages.x86_64-linux.default = self.packages.x86_64-linux.zfs-multi-mount;
  };
} 
