#/usr/bin/env bash

# XDG autostart using systemd. Requires Perl.
# Put `systemd.user.services = with builtins; fromJSON (readfile ./generated/autostart.json;)` in configuration.nix
# See: https://github.com/jceb/dex#autostart-alternative

cd /run/current-system/sw/etc/xdg/autostart
objs=()
for file in $(ls)
do
    # grep --perl-regexp --only-matching
    Description=$(grep -Po "(?<=^Name\[en_\w{2}\]=).+" $file)
    ExecStart=$(grep -Po "(?<=^Exec=).+" $file)
    name=$(echo $file | grep -Po ".+(?=\..+$)")
    objs+=("\"$name\": {\"description\": \"$Description\", \"wants\":[ \"autostart.target\" ], \"serviceConfig\": { \"ExecStart\": \"$ExecStart\" }},")
done
# Turn the array to json, removing the infamous trailing comma
echo "{${objs[@]}}" | perl -pe "s/(,)(?!.*,)//" > ~/my-conf/generated/autostart.json
