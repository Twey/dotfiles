{ config, lib, ... }:
with lib;
let
  ms = config.mailserver;
  cfg = ms.autoconfig;
in {
  options.mailserver.autoconfig.xml = mkOption {
    type = types.str;
    visible = false;
  };

  config.mailserver.autoconfig.xml = ''
<?xml version="1.0" encoding="UTF-8"?>

<clientConfig version="1.1">
  <emailProvider id="${ms.fqdn}">
    ${concatMapStringsSep "\n" (x: "<domain>${x}</domain>") ms.domains}
    <displayName>${cfg.displayName}</displayName>
    <displayShortName>${cfg.displayShortName}</displayShortName>
${optionalString ms.enableImapSsl ''
    <incomingServer type="imap">
      <hostname>${ms.fqdn}</hostname>
      <port>993</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>
''}
${optionalString ms.enableImap ''
    <incomingServer type="imap">
      <hostname>${ms.fqdn}</hostname>
      <port>143</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>
''}
${optionalString ms.enablePop3Ssl ''
    <incomingServer type="pop3">
      <hostname>${ms.fqdn}</hostname>
      <port>995</port>
      <socketType>SSL</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>
''}
${optionalString ms.enablePop3 ''
    <incomingServer type="pop3">
      <hostname>${ms.fqdn}</hostname>
      <port>110</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </incomingServer>
''}
    <outgoingServer type="smtp">
      <hostname>${ms.fqdn}</hostname>
      <port>587</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </outgoingServer>
    <outgoingServer type="smtp">
      <hostname>${ms.fqdn}</hostname>
      <port>25</port>
      <socketType>STARTTLS</socketType>
      <authentication>password-cleartext</authentication>
      <username>%EMAILADDRESS%</username>
    </outgoingServer>
  </emailProvider>
</clientConfig>
  '';
}
