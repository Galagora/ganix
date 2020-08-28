{ stdenv ? (import <nixpkgs> {}).stdenv
, lib ? (import <nixpkgs> {}).lib
, setJavaClassPath
# , autoPatchelfHook ? (import <nixpkgs> {}).autoPatchelfHook
}:
let
  openjdk = stdenv.mkDerivation rec {
    name = "openjdk14-bin";
    version = "14.0.2";

    src = fetchTarball {
      url = "https://download.java.net/java/GA/jdk14.0.2/205943a0976c4ed48cb16f1043c5c647/12/GPL/openjdk-14.0.2_linux-x64_bin.tar.gz";
      sha256 = "072058y978a0imar3wb0lc6xkzyv7w7dkrj4dqsgq1kvgcf2g4jx";
    };

    buildInputs = [];
    dontStrip = 1;

    installPhase = ''
      libfiles=$(ls -1)
      mkdir -p $out/lib/openjdk

      for f in $libfiles; do mv "$f" $out/lib/openjdk; done

      # # Remove some broken manpages.
      # rm -rf $out/lib/openjdk/man/ja*

      # Mirror some stuff in top-level.
      mkdir -p $out/share
      ln -s $out/lib/openjdk/include $out/include
      # ln -s $out/lib/openjdk/man $out/share/man

      # jni.h expects jni_md.h to be in the header search path.
      ln -s $out/include/linux/*_md.h $out/include/

      ln -s $out/lib/openjdk/bin $out/bin
    '';

    preFixup = ''
      # Propagate the setJavaClassPath setup hook so that any package
      # that depends on the JDK has $CLASSPATH set up properly.
      mkdir -p $out/nix-support
      #TODO or printWords?  cf https://github.com/NixOS/nixpkgs/pull/27427#issuecomment-317293040
      echo -n "${setJavaClassPath}" > $out/nix-support/propagated-build-inputs

      # Set JAVA_HOME automatically.
      mkdir -p $out/nix-support
      cat <<EOF > $out/nix-support/setup-hook
      if [ -z "\''${JAVA_HOME-}" ]; then export JAVA_HOME=$out/lib/openjdk; fi
      EOF
    '';
    passthru = {
      home = "${openjdk}/lib/openjdk";
    };

    meta = with stdenv.lib; {
      license = licenses.gpl2Classpath;
      description = "The official prebuilt OpenJDK binary";
    };
  }; in openjdk
