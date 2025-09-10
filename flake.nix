{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    nixpkgs-python.inputs = {nixpkgs.follows = "nixpkgs";};
    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = {self, ...} @ inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [inputs.nixgl.overlay];
      };
    in {
      devShells.default = inputs.devenv.lib.mkShell {
        inherit inputs pkgs;

        modules = [
          ({
            pkgs,
            config,
            ...
          }: {
            packages = with pkgs; [
              python3
              nodejs
              nss
              nspr
              stdenv
              rustc
              cargo
              ccache
              autoconf
              yasm
              zip
              unzip
              pkg-config
              patchelf
              gnumake
              xz
              wget
              llvm
              lld
              gtk3
              alsa-lib
              adwaita-icon-theme
              dbus-glib
              xorg.libXtst
              libva
              pciutils
              pipewire
              libpulseaudio
              rust-bindgen
              rustfmt
              libclang
              unixtools.whereis
              libva.out
              pciutils
              nixgl.nixGLIntel

              # runtime support used by the wrapper
              librsvg
              dconf
              gsettings-desktop-schemas
              libcanberra
            ];

            languages.python = {
              enable = true;
              version = "3.12.11";
              venv.enable = true;
            };

            env = with pkgs; {
              NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
                stdenv.cc.cc
                xorg.libX11
                xorg.libxcb
                xorg.libXext
                xorg.libXrandr
                xorg.libXcomposite
                xorg.libXcursor
                xorg.libXdamage
                xorg.libXi
                xorg.libXrender
                xorg.libXfixes
                xorg.libXinerama
                mesa
                libglvnd
                pango
                libva.out
                pciutils
                at-spi2-atk
                cairo
                gdk-pixbuf
                glib
                gtk3
                alsa-lib
              ];
              NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
              MOZBUILD_STATE_PATH = "/home/e2r2fx/projects/zen-desktop/.mozbuild";

              # GTK/XDG/GIO runtime envs (mirror the working wrapper)
              GTK_PATH = "${libcanberra}/lib/gtk-3.0/";
              XDG_DATA_DIRS = lib.concatStringsSep ":" [
                "${adwaita-icon-theme}/share"
                "${gtk3}/share"
                "${gsettings-desktop-schemas}/share"
                "${librsvg}/share"
              ];
              GIO_EXTRA_MODULES = "${dconf}/lib/gio/modules";
              GDK_PIXBUF_MODULE_FILE = "${librsvg}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache";

              # Prefer Wayland by default as in the wrapper
              MOZ_ENABLE_WAYLAND = "1";
            };

            languages.rust = {
              enable = true;
            };
          })
        ];
      };
    });
}
