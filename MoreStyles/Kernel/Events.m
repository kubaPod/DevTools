
BeginPackage["MoreStyles`"];


  BeginPackage["`Kernel`"];

    IndentCode;

  EndPackage[];


  Begin["`Events`"];

    IndentCode // ClearAll;

    IndentCode[]:= With[
        { sel = CurrentValue["SelectionData"]
        , tab = "  "
        }
      , Module[
            { selString := First @ FrontEndExecute[FrontEnd`ExportPacket[BoxData@sel, "PlainText"]]
            , steps
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