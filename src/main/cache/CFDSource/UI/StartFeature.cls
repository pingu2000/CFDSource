<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.StartFeature">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,5628.405105</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default>Start Feature</Default>
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
<html>This will start a new development feature branch. You must be on main develop branch for this to work. The project is fetched from the remote location during the start if the project is sync'd with a remote.</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld" size="80" readOnly="true"/>
<text id="feature" name="Feature" value="" label="Feature:" enclosingClass="fld" />
<html enclosingClass="notes">Keep your feature name short and in line with your development practice. It is common to name features using a key or reference from an external project tracking system</html>
<checkbox id="fetch" name="Fetch" value="1" label="Pull" enclosingClass="fld" />
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
Zen method to start feature</Description>
<ReturnType>%Boolean</ReturnType>
<ZenMethod>1</ZenMethod>
<Implementation><![CDATA[
	set name=%page.%GetComponentById("name").value
	set pull=%page.%GetComponentById("fetch").value
	set feature=$ZSTRIP(%page.%GetComponentById("feature").value, "<>WCP")
	if feature="" {
		&js<window.alert('You have not entered a feature name, the feature must have a name or key');>
		quit 0
	}
	
	if '##class(CFDSource.System).Exists(name) {
		&js<window.alert('There is a problem as, #(name)# is not a registered CFD System. Cannot end feature.');>	
		quit 0
	}
	
	do ..%RunBackgroundMethod("StartFeature", name, feature, pull)
	quit 1
]]></Implementation>
</Method>

<Method name="StartFeature">
<Description>
Actually starts the feature</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>project:%String,name:%String,pull:%Boolean</FormalSpec>
<Implementation><![CDATA[
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="Start Feature"
	
	set sc=$$$OK
	try {
		set system=##class(CFDSource.System).%New(project)	
		set sc=system.StartFeature(name, pull, .tTrace)
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
