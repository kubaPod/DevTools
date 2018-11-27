<|
  "Label"    -> "New function"
, "ShortKey" -> "n"
, "Template" -> StringRiffle[
    { "`sel` // ClearAll"
    , "`sel` // Options = {};"
    , "`sel` // Attributes = {};"
    , ""
    , "`sel`[]:=Module["
    , "  {tag = \"`sel`\"}"
    , ", Catch["
    , "    Check[ code Throw[$Failed, tag] ]"
    , "  , tag"
    , "  ]"
    , "]"
    }
  , "\n"
  ]
|>


<|"Template" -> RowBox[{"{","\[SelectionPlaceholder]", "}"}],  "ShortKey" -> "{" |>

<|"Template" -> RowBox[{"(","\[SelectionPlaceholder]", ")"}],  "ShortKey" -> "(" |>

<|"Template" -> RowBox[{"[","\[SelectionPlaceholder]", "]"}],  "ShortKey" -> "[" |>

<|
  "Template" -> RowBox[{"\"","\[SelectionPlaceholder]","\""}]
, "Label"    -> "\"\[SelectionPlaceholder]\""
, "ShortKey" ->"\""
, "Preview"  -> None
|>

<|
  "Label" -> "VerificationTest"
, "Template" -> RowBox[{
    "VerificationTest[\n  ", TemplateSlot["sel"]
  , "\n, ", TemplateExpression @ ToBoxes @ DevTools`Events`evaluatedTestTemplate @ TemplateSlot["sel"]
  , "\n, TestID -> ", TemplateExpression[
        ToBoxes @
        If[StringLength[#]>32, StringTake[#, 64]<>"...", #]& @
        First @
        FrontEndExecute @
        FrontEnd`ExportPacket[StripBoxes @ TemplateSlot["sel"], "PlainText"]
    ]
    
  , "\n]"
  }]
, "ShortKey" -> "v"
, "Preview" -> OutputForm @ "VerificationTest[ selection, evaluatedSelection, TestID -> uuid]"
|>



(*TODO: get rid of _RowBox selector *)


(*TODO: or should I make templates being applied via the main link by default? *)

