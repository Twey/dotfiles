{ stdenv
, fetchFromGitHub
, pythonPackages
, gnupg
, openssl
, git
, tor
}:

let
  imgsize = pythonPackages.callPackage ../imgsize.nix { };
in

pythonPackages.buildPythonApplication rec {
  pname = "mailpile";
  version = "2020-08-26";

  src = fetchFromGitHub {
    owner = "mailpile";
    repo = "Mailpile";
    rev = "f2a9d7fe48cee6ae7b2c472500b4e30b10d28768";
    sha256 = "0bmc70a06yficav5v7swasyrc3q3wpb9sk6yzx12ivbxzc29rpvv";
  };

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = with pythonPackages; [ pbr git ];
  PBR_VERSION=version;

  propagatedBuildInputs = with pythonPackages; [
    appdirs
    cryptography
    fasteners
    gnupg
    jinja2
    pgpdump
    pillow
    lxml
    spambayes
    stem
    pysocks
    icalendar
    imgsize
  ];

  patches = [ ./underscores.patch ];

  postInstall = ''
    wrapProgram $out/bin/mailpile \
      --set-default MAILPILE_GNUPG "${gnupg}/bin/gpg" \
      --set-default MAILPILE_GNUPG_GA "${gnupg}/bin/gpg-agent" \
      --set-default MAILPILE_GNUPG_DM "${gnupg}/bin/dirmngr" \
      --set-default MAILPILE_OPENSSL "${openssl}/bin/openssl" \
      --set-default MAILPILE_TOR "${tor}/bin/tor" \
      --set-default MAILPILE_SHARED "$out/share/mailpile"
  '';

  # No tests were found
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A modern, fast web-mail client with user-friendly encryption and privacy features";
    homepage = "https://www.mailpile.is/";
    license = [ licenses.asl20 licenses.agpl3 ];
    platforms = platforms.linux;
    maintainers = [ maintainers.domenkozar ];
  };
}
