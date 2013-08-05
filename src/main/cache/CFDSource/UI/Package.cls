<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.Package">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,73252.423454</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default>Package</Default>
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
<html>This will package your project and output it with the installer ready for installation on a separate (non-development) system</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld" size="80" readOnly="true"/>
<text id="branch" name="Branch" value="#(%page.Feature)#" label="Feature:" enclosingClass="fld roFld" size="80" readOnly="true" />
<text id="version" name="Version" value="#(%page.Version)#" label="Version:" enclosingClass="fld roFld" size="80" readOnly="true" />
<html enclosingClass="notes">You can not change the version currently and the current feature (if any) is for display purposes</html>
<checkbox id="final" name="Final" value="0" label="Final" enclosingClass="fld" />
<html enclosingClass="notes">If final no date time will be stamped on package files</html>
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
Zen method to package</Description>
<FormalSpec>pFinal:%Boolean</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<ZenMethod>1</ZenMethod>
<Implementation><![CDATA[
	set final=%page.%GetComponentById("final").value
	
	set name=%page.%GetComponentById("name").value
	if '##class(CFDSource.System).Exists(name) {
		&js<window.alert('There is a problem as, #(name)# is not a registered CFD System. Cannot package.');>	
		quit 0
	}
	
	do ..%RunBackgroundMethod("PackageSource", name, final)
	quit 1
]]></Implementation>
</Method>

<Method name="PackageSource">
<Description>
Main method to package</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pProject:%String,pFinal:%Boolean</FormalSpec>
<Implementation><![CDATA[
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="Package"
	
	set sc=$$$OK
	try {
		set system=##class(CFDSource.System).%New(pProject)
		set sc=system.Package(pFinal, .tTrace)
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
