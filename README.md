(*please consider it beta before it hits 1.0.0*)

### What's there?

- Dark theme for .m/.wl files 

- Customizable Code Templates (see below and [SE: Live code templates](https://mathematica.stackexchange.com/q/164653/5478))

- Customizable Notebook Actions (see below and [SE: custom un/comment](https://mathematica.stackexchange.com/q/184562/5478))
  

### Installation / Updating

- Manual way

  Go to 'releases' tab and download appropriate .paclet file.
   
  Run `PacletInstall @ path/to/the.paclet` file
  
- via MPM
  
      (*If you don't have MPM` yet*)
      Import["https://raw.githubusercontent.com/kubapod/mpm/master/install.m"] 
  
      Needs @ "MPM`"   
      MPM`MPMInstall["kubapod", "devtools"]
      
      (* now see 'Setup dark stylesheet with all features' section below*)      

### Uninstall
  
      PacletUninstall /@ PacletFind["DevTools"];
      DeleteDirectory[FileNameJoin[{$UserBaseDirectory, "AppliactionData", "DevTools"}], 
        DeleteContents -> True
      ];
      

  
## Quick Guide  
  
### Setup dark stylesheet with all features
    
  In order to use the stylesheet as a default one for .m/.wl files, run:
     
      CurrentValue[$FrontEnd, "DefaultPackageStyleDefinitions"
      ] = FrontEnd`FileName[{"DevTools", "DevPackageDark.nb"}]
        
  And if you don't like it:
  
      CurrentValue[$FrontEnd, "DefaultPackageStyleDefinitions"
      ] = "Package.nb"
  


### Code templates  

  Templates menu is available in DevPackageDark.nb stylesheet mentioned above. 
  This stylesheet is not tested for regular notebooks yet but if you want to enable templates menu for any notebook you can run:
  
  ```Mathematica
  SetOptions[$FrontEnd, NotebookEventActions -> {
     {"MenuCommand", "InsertNewGraphic"} :> Block[{$ContextPath}, Needs["DevTools`"]; DevTools`OpenNotebookMenu["CodeTemplates"] ]
     , ParentList}
  ]  (*This hijacks Ctrl+1 shortkey*)
  ```
  
  Templates menu can be opened with <kbd>Ctrl</kbd> + <kbd>1</kbd> shortkey.
    
  Custom code templates can be added via package toolbar / Templates&Actions / EditCodeTemplates item.
  
      <| "Template" -> _String | _RowBox (*the only one which is reqiired*)
       , "Label" -> _
       , "ShortKey" -> _?(StringMatchQ[Character])
       , "ExpandSelection" -> _boole:True
       , "Preview" -> _ : None
      |>
      
  - Template
    - `_RowBox` : whatever PasteButton can handle it should too
    - `_String` : StringTemplate syntax with `` `sel` `` as a placeholder for a selection data. This needs to be polished as it assumes the selection will be a single token, not a BoxForm.  
    
  - Label, menu item label, is optional but for longer templates it is encouraged.
  - ShortKey, optional, with opened menu it will automatically launch associated template
  - ExpandSelection: whether to expand selection if nothing is selected
  - Preview should be automatically generated form "Template" (unless Template was used as a Label). You can use whatever you want as a preview though.
  

![Alt text](Dev/CodeTemplates.gif?raw=true "Title")
    
  
### Notebook actions

They are very similar to templates feature.
 
 Actions menu is available in DevPackageDark.nb stylesheet mentioned above. 
   This stylesheet is not tested for regular notebooks yet but if you want to enable actions menu for any notebook you can run:
   
   ```Mathematica
   SetOptions[$FrontEnd, NotebookEventActions -> {
      {"MenuCommand", "Print"} :> Block[{$ContextPath}, Needs["DevTools`"]; DevTools`OpenNotebookMenu["CodeTemplates"] ]
      , ParentList}
   ]  (*This highjacks Ctrl+1 shortkey*)
   ```

! Important note is that it hijacks print event, which for packages does not matter but can be annoying for regular notebooks.
Feel free to replace `"Print"` with whatever you find convenient.

Difference is that the menu with actions is invoked by <kbd>Ctrl</kbd> + <kbd>p</kbd> and an action item should look like this:

     <|                        (*!!!   DON'T FORGET ABOUT :> FOR THE ACTION !!! *)       
     "Label"    -> _String,
     "ShortKey" -> _String,
     "Action"   :> foo[]   
     |>   
    

 
