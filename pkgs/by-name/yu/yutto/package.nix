{
  lib,
  python3Packages,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "yutto";
  version = "2.0.0";
  pyproject = true;

  disabled = python3Packages.pythonOlder "3.9";
  pythonRelaxDeps = true;

  src = fetchFromGitHub {
    owner = "yutto-dev";
    repo = "yutto";
    tag = "v${version}";
    hash = "sha256-qbT72SGtSz7/7j1xUzQh5bXxM0GKsJorZ6Y8jshP2WU=";
  };

  build-system = with python3Packages; [ hatchling ];

  dependencies =
    with python3Packages;
    [
      httpx
      aiofiles
      biliass
      dict2xml
      colorama
      typing-extensions
      pydantic
    ]
    ++ (with httpx.optional-dependencies; http2 ++ socks);

  preFixup = ''
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ ffmpeg ]})
  '';

  pythonImportsCheck = [ "yutto" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
    ];
  };

  meta = with lib; {
    description = "Bilibili downloader";
    homepage = "https://github.com/yutto-dev/yutto";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ linsui ];
    mainProgram = "yutto";
  };
}
