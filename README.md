### What's there?

Dark stylesheet:

It is based on a built-in ReverseColor.nb but adapted a little for .m .wl files. 


![Imgur](http://i.imgur.com/tJLjerWm.png)



    CurrentValue[
        $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "DeveloperPackageDark.nb"

but if you want the default on back:

    CurrentValue[
            $FrontEnd, "DefaultPackageStyleDefinitions"
    ] = "Package.nb"

### Installation

- Manual

  Go to 'releases' tab and download appropriate .paclet file.
   
  Run `PacletInstall @ path/to/the.paclet` file
  
- via MPM
  
  If you don't have ``MPM` `` yet, run:
  
  `Import["https://raw.githubusercontent.com/kubapod/mpm/master/install.m"]`
  
  and then:
  
  ``Needs @ "MPM`"``
   
  ``MPM`MPMInstall["kubapod", "morestyles"]``
 
