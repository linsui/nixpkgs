{ lib
, stdenv
, fetchFromGitLab
, rustPlatform
, desktop-file-utils
, meson
, ninja
, pkg-config
, wrapGAppsHook
, python3
, git
, glib
, gtk4
, gst_all_1
, libadwaita
}:

stdenv.mkDerivation rec {
  pname = "audio-sharing";
  version = "0.1.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "AudioSharing";
    rev = version;
    sha256 = "0k96v3rh8h5lhx2fyv28bc7jnz5w7dv3axs6bdvfwf25251q3b2m";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    sha256 = "00vpxh9n12vhlaqnlvxwxxp4fhpn796ncjb13d04fkw1ma5vj6jb";
  };

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
    python3
    git
    desktop-file-utils
  ] ++ (with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
  ]);

  buildInputs = [
    glib
    gtk4
    libadwaita
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-rtsp-server
  ];

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/World/AudioSharing";
    description = "Automatically share the current audio playback in the form of an RTSP stream";
    maintainers = with maintainers; [ linsui ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
