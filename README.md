Currently this paclet contains only one style so I did't spend time on creating any fancy api.

It is based on a built-in ReverseColor.nb but adapted a little for .m .wl files. 

It also supports multiline indentation of code!

![Imgur](http://i.imgur.com/tJLjerW.png)

### Installation

- Manual

  Go to 'releases' tab and download appropriate .paclet file.
   
  Run `PacletInstall @ path/to/the.paclet` file
  
- via MPM
  
  If you don't have ``MPM` `` yet, run:
  
  `Import["https://raw.githubusercontent.com/kubapod/mpm/master/install.m"]`
  
  and then:
  
  ``MPM`MPMInstall["kubapod", "morestyles"]``
 

### Enabling package dark stylesheet

 

If you want to enable dark theme for packages just install the paclet and run:
 
 
    CurrentValue[
        $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "DeveloperPackageDark.nb"
    
Each new or reopened .m .wl file will now use this style by default.
    
And if you are not amazed just run
    
    CurrentValue[
            $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "Package.nb"
    
to set the default one back.
