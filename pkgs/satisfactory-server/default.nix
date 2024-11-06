{
  buildFHSEnv,
  fetchSteam,
  lib,
  makeWrapper,
  pulseaudio,
  stdenvNoCC,
  steamworks-sdk-redist,
  xdg-user-dirs,
}:
let
  binPath = lib.makeBinPath [ xdg-user-dirs ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "satisfactory-server";
  version = "16288570";

  src = fetchSteam {
    inherit (finalAttrs) name;
    appId = "526870";
    depotId = "526872";
    manifestId = "4600845959166322693";
    hash = lib.fakeHash;
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share $out/bin

    cp -r . $out/share/satisfactory-server
    chmod +x $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping

    makeWrapper \
      $out/share/satisfactory-server/Engine/Binaries/Linux/FactoryServer-Linux-Shipping \
      $out/bin/satisfactory-server \
      --add-flags "FactoryGame" \
      --prefix PATH : ${binPath}

    runHook postInstall
  '';

  passthru.fhs = buildFHSEnv {
    name = finalAttrs.name;
    runScript = lib.getExe finalAttrs.finalPackage;

    targetPkgs = pkgs: [
      finalAttrs.finalPackage
      pulseaudio
      steamworks-sdk-redist
    ];

    meta = finalAttrs.meta;
  };

  meta = with lib; {
    mainProgram = "satisfactory-server";
    description = "Satisfactory dedicated server";
    homepage = "https://steamdb.info/app/1690800/";
    changelog = "https://store.steampowered.com/news/app/526870?updates=true";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
})
