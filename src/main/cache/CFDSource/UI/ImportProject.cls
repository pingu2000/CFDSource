<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.ImportProject">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,76105.371683</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default>Project Settings</Default>
</Parameter>

<XData name="templateBody">
<Description>
This XML block defines the contents of this page.</Description>
<XMLNamespace>http://www.intersystems.com/zen</XMLNamespace>
<Data><![CDATA[
<pane xmlns="http://www.intersystems.com/zen">
<tabGroup id="contents" width="100%">
<tab id="frmpane" width="100%">
<vgroup enclosingClass="dialog" width="100%">
<!-- Description -->
<vgroup width="100%" enclosingClass="description">
<html>This will clone a project from a remote GIT repository and import it</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="" label="Name:" enclosingClass="fld" size="80" />
<text id="repo" name="Repo" value="" label="Repository:" enclosingClass="fld" size="80" />
<html enclosingClass="notes">Use a GIT URL that requires no password. Either file:// or GITHub if private key with no passphrase</html>
</vgroup>
</vgroup>
</tab>

<tab id="outputpane">
<!-- Output -->
<vgroup>
<textarea id="output" name="Output" value="" enclosingStyle="padding-top: 10px;" cols="80" rows="20" />
</vgroup>
</tab>
</tabGroup>
</pane>
]]></Data>
</XData>

<Method name="DoStartTask">
<Description>
Main method to package</Description>
<ReturnType>%Boolean</ReturnType>
<ZenMethod>1</ZenMethod>
<Implementation><![CDATA[
	set repo=%page.%GetComponentById("repo").value
	if repo="" {
		&js<window.alert('You must enter a GIT repository URL');>
		quit 0
	}
	
	set name=%page.%GetComponentById("name").value
	if name="" {
		&js<window.alert('You must enter a system name');>
		quit 0
	}
	
	if ##class(CFDSource.System).Exists(name) {
		&js<window.alert('The repository already exists. Cannot create new project.');>
		quit 0
	}
	
	do ..%RunBackgroundMethod("ImportProject", repo, name)
	quit 1
]]></Implementation>
</Method>

<Method name="ImportProject">
<Description>
Main method to package</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>repo,name</FormalSpec>
<Implementation><![CDATA[
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="Import Project"
		
	set sc=$$$OK
	try {
		set system=##class(CFDSource.System).%New(name)
		set sc=system.Clone(repo, .tTrace)
	}
	catch ex {
		do tTrace.AddCheckpoint("Caught!: "_$system.Status.GetErrorText(ex.AsStatus()))
		set sc=ex.AsStatus()
	}
	
	if $$$ISERR(sc) { set ^CacheTempUser.CFDSource("Trace", $J, "Status")=$system.Status.GetErrorText(sc) }
	else { set ^CacheTempUser.CFDSource("Trace", $J, "Status")="Completed Successfully" }
	
	Do ..%EndBackgroundMethod()
]]></Implementation>
</Method>
</Class>
</Export>
