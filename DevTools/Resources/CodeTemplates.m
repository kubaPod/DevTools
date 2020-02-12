<|
  "ShortKey" -> "m",
  "Label" -> "Module",
  "Template" ->
"Module[{\[Placeholder]}
, Null
; `sel`
]"
|>

<|
  "ShortKey" -> "c",
  "Label" -> "Test CloudDeploy",
  "Template" ->
"CloudDeploy[
  `sel`
, CreateUUID[\"temp/\"]
, Permissions \[Rule] \"Public\"
]"
|>

<|
  "Label" -> "VerificationTest"
, "Template" -> RowBox[{
    "VerificationTest[\n  ", TemplateSlot["sel"]
  , "\n, ", TemplateExpression @ ToBoxes @ DevTools`Events`evaluatedTestTemplate @ TemplateSlot["sel"]
  , "\n, TestID -> ", TemplateExpression[
        ToBoxes @
        If[StringLength[#]>64, StringTake[#, 64]<>"...", #]& @
        First @
        FrontEndExecute @
        FrontEnd`ExportPacket[#, "PlainText"]& @
        (# /. s_String ? (StringMatchQ[#, "*`*"]&) :> Last @ StringSplit[s, "`"]) & @
        StripBoxes @ TemplateSlot["sel"]
    ]
    
  , "\n]"
  }]
, "ShortKey" -> "v"
, "Preview" -> OutputForm @ "VerificationTest[ selection, evaluatedSelection, TestID -> uuid]"
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



(*TODO: get rid of _RowBox selector *)


(*TODO: or should I make templates being applied via the main link by default? *)

