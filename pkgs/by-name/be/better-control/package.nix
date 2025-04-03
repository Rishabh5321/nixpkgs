{
  lib,
  python3Packages,
  fetchFromGitHub,
  gtk3,
  networkmanager,
  bluez,
  pipewire,
  brightnessctl,
  power-profiles-daemon,
  gammastep,
  libpulseaudio,
  pulseaudio,
  desktop-file-utils,
  wrapGAppsHook4,
  gobject-introspection,
  makeBinaryWrapper,
}:

python3Packages.buildPythonApplication rec {
  pname = "better-control";
  version = "5.8";
  format = "other";

  src = fetchFromGitHub {
    owner = "quantumvoid0";
    repo = "better-control";
    tag = version;
    sha256 = "sha256-FdT27KYbSLa1YqzERwI/J8szrOkAgjHn9nJv6ae9Ms4=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    wrapGAppsHook4
    gobject-introspection
    makeBinaryWrapper
  ];

  buildInputs = [
    gtk3
    libpulseaudio
  ];

  propagatedBuildInputs = [
    networkmanager
    bluez
    pipewire
    brightnessctl
    power-profiles-daemon
    gammastep
    pulseaudio
    python3Packages.pygobject3
    python3Packages.dbus-python
    python3Packages.pydbus
    python3Packages.psutil
    python3Packages.qrcode
    python3Packages.requests
    python3Packages.pillow
    python3Packages.pycairo
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/better-control $out/share/applications
    cp -r src/* $out/share/better-control/

    # Make the main script executable
    chmod +x $out/share/better-control/better_control.py

    # Create a wrapper script
    makeWrapper ${python3Packages.python.interpreter} $out/bin/better-control \
      --add-flags "$out/share/better-control/better_control.py" \
      --prefix PATH : ${
        lib.makeBinPath [
          brightnessctl
          networkmanager
          bluez
          pipewire
          power-profiles-daemon
          gammastep
          pulseaudio
        ]
      } \
      --prefix GI_TYPELIB_PATH : ${
        lib.makeSearchPath "lib/girepository-1.0" [
          gtk3
        ]
      } \
      --prefix PYTHONPATH : "$out/share/better-control:${python3Packages.makePythonPath propagatedBuildInputs}"

    # Create desktop file
    cat > $out/share/applications/better-control.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Better Control
    Comment=System control panel utility
    Exec=$out/bin/better-control
    Icon=better-control
    Categories=Utility;System;
    Terminal=false
    EOF

    runHook postInstall
  '';

  meta = {
    description = "System control panel utility";
    homepage = "https://github.com/quantumvoid0/better-control";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      rishabh5321
      quantumvoid0
      nekrooo
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "better-control";
  };
}
