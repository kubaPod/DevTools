<|
  "Label" -> "Select cell"
, "ShortKey" -> "a"
, "Action" :> (If[Length[#] > 0 , SelectionMove[First @ # ,All,Cell]]& @ SelectedCells @ EvaluationNotebook[])
|>