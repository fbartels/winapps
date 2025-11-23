{
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  makeDesktopItem,
  callPackage,
  yad,
  ...
}:
let
  rev = "1cf0621ec9db90829464cdc35fa2a9b7f85e7713";
  hash = "sha256-z1lVOBIr2TVhyH5ykz0RTkUtaU7RwRLsvT42Dw9gmQQ=";
in
stdenv.mkDerivation rec {
  pname = "winapps-launcher";
  version = "0-unstable-2025-10-04";

  src = fetchFromGitHub {
    owner = "winapps-org";
    repo = "WinApps-Launcher";

    inherit rev hash;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    yad
    (callPackage ../winapps { })
  ];

  patches = [ ./WinApps-Launcher.patch ];

  postPatch = ''
    substituteAllInPlace WinApps-Launcher.sh
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r ./Icons $out/Icons

    install -m755 -D WinApps-Launcher.sh $out/bin/winapps-launcher
    install -Dm444 -T Icons/AppIcon.svg $out/share/pixmaps/winapps.svg

    wrapProgram $out/bin/winapps-launcher \
      --set LIBVIRT_DEFAULT_URI "qemu:///system" \
      --prefix PATH : "${lib.makeBinPath buildInputs}"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "winapps";
      exec = "winapps-launcher";
      icon = "winapps";
      comment = meta.description;
      desktopName = "WinApps";
      categories = [ "Utility" ];
    })
  ];

  meta = with lib; {
    homepage = "https://github.com/winapps-org/WinApps-Launcher";
    description = "Graphical launcher for WinApps. Run Windows applications (including Microsoft 365 and Adobe Creative Cloud) on GNU/Linux with KDE, GNOME or XFCE, integrated seamlessly as if they were native to the OS. Wayland is currently unsupported.";
    mainProgram = "winapps-launcher";
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
