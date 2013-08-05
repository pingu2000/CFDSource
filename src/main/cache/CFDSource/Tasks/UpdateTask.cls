<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Tasks.UpdateTask">
<Description>
This class is a task that can be setup to automatically sync a project to
the latest on a regular basis. Note: It does not update the current branch so
is relatively safe even if working on things.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>%SYS.Task.Definition</Super>
<TimeCreated>62555,72858.025913</TimeCreated>

<Property name="Systems">
<Description>
The name of the systems to update in this namespace (comma delimitted)</Description>
<Type>%String</Type>
</Property>

<Method name="OnTask">
<Description>
This installs/updates any software that is out of date</Description>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sc=$$$OK
	for i=1:1:$L(..Systems, ",") { set sc=..SourceUpdate($P(..Systems, ",", i))  quit:$$$ISERR(sc) }
	quit sc
]]></Implementation>
</Method>

<Method name="SourceUpdate">
<Description>
Actual method to update a particular system.
Can be used outside the task if useful</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>system:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sys=##class(CFDSource.System).%OpenId(system)
	quit:'$IsObject(sys) $$$ERROR("Cannot find system to update source for: "_system)
	
	// Does a fetch from origin and then imports current branch (develop)
	quit sys.ImportSource(1)
]]></Implementation>
</Method>
</Class>
</Export>
