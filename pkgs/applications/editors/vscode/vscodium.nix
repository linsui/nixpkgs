{ lib
, stdenv
, fetchFromGitHub
, python
, git
, zip
, yarn
, makeWrapper
, fetchurl
, pkgconfig
, jq
, fetchYarnDeps
, writeScript
, xorg
, ripgrep
, electron
, nodejs
, nodePackages
, fixup_yarn_lock
, esbuild
}:

let
  # replaces esbuild's download script with a binary from nixpkgs
  patchEsbuild = path: version: ''
    sed -i 's/${version}/${esbuild.version}/g' ${path}/node_modules/esbuild/lib/main.js
  '';
in
stdenv.mkDerivation rec {
  pname = "vscodium";
  version = "1.68.1";

  src = stdenv.mkDerivation rec {
    pname = "vscodium-src";
    inherit version;

    src = fetchFromGitHub {
      owner = "VSCodium";
      repo = "vscodium";
      rev = version;
      hash = "sha256-A4qm++s7lcx6adJe+8a2XajR6hl6wG9Ydkcoy98ZRqM=";
    };

    vscode-src = fetchFromGitHub {
      owner = "microsoft";
      repo = "vscode";
      rev = version;
      hash = "sha256-0Nzx0sYKwW3UbcR8a9IKJl26QmJvHw7AH4XFxv8CB0I=";
    };

    nativeBuildInputs = [ git jq ];

    patchPhase = ''
      cp -r ${vscode-src} vscode
      chmod -R +w vscode
      patchShebangs prepare_vscode.sh
      sed -i -e 's/yarn/echo/' prepare_vscode.sh
      OS_NAME=linux npm_config_arch=x64 ./prepare_vscode.sh
      for f in $(find -name yarn.lock); do
        cat $f >> vscode/all.lock
        ${fixup_yarn_lock}/bin/fixup_yarn_lock $f
      done
      sed -z -E -i -e 's/@[^@"]+("?:\s+version\s"([0-9.]+)")/@\2\1/g' vscode/all.lock
      sed -i -e '/packageMarketplaceExtensionsStream/d' vscode/build/gulpfile.extensions.js
      sed -i -e '/pipe(electron/d' vscode/build/gulpfile.vscode.js
    '';

    dontBuild = true;

    installPhase = ''
      mv vscode $out
    '';
  };

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/all.lock";
    sha256 = "sha256-5zIFclDqf+oujBESJYWwE9x1gOfcfD/LFzODlihADOg=";
  };

  nativeBuildInputs = [
    yarn
    nodejs
    git
    python
    pkgconfig
    zip
    makeWrapper
    jq
    nodePackages.node-gyp
    nodePackages.node-gyp-build
    nodePackages.typescript
  ];

  buildInputs = [
    xorg.libX11
    xorg.libxkbfile
  ];

  buildPhase = ''
    runHook preBuild
    export HOME=$(mktemp -d)

    for f in $(find -name yarn.lock); do
      pushd $(dirname $f)
      yarn config --offline set yarn-offline-mirror ${offlineCache}
      yarn install --offline --ignore-scripts --ignore-engines
      popd
    done

    mkdir node_modules/@vscode/ripgrep/bin/
    ln -s ${ripgrep}/bin/rg node_modules/@vscode/ripgrep/bin/rg

    sed -i 's/0.14.2/${esbuild.version}/g' ./build/node_modules/esbuild/lib/main.js
    sed -i 's/0.11.23/${esbuild.version}/g' ./extensions/node_modules/esbuild/lib/main.js
    ln -sf ${esbuild}/bin/esbuild ./extensions/node_modules/esbuild/bin/esbuild

    ESBUILD_BINARY_PATH=${esbuild}/bin/esbuild yarn --offline gulp vscode-min

    runHook postBuild
  '';

  installPhase = ''
    mv ../VSCode* $out
  '';

  meta = with lib; {
    description = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS (VS Code without MS branding/telemetry/licensing)
    '';
    longDescription = ''
      Open source source code editor developed by Microsoft for Windows,
      Linux and macOS. It includes support for debugging, embedded Git
      control, syntax highlighting, intelligent code completion, snippets,
      and code refactoring. It is also customizable, so users can change the
      editor's theme, keyboard shortcuts, and preferences
    '';
    homepage = "https://github.com/VSCodium/vscodium";
    downloadPage = "https://github.com/VSCodium/vscodium/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ synthetica turion bobby285271 ];
    mainProgram = "codium";
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" "armv7l-linux" ];
  };
}
