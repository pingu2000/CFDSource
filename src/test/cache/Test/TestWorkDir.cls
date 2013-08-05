<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="Test.TestWorkDir">
<Description>
Tests the working directory code

DO NOT use this as example of how to use CFDSource, only use CFDSource.System!

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>TestBase</Super>
<TimeCreated>63033,51529.069639</TimeCreated>

<Method name="TestWorkDir">
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set ret=##class(CFDSource.Util.WorkDirUtil).GetWorkItems(..SampleSys(), .items, .testItems)
	if $$$ISERR(ret) { w !,"Failed to get work items: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	w !,"Items ...",!
	zw items
	w !,!,"Test Items ...",!
	zw testItems
	
	quit 1
]]></Implementation>
</Method>
</Class>
</Export>
