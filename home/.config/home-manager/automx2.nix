{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, flask
, flask-migrate
, ldap3
}:
buildPythonPackage rec {
  pname = "automx2";
  version = "2022.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-My0YT5FLYjXSRKC0oUYNybewv6CIKr93tqMZ2fYY+5I=";
  };

  propagatedBuildInputs = [
    flask
    flask-migrate
    ldap3
  ];

  meta = with lib; {
    description = "Email client configuration made easy";
    homepage = "https://rseichter.github.io/automx2/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ twey ];
  };
}
