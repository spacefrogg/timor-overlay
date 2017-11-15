{ stdenv, fetchurl, buildFHSUserEnv, writeTextFile, bash, wrapGAppsHook, gsettings_desktop_schemas, gtk3, gnome3 }:

let
version = "5.0.25";
meta = with stdenv.lib; {
  homepage = https://www.zotero.org;
  description = "Collect, organize, cite, and share your research sources";
  license = licenses.agpl3;
  platforms = platforms.linux;
  # broken = true; # probably; see #20049
};
zoteroSrc = stdenv.mkDerivation rec {
  inherit version;
  name = "zotero-${version}-pkg";

  src = fetchurl {
    url = "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2";
    sha256 = "1y3q5582xp4inpz137x0r9iscs1g0cjlqcfjpzl3klsq3yas688k";
  };

  buildInputs= [ wrapGAppsHook gsettings_desktop_schemas gtk3 gnome3.adwaita-icon-theme gnome3.dconf ];
  phases = [ "unpackPhase" "installPhase" "fixupPhase"];

  installPhase = ''
    mkdir -p $out/data
    cp -r * $out/data
    mkdir $out/bin
    ln -s $out/data/zotero $out/bin/zotero
  '';
  # doInstallCheck = true;
  # installCheckPhase = "$out/bin/zotero --version";
};
fhsEnv = buildFHSUserEnv {
  name = "zotero-fhs-env";
  targetPkgs = pkgs: with pkgs; with xlibs; [
    gtk3 dbus_glib
    libXt nss
  ];
};
in writeTextFile {
  name = "zotero";
  destination = "/bin/zotero";
  executable = true;
  text = ''
    #!${bash}/bin/bash
    ${fhsEnv}/bin/zotero-fhs-env ${zoteroSrc}/bin/zotero
  '';
} // {inherit meta; }
