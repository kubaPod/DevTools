(* ::Package:: *)

(* :Author: Kuba Podkalicki *)
(* :Date: 2017-04-23 *)


(* ::Chapter:: *)
(*Begin*)


BeginPackage["DevTools`"];




IndentCode;

CodeTemplatesMenuOpen;
CodeTemplatesEdit;
CodeTemplatesReset;

CenterToParent;



Begin["`Events`"];


(* ::Chapter:: *)
(*Content*)


(* ::Section:: *)
(*Utilities*)


(* ::Subsection:: *)
(*CenterToParent*)


CenterToParent::usage =  "CenterToParent[DialogInput[...]] etc, will make the dialog centered with respect to the parent notebook";

CenterToParent // Attributes = {HoldFirst};

CenterToParent[ dialog_[whatever__, opts : OptionsPattern[]]  ] := With[
    {apc = AbsoluteCurrentValue}
  , With[
        { parentCenter = Transpose @ {
              apc[WindowMargins][[;; , 1]] + .5 apc[ WindowSize]
            , {Automatic, Automatic}
          }
        }
      , dialog[
            whatever
          , NotebookDynamicExpression :> Refresh[
                SetOptions[
                    EvaluationNotebook[]
                  , WindowMargins -> (parentCenter - Transpose[{.5 apc[WindowSize], {0, 0}}])
                  , NotebookDynamicExpression -> None
                ]
              , None
            ]
          , opts 
        ]
     ]
  ];


(* ::Subsection::Closed:: *)
(*DirectoryNeed*)


DirectoryNeed[""]=False; (*because DirectoryQ can't handle this *)

DirectoryNeed[dir_String]:=If[
  Not @ DirectoryQ @ dir
, CreateDirectory[dir, CreateIntermediateDirectories -> True]
];



(* ::Section::Closed:: *)
(*IndentCode*)


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


(* ::Section:: *)
(*CodeTemplates*)


(* ::Subsection::Closed:: *)
(*dev notes*)


(*
min template: <| Template \[Rule] _ |>

template :

  <| Label : whatever
   , Template : RowBox | String // required (*TODO: TemplateObject *)
   , Preview \[Rule] _
   , ShortKey \[Rule] 
   , ExpandEmptySelection \[Rule] 
 (*TODO:
   , MenuSortingValue     
   , FindPlaceholder
 *)
   |>
*)


(* ::Subsection::Closed:: *)
(*misc*)


$userTemplatesPath = FileNameJoin[
  {$UserBaseDirectory, "ApplicationData", "DevTools", "codeTemplates.m"}
];

$templatesCachePath = FileNameJoin[
  {$UserBaseDirectory, "ApplicationData", "DevTools", ToString[$VersionNumber], "codeTemplatesCache.mx"}
];

$minimalTemplatePattern = (_Association)?(KeyExistsQ["Template"]); (*earlier than KeyValuePattern*)


StringWrapCommentFrame[str_String]:=Module[
  {temp, max}
, temp = StringSplit[str,"\n"] 
; max = Max @ StringLength @ temp
; Composition[
    StringJoin
  , Map[StringJoin[{"(* ",#," *)\n"}]&] 
  , StringPadRight[#, max , " "]&
  ] @ temp 
  
];


(* ::Subsection::Closed:: *)
(*$codeTemplates*)


  
  $codeTemplates = {    
    <|
      "Label" -> "New function"
    , "ShortKey" -> "n"    
    , "Template" -> StringRiffle[
        { "`sel` // ClearAll"
        , "`sel` // Options = {};"
        , "`sel` // Attributes = {};"
        , "`sel`[]:=Module[
  {tag = \"`sel`\"}
, Catch[
    Check[
      code
    , Throw[$Failed, tag]  
    ]
  , tag
  ]
]"
      }
    , "\n"
    ]
  
  |>
, <|"Template" -> RowBox[{"{","\[SelectionPlaceholder]", "}"}],  "ShortKey" -> "{" |>
, <|"Template" -> RowBox[{"(","\[SelectionPlaceholder]", ")"}],  "ShortKey" -> "(" |>
, <|"Template" -> RowBox[{"[","\[SelectionPlaceholder]", "]"}],  "ShortKey" -> "[" |>
, <|"Template" -> RowBox[{"\"","\[SelectionPlaceholder]","\""}]
  , "Label" -> "\"\[SelectionPlaceholder]\""
  , "ShortKey" ->"\"" 
  , "Preview" -> None
  |>  

};
  
  



(* ::Subsection:: *)
(*Menu open*)


  (*sets the default value if not present*)
CurrentValue[
  $FrontEnd
, {TaggingRules, "DevTools", "MenuMethod"}
, If[$VersionNumber < 11, "Notebook", "Cell"]
]; 


CodeTemplatesMenuOpen::usage = "CodeTemplatesMenuOpen[nb:_:EvaluationNotebook[]]"<>
   " creates a templates menu and attaches it to the nb.";

CodeTemplatesMenuOpen[]:=CodeTemplatesMenuOpen @ EvaluationNotebook[];

CodeTemplatesMenuOpen[nb_NotebookObject]:=CodeTemplatesMenuOpen[
  nb
, CurrentValue[$FrontEnd, {TaggingRules, "DevTools", "MenuMethod"}, "Notebook"]
];  



(* ::Subsection::Closed:: *)
(*Cell menu open*)


CodeTemplatesMenuOpen[nb_NotebookObject, "Cell"] := MathLink`CallFrontEnd[
  FrontEnd`AttachCell[
      nb
    , Cell[
        BoxData @ ToBoxes @ CodeTemplatesMenu[nb, "Cell"]
      , CellSize -> Automatic
      , Magnification->CurrentValue[Magnification]
      ]
    , {-1, {Right, Top}}
    , {Right, Top}
    , "ClosingActions"->{ "OutsideMouseClick" }
  ]  
];


(* ::Subsection:: *)
(*FramelessNotebook menu open*)


CodeTemplatesMenuOpen[nb_NotebookObject, "Notebook"]:=NotebookPut @ CenterToParent @ Notebook[
  List @ Cell[
    BoxData @ ToBoxes @ CodeTemplatesMenu[nb, "Notebook"]
  , CellFrameMargins->{{0, 0}, {0, 0}}
  , CellMargins->{{0, 0}, {0, 0}}    
  ]        
, StyleDefinitions    -> "Dialog.nb"
, WindowClickSelect   -> False
, WindowFloating      -> True
, WindowFrame         -> "Frameless"
, WindowSize          -> All
, Background          -> None
, WindowElements      -> {}
, WindowFrameElements -> {}    
]


(* ::Subsection:: *)
(*Menu*)


(*TODO: preburn this one day*)
(*CodeTemplatesMenu[]:=CodeTemplatesMenu[  EvaluationNotebook[]];*)

CodeTemplatesMenu[ parentNotebook_NotebookObject, type_String]:= With[
    { nbEvents := CurrentValue[parentNotebook, NotebookEventActions]   
    , appearances := FrontEndResource["FEExpressions","MoreLeftSetterNinePatchAppearance"]
    , $codeTemplates = CodeTemplatesNeeds[] (* 'proper' templates *)
    , selectedAppearance = FrontEndResource["FEExpressions","OrangeButtonNinePatchAppearance"]
    , regularAppearance = FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]     
    }
   
  , DynamicModule[
      { menuObject, closeMenu, n = Length @ $codeTemplates, item       
      }
    , Grid[{{
        If[type =!= "Cell", Nothing, PaneSelector[ 
          { True -> Spacer[{0,0}]
          , False -> Dynamic[ ExpressionCell[$codeTemplates[[item, "Preview"]],               
                "Notebook", "Code", CellFrameMargins->5, CellFrame->True, Magnification-> CurrentValue[Magnification]]
                ]  
          }
        , Dynamic[$codeTemplates[[item, "Preview"]] === None ]
        , ImageSize -> Automatic
        , FrameMargins->15
        ]]
      , Column[
          Table[ With[{i=i}
          , EventHandler[
              PaneSelector[
                { True -> Append[#, Appearance -> selectedAppearance]
                , False -> Append[#, Appearance -> regularAppearance]
                }
               , Dynamic[Refresh[i===item,TrackedSymbols:>{item}]] 
               , ImageSize->Automatic                
               ]& @
              Button[ 
                codeTemplateItemLabel @ $codeTemplates[[i]]
              , codeTemplateApply[parentNotebook, $codeTemplates[[i]]]
              ; closeMenu[]
              , ImageSize -> {All, All}
              
              , FrameMargins-> {{15,15},{2,2}}
              , BaseStyle->{ 
                  "Item"
                , FontColor -> Black 
                }
              ]
            , {"MouseEntered" :> (item = i)  }
            
            ]
          ], {i, n}]
        , BaseStyle-> {15, CacheGraphics -> False, ShowStringCharacters -> True}
        , Spacings->0
        , Alignment-> FromCharacterCode @ {63328}
        ]
      
      }}, Alignment->{Left, Top}, Spacings->{0,0}]  
    , Initialization :> {
        item = 1;
        If[
           type === "Notebook"
         ,
           menuObject = EvaluationNotebook[];
           closeMenu[]:=NotebookClose @ menuObject
         , 
           menuObject = EvaluationCell[];
           closeMenu[]:=NotebookDelete @ menuObject
         ];
              
         nbEvents = {
          "KeyDown" :> (
            codeTemplateApply[parentNotebook, First @ Select[$codeTemplates, Lookup["ShortKey"][#] === CurrentValue["EventKey"]&]]
          ; closeMenu[]
          )
        , "UpArrowKeyDown" :> (item = Mod[item -1, n, 1])
        , "DownArrowKeyDown" :> (item = Mod[item +1, n, 1])
        , "LeftArrowKeyDown" :> {}
        , "RightArrowKeyDown" :> {}
        , "ReturnKeyDown" :> (
            codeTemplateApply[parentNotebook, $codeTemplates[[item]]]
          ; closeMenu[]
          )
        , "EscapeKeyDown" :> closeMenu[]
        , {"MenuCommand", "InsertNewGraphic"} :> {}
        
       (* , ParentList*)
        , PassEventsUp -> False (*prevents KeyDown if arrow was hit.*)
        
        }    
      }
    , Deinitialization :> {        
        nbEvents = Inherited
      }  
    ]
    
  ];


codeTemplateItemLabel// ClearAll
codeTemplateItemLabel[temp_Association]:= If[
  Lookup[temp, "ShortKey", {}]==="NA"
, Pane[temp["Label"], {130+18, All}]  
, Grid[ {{
      Pane[temp["Label"], ImageSize -> {130, All}]    
    , Framed[ Style[ToUpperCase @ temp["ShortKey"],10]
      , FrameMargins -> {{2, 4}, {4, 2}}
      , ImageSize -> {18,18}
      , FrameStyle -> Directive[Thick, GrayLevel[0.7]]
      , ContentPadding -> False
      , RoundingRadius -> 2
      , Background -> GrayLevel[0.99]
      ] 
  }}, Alignment->{Right,Center},Spacings->{0,0}]
];
 


(* ::Subsection::Closed:: *)
(*needs*)


CodeTemplatesNeeds[]:= CodeTemplatesNeeds[] =  CodeTemplatesLoad[];


(* ::Subsection::Closed:: *)
(*load*)


CodeTemplatesLoad[]:= With[
  {path = $templatesCachePath}
,  If[
    FileExistsQ @ path
  , Check[ Import[ path, "MX" ]
    , DeleteFile @ path; CodeTemplatesLoad[]
    ]  
  , CodeTemplatesCache[] /. _String :> CodeTemplatesLoad[]
  ]
];


(* ::Subsection::Closed:: *)
(*cache*)


CodeTemplatesCache[]:=Module[
  { userTempl, cache 
  , userPath = $userTemplatesPath  
  , systemTempl = $codeTemplates
  , cachePath = $templatesCachePath
  }
, Catch[
    userTempl = Check[
        If[ FileExistsQ @ userPath, Import[userPath, {"Package","ExpressionList"}], {}]
      , {}
      ]
  ; Check[
      cache = ToProperTemplate /@ Join[userTempl, systemTempl ]
    , Throw @ $Failed 
    ]
  ; DirectoryNeed @ DirectoryName @  cachePath
  ; Export[ cachePath, cache, "MX"]  
  ]   

];


(* ::Subsection::Closed:: *)
(*reset*)


CodeTemplatesReset::usage = "CodeTemplatesReset[] reloads system and user templates. Should not be needed if evertyhing goes well."

CodeTemplatesReset[]:= (
  If[FileExistsQ[#], DeleteFile[#]]& @ $templatesCachePath
; CodeTemplatesNeeds[] = CodeTemplatesLoad[]
)


(* ::Subsection::Closed:: *)
(*to proper template*)


$defaultTemplate = <| 
  "ShortKey" -> "NA"
, "Preview" -> None
, "ExpandEmptySelection" -> True

|>;


ToProperTemplate[ template:$minimalTemplatePattern]:= Module[
  {temp = template}
 
,  Which[ 
    Not @ KeyExistsQ["Label"] @ temp
  , temp["Label"] = RawBoxes @ temp["Template"]  
  ; temp["Preview"] = None 
  
  , Not @ KeyExistsQ["Preview"] @ temp
  , temp["Preview"] = RawBoxes @ temp["Template"]  
  
  ]
  
; If[
    StringLength[Lookup[ temp, "ShortKey", "NA"] ] > 1
  , temp["ShortKey"] = "NA"
  ]
  
; <|$defaultTemplate, temp|>  
];

ToProperTemplate[___] = ##&[];




(* ::Subsection::Closed:: *)
(*apply*)


  
  codeTemplateApply[notebook_NotebookObject, codeTemplate_ ]:= Module[
    { selInfo:= FrontEndExecute@FrontEnd`UndocumentedGetSelectionPacket[notebook]}
  , Which[ 
      (*is expanding allowed?*)
      Not @ MatchQ[ Lookup[codeTemplate, "ExpandEmptySelection", True]  , True|Automatic]
    , Nothing  
      (*is expanding needed? that is, coursor is inside a cell but nothing is selected*)
    , MatchQ[Lookup[selInfo, {"CellSelectionType", "SelectionType"}, False], {"ContentSelection", "CursorRight"}]
    , FrontEndExecute @ FrontEndToken[notebook, "ExpandSelection"]
    ]    
    
  ; Switch[ codeTemplate["Template"]
    , _RowBox
    , NotebookApply[notebook, codeTemplate["Template"]]
    
    , _String
    , NotebookWrite[
        notebook
      , StringTemplate[codeTemplate @ "Template" ] @  <|
          "sel"-> selectionToString[notebook]
        |>
      ]
      
    ]
  ];


selectionToString[nb_NotebookObject]:=First @ FrontEndExecute @ FrontEnd`ExportPacket[
  BoxData @ NotebookRead @ nb
, "PlainText"
];


(* ::Subsection:: *)
(*user edit*)


(* ::Subsubsection::Closed:: *)
(*$userTemplatesHeader*)


$userTemplatesHeader = StringWrapCommentFrame @ "
                               USER CODE TEMPLATES FILE
Enter your templates delimited by a newline 

Minimal template: <|'Template' -> _(String|RowBox)|>
Optional content: <|'Label' -> _, 'ShortKey' -> _String, 'ExpandEmptySelection' -> True|False|> 

Example from system templates: 

  <| \"Template\" -> RowBox[{\"{\",\"\[SelectionPlaceholder]\", \"}\"}]
   , \"Label\" -> \"Brackets\" 
   , \"ShortKey\" -> \"{\" 
  |>    
";


(* ::Subsubsection::Closed:: *)
(*CodeTemplatesEdit*)


CodeTemplatesEdit::usage = "CodeTemplatesEdit[] opens a user templates editor.";
CodeTemplatesEdit[]:= Module[
  {path = $userTemplatesPath, nb
  }
  
, DirectoryNeed @ DirectoryName @ path
  
; If[
    Not @ FileExistsQ @ path
  , Export[path, $userTemplatesHeader, "Text"]
  ]
  
; nb = NotebookOpen @ path
; SetOptions[nb,
   DockedCells -> {Cell @ BoxData @ ToBoxes @ templatesEditorToolbar[]}
   ]
]  
(*TODO: docked cell with default buttons *)


(* ::Subsubsection::Closed:: *)
(*templatesEditorToolbar*)


templatesEditorToolbar[]:=Grid[{{
  Button["Save and test"
  , NotebookSave[]
  ; CodeTemplatesReset[]
  ; CodeTemplatesMenuOpen[]
  , Appearance->Inherited
  , FrameMargins->{{15,15},{5,5}}
  , Method->"Queued"]
}}
, BaseStyle->{Black, ButtonBoxOptions->{Appearance -> FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]}} ]


(* ::Chapter::Closed:: *)
(*End*)


End[];


EndPackage[];
