{
  description = "calico nameplates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      archs = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      genSystems = nixpkgs.lib.genAttrs archs;
      sysPkgs = genSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = genSystems (system:
        let
          pkgs = sysPkgs.${system};
        in
        {
          default = pkgs.mkShell {
            name = "calico-nameplates";

            buildInputs = with pkgs; [
              lua
            ];
          };
        });

      formatter = genSystems (system: sysPkgs.${system}.nixpkgs-fmt);
    };
}
