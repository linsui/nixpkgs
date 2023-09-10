{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "standard";
  version = "17.1.0";

  src = fetchFromGitHub {
    owner = "standard";
    repo = "standard";
    rev = "v${version}";
    hash = "sha256-paLvnwXOeTC4SSc+j/LhMLd4j8FgRa1QzGg6bxtlvTs=";
  };

  npmDepsHash = "sha256-t95qn2bye0ZnPu5KazHR0sFncC4IVMxUw24l7qQnnFY=";

  dontNpmBuild = true;
  dontNpmPrune = true;

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  meta = with lib; {
    description = "JavaScript Style Guide, with linter & automatic code fixer";
    homepage = "https://github.com/standard/standard";
    changelog =
      "https://github.com/standard/standard/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
