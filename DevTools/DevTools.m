(* :Author: Kuba Podkalicki *)
(* :Date: 2017-04-23 *)


BeginPackage["DevTools`"];


BeginPackage["`Kernel`"];

IndentCode;

EndPackage[];


Begin["`Events`"];

IndentCode // ClearAll;

IndentCode[tab_String:"  "]:= With[
  { sel = CurrentValue["SelectionData"]

  }
  , Module[
    { selString := First @ FrontEndExecute[FrontEnd`ExportPacket[BoxData@sel, "PlainText"]]
      , steps (*counted because we need to move selection back where it was before action //modulo indentation*)
      , result
    }
    , Which[
      sel === $Failed
      , result = tab
      ; steps = 0

      , StringQ[sel]
      , result = tab <> sel
      ; steps = StringLength[result]

      , True
      , result = StringReplace[ StringDrop[selString, -1], {"\r\n" :> ("\n" <> tab),"\r"->""} ]
      ; result = tab <> result <> StringTake[selString,-1]
      ; steps = StringLength @ result
    ]

    ; If[
      steps == 0
      , NotebookWrite[EvaluationNotebook[], BoxData @ result, After]
      , NotebookWrite[EvaluationNotebook[], BoxData @ result, Before]
      ; SelectionMove[EvaluationNotebook[], All, Character, steps]
    ]
  ]
];


End[]


EndPackage[]