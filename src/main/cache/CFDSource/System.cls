<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.System">
<Description><![CDATA[
This class represents some system/project for which we are managing source.
The idea is that the source is held in an external file based repository. We
load up the project, work with it in cache and then export out our changes
when they work. Once we've completed a whole feature (which might be several
local exports/commits) we then merge the changes and push back to a remote
repository for everyone to see.

We link to the Studio Project to determine what is in/not in the system/project.
There is a TestPrefix property to specify a prefix to any artefact in the
project that will be treated as test.

The file system will look like:
<ul><li>{root}/.cacheproject = Description of the system (this class in effect!)</li>
<li>{root}/src/main/cache = All classes and code</li>
<li>{root}/src/main/resources = All {CSP} files and resources</li>
<li>{root}/src/main/data = Any static data globals</li>
<li>{root}/src/test/cache = All test classes and code</li>
<li>{root}/src/test/resources = All test {CSP} files and resources</li>
<li>{root}/src/test/data = Any static test data globals</li>
</ul>

Behaviour of this class can be governed by Globals in the namespace:
<ul><li>^CFDSource("SourceControlClass") = Package.Class extending CFDSource.SourceControl</li>
<li>^CFDSource("Projects", {System}, "WorkDir") = Working directory for {System}</li>
<li>^CFDSource("RootWorkDir") = Default working directory (c:\Dev\Source\ or /opt/dev/ if not set)</li>
<li>^CFDSource("Debug") = The debug level to use (principally applies to Studio Plugin)</li>
<li>^CFDSource("GITHubSSLConfig") = SSL Config used to talk to github (if at all)</li>
<li>^CFDSource("ForwardEdit") = If on allows changes to be made outside of a feature</li>
<li>^CFDSource("Trace") = Level to trace at by default (1, 2 or 3). 2 is the default if balnk</li>
</ul>

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license]]></Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>%RegisteredObject</Super>
<TimeCreated>62659,54308.132568</TimeCreated>

<Property name="Name">
<Description>
The systems name. This is used in creating the path for the working area
It should match the name of a project in the current namespace, although this
class holds the master list of packages/code/data inside the project
Recommended that this should not have spaces in it.</Description>
<Type>%String</Type>
<Required>1</Required>
</Property>

<Property name="Location">
<Description>
The base location for the system (will include trailing / or \)</Description>
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="GroupId">
<Description>
The group this project belongs to (used to ensure Name is unique)</Description>
<Type>%String</Type>
<Required>1</Required>
</Property>

<Property name="Version">
<Description>
The version currently working on
(Note: not really a cast iron version, more what the current branch thinks the next version is going to be)</Description>
<Type>%String</Type>
</Property>

<Property name="Brief">
<Description>
A shortish one liner description of the project/system (optional)</Description>
<Type>%String</Type>
<Parameter name="MAXLEN" value="200"/>
</Property>

<Property name="TestPrefix">
<Description><![CDATA[
A prefix (or list of prefixes) given to test artefacts (classes & resources)]]></Description>
<Type>%String</Type>
</Property>

<Property name="Installer">
<Description>
If present the specific class that is the installer (usually a %Installer)
This class must have a class method called setup that is typically run from the %SYS namespace.
Note: This is not exported as source, it is assumed to be a class in a package that is exported</Description>
<Type>%String</Type>
</Property>

<Property name="Data">
<Description>
Holds the Globals to export as static data for the project
Where Data holds the name as the key, and the global and subscript
as the value (Data[Name]="^Global{("Subscript")})</Description>
<Type>%String</Type>
<Collection>array</Collection>
</Property>

<Property name="TestData">
<Description>
The names of any test globals to export
See Data for more information</Description>
<Type>%String</Type>
<Collection>array</Collection>
</Property>

<Property name="SourceControlPlugin">
<Description>
The source control plugin to use, default is git. Overridden during construction</Description>
<Type>CFDSource.SourceControl</Type>
</Property>

<Method name="%OnNew">
<Description>
Overridden so we sync with the project on disc if it exists</Description>
<FormalSpec>initvalue:%CacheString</FormalSpec>
<Private>1</Private>
<ReturnType>%Status</ReturnType>
<ServerOnly>1</ServerOnly>
<Implementation><![CDATA[
	quit:$G(initvalue)="" $$$ERROR("System name must be provided in %New()")
	
	set ..Name=$ZSTRIP(initvalue, "*PCW")
	set ..SourceControlPlugin=$CLASSMETHOD($G(^CFDSource("SourceControlClass"), "CFDSource.GIT.SourceControl"), "%New")
	quit:..Exists(..Name) ##class(CFDSource.Util.ImportExport).ReadProject($this, ##class(CFDSource.Util.Trace).%New())
	quit $$$OK
]]></Implementation>
</Method>

<Method name="LocationGet">
<Description>
This accessor calculates the project external location for the system</Description>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..ProjectLocation(..Name)
]]></Implementation>
</Method>

<Method name="ProjectLocation">
<Description>
Returns a projects working directory. 
Note: There will be a trailing / or \ at the end of the path</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pName:%String</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	// a. See if project has custom working directory
	quit:$G(pName)'=""&&($D(^CFDSource("Projects", pName, "WorkDir"))=1) ^CFDSource("Projects", pName, "WorkDir")
	
	// b. Otherwise form from root location
	set root=$G(^CFDSource("RootWorkDir"))
	set:root="" root=$system.Util.InstallDirectory()_"Workspaces"
	
	set sep=$S($$$ISWINDOWS:"\", 1:"/")
	quit root_sep_$namespace_sep_$S($G(pName)="":"", 1:pName_sep)
]]></Implementation>
</Method>

<Method name="Exists">
<Description>
This method quickly determines if the project exists as a CFDSource project
If it does not exist, create it as per below</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pName:%String</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set fileName=..ProjectLocation(pName)_".cacheproject"
	quit ##class(%File).Exists(fileName)
]]></Implementation>
</Method>

<Method name="Reload">
<Description>
Reloads the project settings</Description>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	quit:..Exists(..Name) ##class(CFDSource.Util.ImportExport).ReadProject($this, ##class(CFDSource.Util.Trace).%New())
	quit $$$OK
]]></Implementation>
</Method>

<Method name="Save">
<Description>
Saves the project settings (and only the project settings)</Description>
<FormalSpec><![CDATA[&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Checking Status ...")
	do ..SourceControlPlugin.GetStatus($this, .branch, pTrace)
	quit:$G(branch)="" pTrace.SetError($$$ERROR("Project not in a feature, cannot export"))
	
	do pTrace.AddStep("Exporting Project ...")
	set ret=##class(CFDSource.Util.ImportExport).WriteProject($this, pTrace)  quit:$$$ISERR(ret) ret
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="GetCurrentFeature">
<Description>
Call to get current feature branch, if empty string then we are not in any feature</Description>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	quit:'..Exists(..Name) ""
	
	set pTrace=##class(CFDSource.Util.Trace).%New()
	do ..SourceControlPlugin.GetStatus($this, .branch, pTrace)
	quit:$G(branch)="develop" ""
	quit $G(branch)
]]></Implementation>
</Method>

<Method name="StartFeature">
<Description>
Call to start a new development feature</Description>
<FormalSpec><![CDATA[pFeature:%String,pPull:%Boolean=1,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Starting new feature")
	set ret=..SourceControlPlugin.StartFeature($this, pFeature, pPull, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Import in all the source")
	set ret=##class(CFDSource.Util.ImportExport).ImportProject($this, .importItems, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="SwitchFeature">
<Description>
Call to switch to a different development feature. This will of course
undo any local changes since the last commit</Description>
<FormalSpec><![CDATA[pFeature:%String,pPull:%Boolean=1,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Switching to exist feature")
	set ret=..SourceControlPlugin.SwitchFeature($this, pFeature, pPull, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Import in all the source")
	set ret=##class(CFDSource.Util.ImportExport).ImportProject($this, .importItems, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="EndFeature">
<Description><![CDATA[
Call to end the current development feature and merge back into develop branch
An export is done first & commit if required]]></Description>
<FormalSpec><![CDATA[pFinalComment:%String,pPush:%Boolean=1,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Exporting Source")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject($this,,pTrace)  
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Commit")
	set:pFinalComment="" pFinalComment="Automated end feature commit: "_$ZDT($H, 4)
	set ret=..SourceControlPlugin.Commit($this, pFinalComment, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("End the feature")
	set ret=..SourceControlPlugin.EndFeature($this, pPush, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="Package">
<Description>
Exports the system as a package to be installed in another system</Description>
<FormalSpec><![CDATA[pFinal:%Boolean=0,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	do pTrace.AddStep("Package")
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	set ret=##class(CFDSource.Util.Package).ExportPackage($this, pFinal, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="Export">
<Description>
Exports and commits the project</Description>
<FormalSpec><![CDATA[pCommitMessage:%String,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Checking Status ...")
	do ..SourceControlPlugin.GetStatus($this, .branch, pTrace)
	quit:$G(branch)="" pTrace.SetError($$$ERROR("Project not in a feature, cannot export"))
	
	do pTrace.AddStep("Exporting Project ...")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject($this,,pTrace)  quit:$$$ISERR(ret) ret
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Committing ...")
	set:pCommitMessage="" pCommitMessage="Automated checkpoint commit: "_$ZDT($H, 4)
	set ret=..SourceControlPlugin.Commit($this, pCommitMessage, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="Import">
<Description>
Imports the source from the local repository and optionally pulls
it from a remote source. This overwrites any changes inside the namespace
since last exported/committed</Description>
<FormalSpec><![CDATA[pPull:%Boolean=0,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	if pPull {
		do pTrace.AddStep("Pulling in source")
		set ret=..SourceControlPlugin.Pull($this, pTrace)
		quit:$$$ISERR(ret) pTrace.SetError(ret)
	}
	
	do pTrace.AddStep("Importing in Project")
	set ret=##class(CFDSource.Util.ImportExport).ImportProject($this, .importItems, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="Initialise">
<Description>
This method will initialise the project, setup the local source control for it
and optionally connect to a remote repository (pRepoUrl).
Note: The remote repository is not created as part of this operation.</Description>
<FormalSpec><![CDATA[pRepoUrl:%String,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Exporting Project ...")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject($this,,pTrace)  quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Starting Source Project ...")
	set ret=..SourceControlPlugin.CreateProject($this, pRepoUrl, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>

<Method name="Clone">
<Description>
This method will attempt to clone a remote repository to setup the local 
repository for this system. Once complete it will then import in all the
source and setup the %Studio.Project</Description>
<FormalSpec><![CDATA[pRepoUrl:%String,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddStep("Cloning Project ...")
	set ret=..SourceControlPlugin.ImportProject($this, pRepoUrl, pTrace)  quit:$$$ISERR(ret) pTrace.SetError(ret)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	do pTrace.AddStep("Importing Project ...")
	set ret=##class(CFDSource.Util.ImportExport).ImportProject($this, .importItems, pTrace)
	quit:$$$ISERR(ret) pTrace.SetError(ret)
	
	quit ret
]]></Implementation>
</Method>
</Class>
</Export>
