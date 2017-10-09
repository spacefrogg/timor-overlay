self: super:

# self: final fixpoint
# super: immediate predecessor pkgs
let
  callPackage = super.lib.callPackageWith self;
in

{

  factor-lang = callPackage ./pkgs/factor-lang {
    inherit (self.gnome2) gtkglext;
  };

  spnav = callPackage ./pkgs/spnav { };

  spacenavd = callPackage ./pkgs/spacenavd { };

  freecad = (super.freecad.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ self.spnav ];
  }));

  openafsClientLocal = callPackage ./pkgs/openafs { kernel = super.linuxPackages.kernel; } ;
  workcraft = callPackage ./pkgs/workcraft {};

  unp = callPackage ./pkgs/unp { };

  esp32 = callPackage ./pkgs/esp32 { };

  mfcl8650cdwlpr = callPackage ./pkgs/mfcl8650cdwlpr { };
  mfcl8650cdwcupswrapper = callPackage ./pkgs/mfcl8650cdwcupswrapper {};

  vlc = super.vlc.overrideAttrs(oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ self.libnotify self.gtk2 ];
    configureFlags = oldAttrs.configureFlags ++ [ "--enable-notify" ];
  });

  exwm-ns = callPackage ./pkgs/exwm-ns { };

  slic3r = super.slic3r.overrideAttrs(oldAttrs: {
    buildPhase = ''
      export LD=g++
    '' +
    oldAttrs.buildPhase;
    patches = [
      (self.fetchpatch {
        name = "fix-deserialize-return-values";
        url = "https://github.com/alexrj/Slic3r/commit/6e5938c8330b5bdb6b85c3ca8dc188605ee56b98.diff";
	sha256 = "1m125lajsm2yhacwvb3yxsz63jy9k2zzfaprnc4nkfcz0hs5vbpq";
	})];
  });

  physlock = super.physlock.overrideAttrs(oldAttrs: rec {
    version = "11-git";
    name = "physlock-${version}";
    src = self.fetchFromGitHub {
    owner = "muennich";
      repo = "physlock";
      rev = "31cc383afc661d44b6adb13a7a5470169753608f";
      sha256 = "0j6v8li3vw9y7vwh9q9mk1n1cnwlcy3bgr1jgw5gcv2am2yi4vx3";
    };
    buildInputs = [ self.pam self.systemd ];
    makeFlags = "SESSION=systemd";
  });

  emacs-spacemacs = self.emacs.overrideAttrs(oldAttrs: rec {
    patches = oldAttrs.patches ++ [ ./patches/spacemacs.d.patch ];
    versionModifier = "spacemacs";
    name = "emacs-${oldAttrs.version}-${versionModifier}";
  });

  spacemacs =
    (self.writeScriptBin "spacemacs" ''
     #!/bin/sh
     dir=~/.spacemacs.d.d
     if [ ! -d "$dir" ]; then
	      ${self.git}/bin/git clone https://github.com/syl20bnr/spacemacs.git "$dir"
     fi
     ${self.emacs-spacemacs}/bin/emacs $@
     '');

  perlPackages = super.perlPackages // (with super.perlPackages;{
    ExtUtilsCppGuess = buildPerlModule rec {
    name = "ExtUtils-CppGuess-0.07";
    src = self.fetchurl {
      url = "mirror://cpan/modules/by-module/ExtUtils/${name}.tar.gz";
      sha256 = "1a77hxf2pa8ia9na72rijv1yhpn2bjrdsybwk2dj2l938pl3xn0w";
    };
    propagatedBuildInputs = [ CaptureTiny ];
    perlPreHook = "unset LD";
  };});

}
