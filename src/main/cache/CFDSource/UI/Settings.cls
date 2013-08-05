<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.Settings">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseDialog</Super>
<TimeCreated>62659,73438.867481</TimeCreated>

<Parameter name="TEMPLATETITLE">
<Description>
Displayed name of this page.</Description>
<Default>Project Settings</Default>
</Parameter>

<Property name="RepoUser">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="RepoEmail">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Debug">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Trace">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ForwardEdit">
<Type>%Boolean</Type>
<Calculated>1</Calculated>
</Property>

<Method name="DebugGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit $G(^CFDSource("Debug"), 0)
]]></Implementation>
</Method>

<Method name="TraceGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit $G(^CFDSource("Trace"), 0)
]]></Implementation>
</Method>

<Method name="ForwardEditGet">
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[	quit $G(^CFDSource("ForwardEdit"), 0)
]]></Implementation>
</Method>

<Method name="RepoUserGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit $G(^CFDSource("User"))
]]></Implementation>
</Method>

<Method name="RepoEmailGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	quit:$G(^CFDSource("User"))'="" $G(^CFDSource("Email", ^CFDSource("User")))
	quit ""
]]></Implementation>
</Method>

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
<text id="repoUser" name="repoUser" label="Repo User: " value="#(%page.RepoUser)#" enclosingClass="fld" />
<text id="repoEmail" name="repoEmail" label="Repo Email: " size="60" value="#(%page.RepoEmail)#" enclosingClass="fld" />
<combobox id="debug" name="debug" label="Debug" value="#(%page.Debug)#" valueList="0,1,2,3" displayList="Off,Minimal,Full,Dev" enclosingClass="fld" />
<combobox id="trace" name="trace" label="Trace" value="#(%page.Trace)#" valueList="0,1,2,3" displayList="Off,Steps,Checkpoints,Full" enclosingClass="fld" />
<checkbox id="edit" name="edit" label="Forward Edit" value="#%page.ForwardEdit)#" enclosingClass="fld" />
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
<ClassMethod>1</ClassMethod>
<FormalSpec>pSubmit:%ZEN.Submit</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set user=pSubmit.%Data("repoUser")
	set email=pSubmit.%Data("repoEmail")
	set debug=pSubmit.%Data("debug")
	set edit=pSubmit.%Data("edit")
	set trace=pSubmit.%Data("trace")
	
	if debug'="" { set ^CFDSource("Debug")=debug }
	else { kill ^CFDSource("Debug") }
	if trace'="" { set ^CFDSource("Trace")=trace }
	else { kill ^CFDSource("Trace") }
	set ^CFDSource("ForwardEdit")=$S(edit="1":1, 1:0)
	set ^CFDSource("User")=user
	set:user'="" ^CFDSource("Email", user)=email
	
	quit ##super(pSubmit)
]]></Implementation>
</Method>
</Class>
</Export>
