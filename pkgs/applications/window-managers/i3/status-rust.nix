{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, dbus
, libpulseaudio
, notmuch
, openssl
, ethtool
}:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "0.20.6";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FLMfXloAAIz/9KAtKFfB8uokQz/J8R+WsGarq/5cblo=";
  };

  cargoSha256 = "sha256-UVAF2rz0y6h3/rcTJ+31mMyJDLG7q40n6vBK8Wxultg=";

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [ dbus libpulseaudio notmuch openssl ];

  cargoBuildFlags = [
    "--features=notmuch"
    "--features=maildir"
    "--features=pulseaudio"
  ];

  prePatch = ''
    substituteInPlace src/util.rs \
      --replace "/usr/share/i3status-rust" "$out/share"
  '';

  postInstall = ''
    mkdir -p $out/share
    cp -R examples files/* $out/share
  '';

  postFixup = ''
    wrapProgram $out/bin/i3status-rs --prefix PATH : "${ethtool}/bin"
  '';

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3;
    maintainers = with maintainers; [ backuitist globin ma27 ];
    platforms = platforms.linux;
  };
}
