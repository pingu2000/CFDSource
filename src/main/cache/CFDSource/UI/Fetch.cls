<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.Fetch">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,72070.267996</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default><![CDATA[Fetch & Update]]></Default>
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
<html>This will fetch and import the source from a local or remote repository. You can also use this to switch branches. Note, if you do switch and have uncommited local changes they will be lost!</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld" size="80" readOnly="true"/>
<text id="currentBranch" name="CurrentBranch" value="#(%page.Feature)#" label="Feature:" enclosingClass="fld roFld" size="80" readOnly="true" />
<text id="newBranch" name="NewBranch" value="" label="New Branch:" enclosingClass="fld" size="80" />
<html enclosingClass="notes">This is optional, but if set the local repositories' working area will be set to this branch before the import</html>
<checkbox id="pull" name="Pull" value="0" label="Pull Remote?" enclosingClass="fld" />
<html enclosingClass="notes">This will refresh (pull) from the remote repo the local repository was cloned from</html>
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
Zen method to end a feature</Description>
<ReturnType>%Boolean</ReturnType>
<ZenMethod>1</ZenMethod>
<Implementation><![CDATA[
	set name=%page.%GetComponentById("name").value
	set pull=%page.%GetComponentById("pull").value
	set branch=%page.%GetComponentById("newBranch").value
	
	if '##class(CFDSource.System).Exists(name) {
		&js<window.alert('There is a problem as, #(name)# is not a registered CFD System. Cannot end feature.');>	
		quit 0
	}
	
	do ..%RunBackgroundMethod("FetchSource", name, pull, branch)
	quit 1
]]></Implementation>
</Method>

<Method name="FetchSource">
<Description>
Main method to end a feature</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>project:%String,pull:%Boolean,branch:%String</FormalSpec>
<Implementation><![CDATA[
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="Fetch"
	
	set sc=$$$OK
	try {
		set system=##class(CFDSource.System).%New(project)
		
		if branch'="" {
			set sc=system.SwitchFeature(branch, pull, .tTrace)
		}
		else {
			set sc=system.Import(pull, .tTrace)
		}
	}
	catch ex {
		set sc=ex.AsStatus()
	}
	
	if $$$ISERR(sc) { set ^CacheTempUser.CFDSource("Trace", $J, "Status")=$system.Status.GetErrorText(sc) }
	else { set ^CacheTempUser.CFDSource("Trace", $J, "Status")="Completed Successfully" }
	
	Do ..%EndBackgroundMethod()
]]></Implementation>
</Method>
</Class>
</Export>
