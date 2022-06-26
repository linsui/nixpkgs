{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, meson
, ninja
, pkg-config
, wrapGAppsHook4
, glib
, gtk4
, libadwaita
, openssl
, protobuf
, libxml2
, sqlite
, cairo
}:

rustPlatform.buildRustPackage rec {
  pname = "gtk-qq";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lomirus";
    repo = pname;
    rev = "3b7060cf6d02ada0679a838f433274a46d6471ad";
    hash = "sha256-Sq5VTlYifsGVhOKBY/RcmrBKaeOiqsWRdH0pVaSVvKQ=";
  };

  cargoHash = "sha256-J1mQiqn8i9IhZg7kIakMzjvg1ho9g9vAjqrFoNCtlR8=";

  RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [
    glib # glib-compile-resources
    meson
    ninja
    libxml2 # xmllint
    pkg-config
    protobuf # protoc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    openssl
    sqlite
    cairo
  ];

  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontUseNinjaCheck = true;

  preBuild = ''
    meson setup builddir
    meson compile -C builddir
  '';

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/World/amberol";
    description = "A small and simple sound and music player";
    maintainers = with maintainers; [ linsui ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
