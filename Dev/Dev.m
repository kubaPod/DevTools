(* ::Package:: *)

DevPackage[dark:_:False]:=With[{
  updateIcon = RawBoxes@PaneBox[
    StyleBox[DynamicBox[FEPrivate`ImportImage[FrontEnd`FileName[{"Toolbars","Package"},"UpdateIcon.png"]]],Magnification->0.5`]
  , BaselinePosition->Scaled[0.15`]
  ]
, buttonAppearance = FEPrivate`FrontEndResource["MUnitExpressions","ButtonAppearances"]
}, Notebook[{
  Cell[StyleData[StyleDefinitions -> If[dark,FrontEnd`FileName[{"DevTools", "ReverseColorPackage.nb"}],"Package.nb" ]]]
, Cell[
    StyleData["Notebook"]
  , NotebookEventActions->{
      {"KeyDown", "\t"} :> Block[{$ContextPath}, Needs["DevTools`"]; IndentCode[]]
    , {"MenuCommand", "InsertNewGraphic"} :>  Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesMenuOpen[] ]
    , ParentList
    }
  , DockedCells->{
     Cell[
       BoxData @ ToBoxes @ Grid[{{
         Pane[
           Button[
             "Get @ ThisFile"
           , Get[NotebookFileName[]]
           , Appearance->buttonAppearance 
           , Method -> "Queued"
           ]
         , Full
         ]
       , Button[ Row[{updateIcon, "Highlighting"}, Spacer[3]]
         , FrontEndExecute@FrontEnd`Private`GetUpdatedSymbolContexts[]
         , Appearance->buttonAppearance 
         ]  
       , Button[ Row[{updateIcon, "Menus"}, Spacer[3]]
         , MathLink`CallFrontEnd[FrontEnd`ResetMenusPacket[{Automatic,Automatic}]]
         , Appearance->buttonAppearance 
         , Method -> "Queued"
         ]
       , Button[ "Edit code templates"
         , Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesEdit[] ]
         , Appearance->buttonAppearance 
         , Method -> "Queued"
         ]
       }}
       , BaseStyle -> ButtonBoxOptions -> {
           (*BaseStyle -> "ControlStyleLightBold"*)
      (*   , Appearance -> FEPrivate`FrontEndResource["MUnitExpressions","ButtonAppearances"]*)
      (* This will not work in 10.4, FE throws an error not being able to resolve Appearance*)
           FrameMargins -> {{10,10},{0,0}}
         , ImageSize -> {Automatic, 28}
         , FontColor -> GrayLevel@.2
         
         , FontFamily -> FrontEnd`CurrentValue["ControlsFontFamily"]
         }
       ]
     , "DockedCell"
     , CellFrameMargins->{{12,12},{10,10}}(*CellFrameMargins -> {{12, 12}, {5, 5}}*)
     ]
   , Inherited
   }
 ] 
}]];
