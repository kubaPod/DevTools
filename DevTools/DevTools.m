(* ::Package:: *)

(* :Author: Kuba Podkalicki *)
(* :Date: 2017-04-23 *)


(* ::Chapter:: *)
(*Begin*)


BeginPackage["DevTools`"];

  Needs @  "PacletManager`"


IndentCode;

CodeTemplatesEnable; CodeTemplatesDisable;
NotebookActionsEnable; NotebookActionsDisable;

OpenNotebookMenu;
CodeTemplatesEdit;
EditNotebookActions;
CodeTemplatesReset;


LocalizeVariable;
RenameLocal;


CenterToParent;


PacletVersionIncrement;


KeyFrame;


Begin["`Events`"];


(* ::Chapter:: *)
(*Content*)


$paclet = CreatePaclet @ DirectoryName[ $InputFileName /. "" :> NotebookFileName[] ];


(* ::Section:: *)
(*Utilities*)


(* ::Subsection::Closed:: *)
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



(* ::Subsection::Closed:: *)
(*CurrentValue*)


AddToCurrentValue[parent_, path_, rule:(_Rule|_RuleDelayed)] := Switch[ CurrentValue[parent, path]
, KeyValuePattern[{}], CurrentValue[parent, path] = Normal @ <|CurrentValue[parent, path], rule|>
, _                  , CurrentValue[parent, path] = {rule}
];

DropFromCurrentValue[parent_, path_, key_]:= Switch[ CurrentValue[parent, path]
, KeyValuePattern[{}], CurrentValue[parent, path] = CurrentValue[parent, path] // KeyDrop[key] // Normal
, _                  , CurrentValue[parent, path] 
];


(* ::Subsection:: *)
(*RenameLocal*)


(* ::Subsection:: *)
(*LocalizeVariable*)


LocalizeVariable::usage = "LocalizeVariable[] adds selected symbol to a parent scoping construct spec.";


LocalizeVariable[] /; $Notebooks := Catch @ Module[
        {emptyListQ, finalEnd, finalStart,  insertion,   symbol, selection
        , selectionTokens, abort
        , nb = FrontEnd`InputNotebook[]
        
        }
        
      , abort = Function[{what, restoreSelectionQ}
        , Beep[]
        ; If[restoreSelectionQ, SelectionMoveRange[finalStart, finalEnd] ]
        ; Throw @ $Failed
        ]
      
      ; symbol = selection = CurrentValue[nb, "SelectionData"] 
      
      ; If[ ! SymbolNameQ @ symbol , abort[$Failed, False]  ]
      
      ; {finalStart, finalEnd} = "CharacterRange" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb]
      ; insertion            = symbol
                   
      ; While[
          True
          
        , selection = Last @ FrontEndCall[
            { "SilentMove", All, Expression} (*ExpandSelection does not support AutoScroll :( *)                 
          , { "Get", "SelectionData"}                  
          ]
          
        ; If[ selection === $Failed  ,  abort[$Failed, True]  ]
          
        ; selectionTokens = StripBoxes @ selection /. RowBox | BoxData -> List // Flatten
          
        ; If[ ScopingBoxTokens @ selectionTokens, Break[] ]
        ]  
          
      ; emptyListQ = MatchQ[ {_, "[", "{", "}", ___} ] @ selectionTokens
          
      ; If[ Not @ emptyListQ, insertion = insertion<>"," ]      
          
      ; finalStart += StringLength @ insertion        
      ; finalEnd   += StringLength @ insertion        
            
      ; FrontEndCall[
              {"SilentMove" , Before, Word}, (*before Module *)
              {"SilentMove" , After , Word, 3}, (*after Module[{ *)
              {"SilentWrite", insertion},
              {"SilentMove", Before, CellContents},
              {"SilentMove", Next  , Character, finalStart},
              {"SilentMove", All   , Character, finalEnd - finalStart}
        ]
    ]


SelectionMoveRange[start_Integer, end_Integer]:=FrontEndCall[
         {"SilentMove", Before, CellContents},
         {"SilentMove", Next  , Character, start},
         {"SilentMove", All   , Character, end-start}
       ]


SymbolNameQ = MatchQ[ _String ? (StringMatchQ[LetterCharacter~~(LetterCharacter|DigitCharacter|"$")...] )]
ScopingBoxTokens = MatchQ[ {"Module"|"With"|"Block"|"DynamicModule"|"Internal`InheritedBlock","[", ___} ]
StandardScopingBoxesQ = MatchQ[ RowBox[{"Module"|"With"|"Block"|"DynamicModule"|"Internal`InheritedBlock","[",___}] ]


FrontEndCall[args___]:= FrontEndCall @ {args}
FrontEndCall[list_]:= FrontEndExecute @ Map[ToFrontEndExpression] @ list;

ToFrontEndExpression::invArg = "Unknown action: ``";

ToFrontEndExpression[{"SilentMove", args__}]:= FrontEnd`SelectionMove[FrontEnd`InputNotebook[], args, AutoScroll -> False]
ToFrontEndExpression[{"SilentWrite", args__}]:= FrontEnd`NotebookWrite[FrontEnd`InputNotebook[], args, AutoScroll -> False]
ToFrontEndExpression[{"Get", args__}]:= FrontEnd`Value[FrontEnd`CurrentValue[FrontEnd`InputNotebook[], args], True];

ToFrontEndExpression[args___]:= Message[ToFrontEndExpression::invArg, args]


(* ::Section::Closed:: *)
(*Resource management*)


(* ::Subsection::Closed:: *)
(*aux*)


$throwOnFailed[$Failed]:=Throw @ $Failed;
$throwOnFailed[x_]:=x;


(* ::Subsection:: *)
(*Needs*)


NeedsResource[paclet:(_Paclet|_PacletObject), res_String]:= Catch[
  NeedsResource[paclet, res] = $throwOnFailed @ GetResource[paclet, res]
];



(* ::Subsection:: *)
(*Get*)


GetResource[paclet:(_Paclet|_PacletObject), res_String]:= Catch @ Module[{cachePath}
, cachePath = ResourceCachePath[paclet, res]
; If[
    FileExistsQ @ cachePath
    
  , Import[ cachePath, "MX" ] // $throwOnFailed
  
  , CacheResource[paclet, res] // MatchQ[_String?FileExistsQ] // TrueQ // Replace[False :> Throw @ $Failed]
  ; GetResource[paclet, res]
  ]
]



(* ::Subsection:: *)
(*Cache*)


CacheResource[paclet:(_Paclet|_PacletObject), res_String]:= Catch @ Module[{userRes, pacletRes, pacletResPath, cachePath, standardizer, resource}
, pacletResPath =        ResourcePath[paclet, res]
; cachePath     =   ResourceCachePath[paclet, res]
; standardizer  = StandardizeResource[paclet, res] (*Comment*)

; userRes   = standardizer @ GetUserResource[paclet, res] 
; pacletRes = standardizer @ ImportResource @ pacletResPath // $throwOnFailed 

; DirectoryNeed @ DirectoryName @ cachePath
; resource = MergeResource[userRes, pacletRes]

; Export[cachePath, resource, "MX"]
]



(* ::Subsection:: *)
(*GetUsersRes*)


GetUserResource[paclet:(_Paclet|_PacletObject), res_String]:=Module[{path}
, path = UserResourcePath[paclet, res]
; If[
    Not @ FileExistsQ @ path
  , {}
  , Check[ImportResource[paclet, res, path], {}] (*TODO: msg?*)
  ]


]


(* ::Subsection::Closed:: *)
(*Import // Standardize // Merge*)


StandardizeResource[paclet:(_Paclet|_PacletObject), res_String]:= Identity;


MergeResource[userRes_, pacletRes_]:=Join[userRes, pacletRes];


ImportResource[path_String]:=Import[path, {"Package","ExpressionList"}];
ImportResource[_, _, path_String]:= Import[path, {"Package","ExpressionList"}];



(* ::Subsection::Closed:: *)
(*Reset*)


ResetResource[paclet:(_Paclet|_PacletObject), res_String]:= (
  ResourceCachePath[paclet, res] // If[FileExistsQ[#], DeleteFile[#]]&
; NeedsResource[paclet, res] =.
; NeedsResource[paclet, res]
);


(* ::Subsection:: *)
(*paths*)


UserResourcePath[paclet:(_Paclet|_PacletObject), res_String]:= FileNameJoin[{
  $UserBaseDirectory, "ApplicationData", paclet @ "Name", res <> ".m"
}];

ResourceCachePath[paclet:(_Paclet|_PacletObject), res_String]:= FileNameJoin[{
  $UserBaseDirectory, "ApplicationData", paclet @ "Name", paclet @ "Version", res <> ".m"
}]

ResourcePath[paclet:(_Paclet|_PacletObject), res_String]:= FileNameJoin[{
  paclet @ "Location", "Resources", res <> ".m"
}]


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


(* ::Subsection:: *)
(**)


(* ::Section::Closed:: *)
(*Menu open*)


OpenNotebookMenu[content_String : "CodeTemplates"]:=OpenNotebookMenu[content, EvaluationNotebook[]];

OpenNotebookMenu[content_String : "CodeTemplates", nb_NotebookObject]:=OpenNotebookMenu[
  content
, nb
, CurrentValue[$FrontEnd, {TaggingRules, "DevTools", "MenuMethod"}, "Notebook"]
];  



OpenNotebookMenu // Options = {
   "Anchor" -> {-1, {Right, Top}}
 , "Alignment" -> {Right, Top}  
};

OpenNotebookMenu[content_String, nb_NotebookObject, "Cell", OptionsPattern[]] := With[
  { anchor = OptionValue["Anchor"]
  , alignment  = OptionValue["Alignment"]
  }
, MathLink`CallFrontEnd[
    FrontEnd`AttachCell[
        nb
      , Cell[
          BoxData @ ToBoxes @ NotebookMenu[content, nb, "Cell"]
        , CellSize      -> Automatic
        , Magnification ->CurrentValue[Magnification]
        ]
      , anchor
      , alignment
      , "ClosingActions" -> { "OutsideMouseClick" }
    ]  
  ]
]  


OpenNotebookMenu[content_String, nb_NotebookObject, "Notebook"]:=NotebookPut @ CenterToParent @ Notebook[
  List @ Cell[
    BoxData @ ToBoxes @ NotebookMenu[content, nb, "Notebook"]
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


(* ::Section::Closed:: *)
(*CodeTemplates*)


(* ::Subsection::Closed:: *)
(*Config*)


StandardizeResource[$paclet, "CodeTemplates"]:= Map[ToProperTemplate];


  (*sets the default value if not present*)
CurrentValue[
  $FrontEnd
, {TaggingRules, "DevTools", "MenuMethod"}
, If[$VersionNumber < 11, "Notebook", "Cell"]
]; 


CodeTemplatesEnable[]:= AddToCurrentValue[$FrontEnd, NotebookEventActions, 
  {"MenuCommand", "InsertNewGraphic"} :> Block[{$ContextPath}, Needs["DevTools`"]; OpenNotebookMenu["CodeTemplates"] ]
] 


CodeTemplatesDisable[]:= DropFromCurrentValue[$FrontEnd, NotebookEventActions, {"MenuCommand", "InsertNewGraphic"} ]


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
(*default templates' utilities*)


 (*The way NotebookWrite works allows us writing cell expressions mixed with strings that need to be parsed yet. 
      It is way more readable and easier to write. Don't know how robust it is but I am to lazy to change this ;)
     *)
     
evaluatedTestTemplate[selection_]:= DynamicWrapper[
  ProgressIndicator[Appearance->"Percolate"]
, Module[
    { result =  ToString[ ToExpression @ selection, InputForm]  }
  , NotebookWrite[EvaluationBox[], RowBox @ List @ result, After]  
  ; If[ $MessageList =!= {}
    , NotebookWrite[EvaluationNotebook[], RowBox[{"\n, ", ToBoxes[ RawBoxes @* First /@ (MakeBoxes @@@ $MessageList)]}]]
    ]
  ]
, SynchronousUpdating -> False

]  
(* I'm not using Dynamic with DestroyAfterEvaluation because returning a sequence / rowbox does not play well with existing structure.
  And because CachedValues is somehow ignored *)

(*TODO: investigate why CachedValue is not respected when templates are applied, it seems it is not only because it is done via preemptive link *)
    
  


(* ::Subsection::Closed:: *)
(*Menu*)


(*TODO: preburn this one day*)


NotebookMenu[ "CodeTemplates", parentNotebook_NotebookObject, type_String]:= Catch @ With[
    { nbEvents          := CurrentValue[parentNotebook, NotebookEventActions]
    , appearances       := FrontEndResource["FEExpressions","MoreLeftSetterNinePatchAppearance"]
    , selectedAppearance = FrontEndResource["FEExpressions","OrangeButtonNinePatchAppearance"]
    , regularAppearance  = FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]
    , $codeTemplates     = NeedsResource[$paclet, "CodeTemplates"] // If[! ListQ@#, Beep[];Throw @ $Failed, #]& (* 'proper' templates *)
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
  Lookup[temp, "ShortKey", "NA"] === "NA"
, Pane[temp["Label"], {130+18, All}]  
, Grid[ {{
      Pane[temp["Label"], ImageSize -> {130, All}]    
    , KeyFrame @ ToUpperCase @ temp["ShortKey"]
  }}, Alignment->{Right,Center},Spacings->{0,0}]
];



KeyFrame[key_, opts___]:=Framed[ Style[key,10]
      , opts
      , FrameMargins -> {{2, 4}, {4, 2}}
      , ImageSize -> {18,18}
      , FrameStyle -> Directive[Thick, GrayLevel[0.7]]
      , ContentPadding -> False
      , RoundingRadius -> 2
      , Background -> GrayLevel[0.99]
      ]


(* ::Subsection::Closed:: *)
(*ToProperTemplate*)


$defaultTemplate = <| 
  "ShortKey" -> "NA"
, "Preview" -> None
, "ExpandEmptySelection" -> True

|>;


$minimalTemplatePattern = (_Association)?(KeyExistsQ["Template"]); (*earlier than KeyValuePattern*)


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
(*CodeTemplateApply*)


  
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
    , NotebookApply[notebook
      , TemplateApply[ codeTemplate["Template"], <|"sel" -> selectionToBoxes @ NotebookRead[notebook]|>]
      ] (*this was a simple selection placeholder templates can be used but also more advanced utilizing tempaltes *)
    
    , _String
    , NotebookWrite[
        notebook
      , StringTemplate[codeTemplate @ "Template" ] @  <| "sel"-> selectionToString[notebook] |>
      ]
      
    ]
  ];


selectionToString[nb_NotebookObject]:=First @ FrontEndExecute @ FrontEnd`ExportPacket[
  BoxData @ NotebookRead @ nb
, "PlainText"
];


selectionToBoxes[Cell[data_,___]] := selectionToBoxes @ data;
selectionToBoxes[BoxData[boxes_]]:= boxes;
selectionToBoxes[{}]:= ##&[];
selectionToBoxes[boxes_]:=boxes;


(* ::Subsection::Closed:: *)
(*user edit*)


(* ::Subsubsection::Closed:: *)
(*$userTemplatesHeader*)


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


(* ::Subsubsection:: *)
(*CodeTemplatesEdit*)


CodeTemplatesEdit::usage = "CodeTemplatesEdit[] opens a user templates editor.";
CodeTemplatesEdit[]:= Module[
  {
    path = UserResourcePath[$paclet, "CodeTemplates"]
  , nb
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


(* ::Subsubsection:: *)
(*templatesEditorToolbar*)


templatesEditorToolbar[]:=Grid[{{
  Button["Save and test"
  , NotebookSave[]
  ; ResetResource[$paclet, "CodeTemplates"]
  ; OpenNotebookMenu[]
  , Appearance->Inherited
  , FrameMargins->{{15,15},{5,5}}
  , Method->"Queued"]
}}
, BaseStyle->{Black, ButtonBoxOptions->{Appearance -> FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]}} ]


(* ::Section::Closed:: *)
(*NotebookActions*)


NotebookActionsEnable[]:= AddToCurrentValue[$FrontEnd, NotebookEventActions, 
  {"MenuCommand", "NewColumn"} :> Block[{$ContextPath}, Needs["DevTools`"]; OpenNotebookMenu["NotebookActions"] ]
] 


NotebookActionsDisable[]:= DropFromCurrentValue[$FrontEnd, NotebookEventActions, {"MenuCommand", "NewColumn"}] 


(* ::Subsection::Closed:: *)
(*OpenNotebookMenu*)


OpenNotebookMenu["NotebookActions", nb_NotebookObject, "Cell"]:=OpenNotebookMenu[
  "NotebookActions", nb, "Cell"
, "Anchor" -> {1, {Left, Top}}
, "Alignment" -> {Left, Top}
]


(* ::Subsection:: *)
(*NotebookMenu*)


NotebookMenu[ "NotebookActions", parentNotebook_NotebookObject, type_String]:= Catch @ With[
    { nbEvents          := CurrentValue[parentNotebook, NotebookEventActions]
    , appearances       := FrontEndResource["FEExpressions","MoreLeftSetterNinePatchAppearance"]
    , selectedAppearance = FrontEndResource["FEExpressions","OrangeButtonNinePatchAppearance"]
    , regularAppearance  = FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]
    , $actions     = NeedsResource[$paclet, "NotebookActions"]  // If[! ListQ@#, Beep[];Throw @ $Failed, #]& (* 'proper' templates *)
    }
   
  , DynamicModule[
      { menuObject, closeMenu, n = Length @ $actions, item       
      }
    , Grid[{{
        Column[
          Table[ With[{i = i, $action = $actions[[i]]}
          , EventHandler[
              PaneSelector[
                { True -> Append[#, Appearance -> selectedAppearance]
                , False -> Append[#, Appearance -> regularAppearance]
                }
               , Dynamic[Refresh[i === item,TrackedSymbols:>{item}]] 
               , ImageSize->Automatic                
               ]& @
              Button[ 
                codeTemplateItemLabel @ $action
              , $action["Action"]
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
          "KeyDown" :> ((*TODO what if select \[Rule] {} *)
            Lookup["Action"] @ First @ Select[$actions, Lookup["ShortKey"][#] === CurrentValue["EventKey"]&]
          ; closeMenu[]
          )
        , "UpArrowKeyDown" :> (item = Mod[item -1, n, 1])
        , "DownArrowKeyDown" :> (item = Mod[item +1, n, 1])
        , "LeftArrowKeyDown" :> {}
        , "RightArrowKeyDown" :> {}
        , "ReturnKeyDown" :> (
            $actions[[item, "Action"]]
          ; closeMenu[]
          )
        , "EscapeKeyDown" :> closeMenu[]
        , {"MenuCommand", "NewColumn"} :> {}
        
       (* , ParentList*)
        , PassEventsUp -> False (*prevents KeyDown if arrow was hit.*)
        
        }    
      }
    , Deinitialization :> {        
        nbEvents = Inherited
      }  
    ]
    
  ];


(* ::Subsection:: *)
(*user edit*)


(* ::Subsubsection::Closed:: *)
(*$userTemplatesHeader*)


$userActionsHeader = StringWrapCommentFrame @ "
                               USER NOTEBOOK ACTIONS FILE

Enter your items delimited by a newline 

 <|                        (*!!!   DON'T FORGET ABOUT :> FOR THE ACTION !!! *)
    \"Label\"    -> _String, 
    \"ShortKey\" -> _String, 
    \"Action\"   :> foo[] 
|>

Example from default items:

<|
  \"Label\"    -> \"Select cell\"
, \"ShortKey\" -> \"a\"
, \"Action\"   :> SelectionMove[First @ SelectedCells @ EvaluationNotebook[],All,Cell]
|>   
";


(* ::Subsubsection::Closed:: *)
(*CodeTemplatesEdit*)


EditNotebookActions::usage = "CodeTemplatesEdit[] opens a user templates editor.";
EditNotebookActions[]:= Module[
  {
    path = UserResourcePath[$paclet, "NotebookActions"]
  , nb
  }
  
, DirectoryNeed @ DirectoryName @ path
  
; If[
    Not @ FileExistsQ @ path
  , Export[path, $userActionsHeader, "Text"]
  ]
  
; nb = NotebookOpen @ path
; SetOptions[nb,
   DockedCells -> {Cell @ BoxData @ ToBoxes @ eventsEditorToolbar[]}
   ]
]  
(*TODO: docked cell with default buttons *)


(* ::Subsubsection::Closed:: *)
(*templatesEditorToolbar*)


eventsEditorToolbar[]:=Grid[{{
  Button["Save and test"
  , NotebookSave[]
  ; ResetResource[$paclet, "NotebookActions"]
  ; OpenNotebookMenu["NotebookActions"]
  , Appearance->Inherited
  , FrameMargins->{{15,15},{5,5}}
  , Method->"Queued"]
}}
, BaseStyle->{Black, ButtonBoxOptions->{Appearance -> FrontEndResource["FEExpressions","GrayButtonNinePatchAppearance"]}} ]


(* ::Section::Closed:: *)
(*Paclets utilities*)


(* ::Subsection::Closed:: *)
(*PacletVersionIncrement*)


PacletVersionIncrement::noPacletE = "Failed to get :(_Paclet|_PacletObject) from ``";
PacletVersionIncrement::noSemVer = "Paclet Version is not of 'X.Y.Z' form";
 
PacletVersionIncrement[p:(_Paclet|_PacletObject), spec___]:= PacletVersionIncrement[
  FileNameJoin[{p @ "Location", "PacletInfo.m"}]
, spec
];

PacletVersionIncrement[piPath_String?FileExistsQ, versionType:"Major"|"Minor"|"Patch"|"Manual"|"Date"|"Date&Hour"]:=Module[
  { pacletE
  , tag = "PVI"}
, Catch[
    pacletE = Get[piPath]
    
  ; If[ Head @ pacletE =!= Paclet
    , Message[PacletVersionIncrement::noPacletE, piPath]
    ; Throw[$Failed, tag]
    ]
    
  ; If[ 
      Not @ MemberQ[pacletE, Version -> semVerPattern]
    , Message[PacletVersionIncrement::noSemVer, pacletE]
    ; Throw[$Failed, tag]
    ]
    
  ; pacletE = pacletE /. (
      Version -> version_) :> (
      Version -> (
        incrementVersion[versionType, version] /. r:Except[_String]:>Throw[r,tag])
      )
      
  
  ; Block[{ Internal`$ContextMarks=False }
    , Export[
        piPath
      , pacletE
      , "Package"
      , PageWidth->80
      ]
    ]
    
  ; Version /. List @@ pacletE  
             
  , tag
  ]
]; 



incrementVersion["Date", version_String]:=StringRiffle[Date[][[;;3]],"."];
incrementVersion["Date&Hour", version_String]:=StringRiffle[Date[][[;;4]],"."];
incrementVersion["Manual", version_String]:=InputString["Enter next version. (current version - "<>version<>")"];
incrementVersion[versionType_String, version_String]:=Module[
  { digits = ToExpression /@ StringSplit[version, "."]
  , n0 = 1
  }
  , Catch[
      n0 = Switch[versionType
      , "Major", 1
      , "Minor", 2  
      , "Patch", 3 
        (*maybe add default or msg*)
      ]
    ; digits[[n0]]++
    ; digits[[n0 + 1 ;;]] = 0
    ; StringRiffle[digits, "."]
    ]
]


semVerPattern = s_ /; StringMatchQ[s, ( DigitCharacter.. ~~ "."|"" ).. ]


(* ::Chapter:: *)
(*End*)


End[];


EndPackage[];


