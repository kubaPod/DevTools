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
  , "\n, ", TemplateExpression @ ToBoxes @ evaluatedTestTemplate @ TemplateSlot["sel"]
  , "\n, TestID -> ", TemplateExpression @ ToString[CreateUUID[], InputForm]
  , "\n]"
  }]
, "ShortKey" -> "v"
, "Preview" -> OutputForm @ "VerificationTest[ selection, evaluatedSelection, TestID -> uuid]"
|>



(*TODO: get rid of _RowBox selector *)


(*TODO: or should I make templates being applied via the main link by default? *)

