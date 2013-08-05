<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Tasks.ExportTask">
<Description>
This class is a task that can be setup to automatically export the source code
for a project. This can be useful to, for instance, ensure we checkin nightly
any development work. The checkin is only done locally and then only to
the feature branch so does not effect everyone/everything. Useful if other
developers have branched off our local repo.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>%SYS.Task.Definition</Super>
<TimeCreated>62555,72858.025913</TimeCreated>

<Property name="Systems">
<Description>
The name of the systems to export in this namespace (comma delimitted)</Description>
<Type>%String</Type>
</Property>

<Method name="OnTask">
<Description>
This export any software that is out of date</Description>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sc=$$$OK
	for i=1:1:$L(..Systems, ",") { set sc=..SourceExport($P(..Systems, ",", i))  quit:$$$ISERR(sc) }
	quit sc
]]></Implementation>
</Method>

<Method name="SourceExport">
<Description>
Actual method to export a particular system.
Can be used outside the task if useful</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>system:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sys=##class(CFDSource.System).%OpenId(system)
	quit:'$IsObject(sys) $$$ERROR("Cannot find system to update source for: "_system)
	
	quit sys.ExportSource(,"Regular checkin: "_$ZDT($H, 3, 3))
]]></Implementation>
</Method>
</Class>
</Export>
