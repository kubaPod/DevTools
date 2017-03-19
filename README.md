Currently this paclet contains only one style so I did't spend time on creating any fancy api.

![Imgur](http://i.imgur.com/tJLjerW.png)

### Installation

Just run this code stolen from [szhorvat/MaTeX](https://github.com/szhorvat/MaTeX) and adjusted a little bit:

    Module[{json, download, target}
      , Check[
            json = Import[
                "https://api.github.com/repos/kubapod/MoreStyles/releases/latest"
              , "JSON"
            ]
          ; download = Lookup[First @ Lookup[json, "assets"], "browser_download_url"]
          ; target = FileNameJoin[{CreateDirectory[], "paclet.paclet"}]
          ; If[
                $Notebooks
              , PrintTemporary @ Labeled[ProgressIndicator[Appearance -> "Necklace"]
                  , "Downloading...", Right]
              , Print["Downloading..."]
            ]
          ; URLSave[download, target]
          , Return[$Failed]
        ]
      ; If[FileExistsQ[target], PacletInstall[target], $Failed]
    ]

### Enabling package dark stylesheet

 

If you want to enable dark theme for packages just install the paclet and run:
 
 
    CurrentValue[
        $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "ReverseColorPackage.nb"
    
    
And if you are not amazed just run
    
    CurrentValue[
            $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "Package.nb"
    
to set the default one back.