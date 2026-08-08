{ pkgs, lib, config, inputs, ... }:

{
  cachix.enable = false;

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.inotify-tools ];

  # https://devenv.sh/languages/
  languages.elixir.enable = true;

  # https://devenv.sh/services/
  services.postgres.enable = true;

  enterShell = ''
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    actionlint = {
      enable = true;
    };
    check-merge-conflicts.enable = true;
    end-of-file-fixer.enable = true;
    mix-format.enable = true;
    mixed-line-endings.enable = true;
    ripsecrets.enable = true;
    trim-trailing-whitespace.enable = true;
    typos = {
      enable = true;
      settings = {
        write = true;
        configPath = "typos.toml";
      };
    };
  };
}
