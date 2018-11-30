<|
  "Label" -> "Select cell"
, "ShortKey" -> "a"
, "Action" :> (If[Length[#] > 0 , SelectionMove[First @ # ,All,Cell]]& @ SelectedCells @ EvaluationNotebook[])
|>

<|
  "Label" -> "$InstallationDir"
  
  , "Action" :> SystemOpen @ $InstallationDirectory
|>

<|
  "Label" -> "$UserBaseDir"
  
  , "Action" :> SystemOpen @ $InstallationDirectory
|>

<|
  "Label" -> "NotebookDirectory"
  
  , "Action" :> SystemOpen @ $InstallationDirectory
|>