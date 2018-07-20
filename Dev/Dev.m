(* ::Package:: *)

DevPackage;


Begin["`Private`"]


DevPackage[dark:_:False]:= Notebook[{
  Cell[StyleData[StyleDefinitions -> If[dark, FrontEnd`FileName[{"DevTools", "ReverseColorPackage.nb"}],"Package.nb" ]]]
, Cell[
    StyleData["Notebook"]
  , NotebookEventActions -> notebookActions[]
  , DockedCells->{
     devNotebookToolbar[]
   , Inherited
   }
 ] 
}];


updateIcon[]:=RawBoxes@PaneBox[
    StyleBox[DynamicBox[FEPrivate`ImportImage[FrontEnd`FileName[{"Toolbars", "Package"},"UpdateIcon.png"]]],Magnification->0.5`]
  , BaselinePosition->Scaled[0.15`]
]


menuIcon[]:=Pane[
     					RawBoxes[
      						StyleBox[
       							DynamicBox @ FEPrivate`ImportImage @ FrontEnd`FileName[{"Toolbars", "Package"}, "MenuIcon.png"],
       							Magnification -> 0.5
       						]
      					],
     					BaselinePosition -> (Bottom -> Baseline)
     				];


notebookActions[]:={
  {"KeyDown", "\t"} :> Block[{$ContextPath}, Needs["DevTools`"]; IndentCode[]]
, {"MenuCommand", "InsertNewGraphic"} :>  Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesMenuOpen[] ]
, ParentList
}


devNotebookToolbar[]:=With[
  { updateIcon = updateIcon[]
  , menuIcon = menuIcon[]
  , buttonAppearance = FEPrivate`FrontEndResource["MUnitExpressions","ButtonAppearances"]
  , buttonStyle = {FontColor -> GrayLevel@.2 }
  }
, Cell[
       BoxData @ ToBoxes @ Grid[{{
         Pane[
           Button[
             "Get @ ThisFile"
           , Get[NotebookFileName[]]; FrontEndExecute@FrontEnd`Private`GetUpdatedSymbolContexts[]
           , Appearance->buttonAppearance 
           , Method -> "Queued"
           , BaseStyle-> buttonStyle
           ]
         , Full
         ]
       (*, Button[ Row[{updateIcon, "Menus"}, Spacer[3]]
         , MathLink`CallFrontEnd[FrontEnd`ResetMenusPacket[{Automatic,Automatic}]]
         , Appearance->buttonAppearance 
         , Method -> "Queued"
         , BaseStyle-> buttonStyle
         ]*)
       , ActionMenu[
           Button[ 
             Row[{"Code templates", menuIcon}, "  "]
           , Appearance->buttonAppearance 
           , BaseStyle-> buttonStyle 
           ]
         , { "Edit user templates" :> Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesEdit[] ]
           , "Refresh" :> Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesReset[] ]
           , Row[{"Open menu  ", KeyFrame["Ctrl", ImageSize->{All, 18}], "+", KeyFrame["1"] }]:> Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesMenuOpen[] ]
           }
         , Method->"Queued"
         , Appearance->None    
         ]
       , Button[ updateIcon(*Row[{updateIcon, "Highlighting"}, Spacer[3]]*)
         , FrontEndExecute@FrontEnd`Private`GetUpdatedSymbolContexts[]
         ; MathLink`CallFrontEnd[FrontEnd`ResetMenusPacket[{Automatic,Automatic}]]
         , Appearance -> buttonAppearance 
         , BaseStyle  -> buttonStyle
         , Method     -> "Queued"
         ]  ~ Tooltip ~ "Refresh symbol highlighting and front end menus."  
       }}
       , BaseStyle -> ButtonBoxOptions -> {
           (*BaseStyle -> "ControlStyleLightBold"*)
      (*   , Appearance -> FEPrivate`FrontEndResource["MUnitExpressions","ButtonAppearances"]*)
      (* This will not work in 10.4, FE throws an error not being able to resolve Appearance*)
           FrameMargins -> {{10,10},{0,0}}
         , ImageSize -> {Automatic, 28}
         (*, FontColor -> GrayLevel@.2*)
         
         , FontFamily -> FrontEnd`CurrentValue["ControlsFontFamily"]
         }
       ]
     , "DockedCell"
     , CellFrameMargins->{{12,12},{10,10}}(*CellFrameMargins -> {{12, 12}, {5, 5}}*)
     ]
];


End[];
