(*please consider it beta before it hits 1.0.0*)

### What's there?

- A dark stylesheet with code templates menu.

  It is based on a built-in ReverseColor.nb but adapted a little for .m .wl files. 

- Code templates
 
  Templates menu can be open with <kbd>Ctrl</kbd> + <kbd>O</kbd> shortkey.
  
- Custom code templates

  Hit 'Edit code templates' and add custom entries in opened file.
  
      <| "Template" -> _String | _RowBox (*the only one which is reqiired*)
       , "Label" -> _
       , "Shortkey" -> _?(StringMatchQ[Character])
       , "ExpandSelection" -> _boole:True
       , "Preview" -> _ : None
      |>
      
  - Template
    - `_RowBox` : whatever PasteButton can handle it should too
    - `_String` : StringTemplate syntax with `` `sel` `` as a placeholder for a selection data. This needs to be polished as it assumes the selection will be a single token, not a BoxForm.  
    
  - Label, menu item label, is optional but for longer templates it is encouraged.
  - Shortkey, optional, with opened menu it will automatically launch associated template
  - ExpandSelection: whether to expand selection if nothing is selected
  - Preview should be automatically generated form "Template" (unless Template was used as a Label). You can use whatever you want as a preview though.
  

![Alt text](Dev/CodeTemplates.gif?raw=true "Title")
    

### Installation

- Manual

  Go to 'releases' tab and download appropriate .paclet file.
   
  Run `PacletInstall @ path/to/the.paclet` file
  
- via MPM
  
  If you don't have ``MPM` `` yet, run:
  
  `Import["https://raw.githubusercontent.com/kubapod/mpm/master/install.m"]`
  
  and then:
  
  ``Needs @ "MPM`"``
   
  ``MPM`MPMInstall["kubapod", "devtools"]``
  
### Setup dark stylesheet with code templates
  
In order to use the stylesheet as a default one for .m/.wl files, run:
   
    CurrentValue[$FrontEnd, "DefaultPackageStyleDefinitions"
    ] = FrontEnd`FileName[{"DevTools", "DevPackageDark.nb"}]
      
And if you don't like it:

    CurrentValue[$FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "Package.nb"
    
### I don't like dark styles but I do like code templates
    
Alternatively, if you don't want to use dark styles but code templates you can install ``Shortcuts` `` package and modify the joker.m file. Here's what you have to do:
    
- install ``Shortcuts` `` ([mathematica.se.com thread](https://mathematica.stackexchange.com/q/68864/5478))
    
      Get["http://www.mertig.com/shortcuts.m"]
      
- open `joker.m` <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>J</kbd>

- comment everything and put this snippet at the bottom:

      Block[{$ContextPath}, Needs["DevTools`"]; CodeTemplatesMenuOpen[] ]
      
- save, close and the menu should open on <kbd>Ctrl</kbd>+<kbd>t</kbd>

- to edit user templates run

      Needs["DevTools`"]; CodeTemplatesEdit[]


 
 
