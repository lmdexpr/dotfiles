{ ... }:

{
  programs.git = {
    enable = true;
    userName = "lmdexpr";
    userEmail = "lmdexpr@gmail.com";

    aliases = {
      st = "status";
      co = "checkout";
      cm = "commit";
      sw = "switch";
      br = "branch";

      graph = "log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'";
      gr = "log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'";


      difff = "diff --word-diff";
    };
  };
}
