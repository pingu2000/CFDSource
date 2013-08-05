<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.EndFeature">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,37022.310285</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default>End Feature Development</Default>
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
<html>This will end the current feature, merging with the latest development branch and, if connected to a remote, will push the changes</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld" size="80" readOnly="true"/>
<text id="branch" name="Branch" value="#(%page.Feature)#" label="Feature:" enclosingClass="fld" size="80" readOnly="true" />
<text id="msg" name="Msg" value="" label="Commit Message:" enclosingClass="fld" size="80" />
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
	
	set msg=$ZSTRIP(%page.%GetComponentById("msg").value, "<>WCP")
	if msg="" {
		&js<window.alert('A commit message is required to end the feature.');>
		quit 0
	}
	
	if '##class(CFDSource.System).Exists(name) {
		&js<window.alert('There is a problem as, #(name)# is not a registered CFD System. Cannot end feature.');>
		quit 0
	}
	
	do ..%RunBackgroundMethod("EndFeature", name, msg)
	quit 1
]]></Implementation>
</Method>

<Method name="EndFeature">
<Description>
Main method to end a feature</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>project:%String,message:%String</FormalSpec>
<Implementation><![CDATA[
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="End Feature"
	
	try {
		set system=##class(CFDSource.System).%New(project)
		set sc=system.EndFeature(message, 1, .tTrace)
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
