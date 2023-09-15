{ pkgs, config, lib, ... }:
with lib;
{
  options.services.automx2 = {
    enable = mkEnableOption "mail server autoconfiguration";

    socket = mkOption {
      type = types.str;
      default = "/var/run/automx2.sock";
      description = "The socket path to bind to";
    }

    provider = mkOption {
      type = types.str;
      example = "Example Inc.";
      description = "The name the user will see for this server";
    };

    domains = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Domains hosted by these servers";
    };

    servers = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Address of the server";
          };

          type = mkOption {
            type = types.enum ["pop" "imap" "smtp"];
            description = "Protocol offered by the server";
          };
        };
      });
      default = [ ];
      example = [
        {
          type = "pop";
          name = "pop.example.com";
        }
        {
          type = "imap";
          name = "imap.example.com";
        }
        {
          type = "smtp";
          name = "smtp.example.com";
        }
      ];
      description = "List of servers available";
    };

    config = mkOption {
      description = ''
        automx2 server configuration, as described in
        https://rseichter.github.io/automx2/#configure
      '';

      type = types.submodule {
        options = {
          loglevel = mkOption {
            type = types.enum [ "DEBUG" "WARNING" ];
            default = "WARNING";
          };

          db_echo = mkOption {
            type = types.bool;
            default = false;
          };

          db_uri = mkOption {
            type = types.str;
            default = "sqlite:///:memory:";
            example = "sqlite:////var/lib/automx2/db.sqlite";
          };

          proxy_count = mkOption {
            type = types.int;
            default = 1;
            description = ''
            Number of proxy servers between automx2 and the client (default: 0).
            If your logs only show 127.0.0.1 or ::1 as the source IP for incoming
            connections, proxy_count probably needs to be changed.
          '';
          };
        };
      };

      default = {
        loglevel = "WARNING";
        db_echo = false;
        db_uri = "sqlite:///:memory:";
        proxy_count = 1;
      };
    };
  };


  config = let cfg = config.services.automx2; in lib.mkIf cfg.enable {
    systemd.user.services.automx2 = let
      config-file = with cfg.config; pkgs.writeText "automx2.conf" ''
        [automx2]
        loglevel = ${loglevel}
        db_echo = ${if db_echo then "yes" else "no"}
        db_uri = ${db_uri}
        proxy_count = ${builtins.toString proxy_count}
      '';

      automx2 = pkgs.python3Packages.callPackage /tmp/automx2.nix { };

      gunicorn = pkgs.python3Packages.gunicorn;

      python-path = pkgs.python3Packages.makePythonPath [
        gunicorn
        automx2
      ];

      config-json = pkgs.writeTextFile {
        name = "automx2.json";
        text = builtins.toJSON {
          inherit (cfg) provider domains servers;
        };
      };

      insert-data = pkgs.writeShellScript "automx2-insert-data" ''
        set -x
        while ! [ -S "${cfg.socket}" ]
        do
          ${pkgs.coreutils}/bin/sleep 1
        done

        ${pkgs.curl}/bin/curl \
          --unix-socket ${cfg.socket} \
          -X POST \
          --json @${config-json} \
          http://127.0.0.1/initdb/
      '';
    in {
      # [Unit]
      # After=network.target
      # Description=MUA configuration service
      # Documentation=https://rseichter.github.io/automx2/

      # [Service]
      # Environment=FLASK_APP=automx2.server:app
      # Environment=FLASK_CONFIG=production
      # ExecStart=/srv/www/automx2/bin/flask run --host=127.0.0.1 --port=4243
      # Restart=always
      # User=automx2
      # WorkingDirectory=/var/lib/automx2

      # [Install]
      # WantedBy=multi-user.target

      Unit = {
        Description = "automx2 mail autoconfiguration service";
        After = [ "network.target" ];
        Documentation = "https://rseichter.github.io/automx2/";
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Environment = [
          "PYTHONPATH=${python-path}"
          "AUTOMX2_CONF=${config-file}"
        ];
        ExecStart = "${gunicorn}/bin/gunicorn --bind unix:/tmp/${cfg.socket} automx2.server:app";
        ExecStartPost = "${pkgs.coreutils}/bin/timeout 5 ${insert-data}";
        Restart = "always";
      };
    };
  };
}
