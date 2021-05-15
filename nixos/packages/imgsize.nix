{ stdenv
, lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "imgsize";
  version = "2.1";

  format = "wheel";

  src = fetchPypi {
    inherit pname version;
    format = "wheel";
    sha256 = "03z0rq0yvgiwy7qaz0sdp0gndrbs0vl9gdxy8qb2a141aapn5dgk";
  };

  meta = with lib; {
    description = "Pure Python image size library";
    homepage = "https://github.com/ojii/imgsize";
    license = with licenses; [ bsd3 ];
  };

}
