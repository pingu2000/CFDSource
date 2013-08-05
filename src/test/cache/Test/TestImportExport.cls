<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="Test.TestImportExport">
<Description>
Tests the import and export code

DO NOT use this as example of how to use CFDSource, only use CFDSource.System!

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>TestBase</Super>
<TimeCreated>63033,51482.120793</TimeCreated>

<Method name="TestExport">
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// TODO: test files exist
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>

<Method name="TestImport">
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .importItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	w !,"Imported Items ...",!
	zw importItems
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>
</Class>
</Export>
