# This file was generated by pkgs.mastodon.updateScript.
{
  fetchFromGitHub,
  applyPatches,
  patches ? [ ],
}:
let
  version = "4.3.4";
in
(applyPatches {
  src = fetchFromGitHub {
    owner = "mastodon";
    repo = "mastodon";
    rev = "v${version}";
    hash = "sha256-2FpiFSK9CBm7eHqVvV8pPp6fLc5jCcUektpSyxNnXtw=";
  };
  patches = patches ++ [ ];
})
// {
  inherit version;
  yarnHash = "sha256-e5c04M6XplAgaVyldU5HmYMYtY3MAWs+a8Z/BGSyGBg=";
}
