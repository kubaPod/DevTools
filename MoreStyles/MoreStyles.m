(* :Author: Kuba Podkalicki *)
(* :Date: 2017-04-23 *)


BeginPackage["MoreStyles`"]
(* Exported symbols added here with SymbolName::usage *)

  Get @ "MoreStyles`Kernel`Events`";

  DeveloperToolbar;

  Begin["`Private`"];

  DeveloperToolbar[]:= Button["Get", Get @ NotebookFileName[], Method -> "Queued"];

  End[];


EndPackage[]