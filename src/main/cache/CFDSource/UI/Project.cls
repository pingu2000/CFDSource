<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.Project">
<Description>
Holds the project settings

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseDialog</Super>
<TimeCreated>62659,73438.867481</TimeCreated>

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
<vgroup enclosingClass="dialog">
<!-- Description -->
<!-- <vgroup width="100%" enclosingClass="description">
<html></html>
</vgroup> -->

<!-- Main Form -->
<vgroup enclosingClass="frm">
<hidden id="system" name="System" value="#(%page.Project)#" />
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld roFld" readOnly="true" />
<text id="groupId" name="GroupId" value="#(%page.GroupId)#" label="Group ID:" enclosingClass="fld roFld" readOnly="false" />
<text id="version" name="Version" value="#(%page.Version)#" label="Version:" enclosingClass="fld" readOnly="false" />
<textarea id="brief" name="Brief" value="#(%page.Brief)#" label="Description:" enclosingClass="fld" controlClass="tps" cols="60" rows="2" readOnly="false" />
<text id="prefix" name="Prefix" value="#(%page.TestPrefix)#" label="Test Prefix:" enclosingClass="fld" readOnly="false" />
<text id="installer" name="Installer" value="#(%page.Installer)#" label="Installer:" enclosingClass="fld" readOnly="false" />
<text id="branch" name="Branch" value="#(%page.Feature)#" label="Feature:" enclosingClass="fld roFld" size="80" readOnly="true" />

<pane paneName="CodeAndDataPane" id="codeAndDataPane" />
</vgroup>
</vgroup>
</pane>
]]></Data>
</XData>

<Method name="onfinishHandler">
<Description>
This is called when the template is finished;</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[	return true;
]]></Implementation>
</Method>

<Method name="%OnSubmit">
<Description>
Called automatically when finish is selected</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pSubmit:%ZEN.Submit</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	quit:pSubmit.%Action'="finish" ##super(pSubmit)
	
	set sysName=pSubmit.%Data("System")
	set version=$ZSTRIP($ZSTRIP(pSubmit.%Data("Version"), "<>WCP"), "*A")
	set desc=$ZSTRIP(pSubmit.%Data("Brief"), "<>WCP")
	set groupId=$ZSTRIP(pSubmit.%Data("GroupId"), "<>WCP")
	set prefix=$ZSTRIP(pSubmit.%Data("Prefix"), "<>WCP")
	set installer=$ZSTRIP(pSubmit.%Data("Installer"), "<>WCP")
	
	set data=pSubmit.%Data("Data")
	set testdata=pSubmit.%Data("TestData")
	
	// Update the system
	set sys=##class(CFDSource.System).%New(sysName)
	quit:sys.GetCurrentFeature()="" $$$ERROR("Cannot update project outside of active feature")
	
	set modified=0
	set:sys.GroupId'=groupId sys.GroupId=groupId,modified=1
	set:sys.Version'=version sys.Version=version,modified=1
	set:sys.Brief'=desc sys.Brief=desc,modified=1
	set:sys.TestPrefix'=prefix sys.TestPrefix=prefix,modified=1
	set:sys.Installer'=installer sys.Installer=installer,modified=1
	
	if data'=pSubmit.%Data("DataO") {
		set modified=1
		do sys.Data.Clear()
		for i=1:1:$L(data, ",") { 
			set entry=$P(code, ",", i)
			do sys.Data.SetAt($P(entry, "=", 1), $P(entry, "=", 2))
		}
	}
	
	if testdata'=pSubmit.%Data("TestDataO") {
		set modified=1
		do sys.TestData.Clear()
		for i=1:1:$L(testdata, ",") { 
			set entry=$P(testcode, ",", i)
			do sys.TestData.SetAt($P(entry, "=", 1), $P(entry, "=", 2))
		}
	}
	
	do:modified sys.Save(1)
		
	quit ##super(pSubmit)
]]></Implementation>
</Method>
</Class>
</Export>
