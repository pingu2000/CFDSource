<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="Test.TestProjectItems">
<Description>
Test the Project Item code

DO NOT use this as example of how to use CFDSource, only use CFDSource.System!

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>TestBase</Super>
<TimeCreated>63033,51508.089284</TimeCreated>

<Method name="TestProjectItems">
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	
	set ret=##class(CFDSource.Util.ProjectItemsUtil).GetProjectItems(..SampleSys(), .items, .testItems, pT)
	if $$$ISERR(ret) { w !,"Failed to get project items: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	w !,"Items ...",!
	zw items
	w !,!,"Test Items ...",!
	zw testItems
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>

<Method name="TestReconClass">
<Description>
Tests if we remove a class from the work dir then it is removed if part of project</Description>
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	
	do $system.OBJ.Load("c:\tmp\Sample.xml", "ck")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// Delete class on file system
	set dir="C:\tmp\Sample\src\main\cache\Sample\Util\"
	set file="UtilityClassA.cls"
	do ##class(%File).CopyFile(dir_file, "c:\tmp\")
	do ##class(%File).Delete(dir_file)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	if $D(^oddDEF("Sample.Util.UtilityClassA"))'=0 { w !,"Class still present"  quit 0 }
	
	do ##class(%File).CopyFile("c:\tmp\"_file, dir)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	if $D(^oddDEF("Sample.Util.UtilityClassA"))=0 { w !,"Class not present"  quit 0 }
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>

<Method name="TestReconRoutine">
<Description>
Tests if we remove a routine from the work dir then it is removed if part of project</Description>
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	
	do $system.OBJ.Load("c:\tmp\Sample.xml", "ck")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// Delete routine on file system
	set dir="C:\tmp\Sample\src\test\cache\"
	set file="TestInc.inc"
	do ##class(%File).CopyFile(dir_file, "c:\tmp\")
	do ##class(%File).Delete(dir_file)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	if $D(^rINC("TestInc"))'=0 { w !,"Routine still present"  quit 0 }
	if '..EnsureProjectItem(1, "TestInc.INC", "MAC") { w !,"Project Item still exists"  quit 0 }
	
	do ##class(%File).CopyFile("c:\tmp\"_file, dir)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	if $D(^rINC("TestInc"))=0 { w !,"Routine not present"  quit 0 }
	if '..EnsureProjectItem(0, "TestInc.INC", "MAC") { w !,"Project Item does not exist"  quit 0 }
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>

<Method name="TestReconCSP">
<Description>
Tests if we remove a csp from the work dir then it is removed if part of project</Description>
<ClassMethod>1</ClassMethod>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set pT=..Trace()
	
	do $system.OBJ.Load("c:\tmp\Sample.xml", "ck")
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// Delete CSP on file system
	set dir="C:\tmp\Sample\src\main\resources\"
	set file="menu.csp"
	do ##class(%File).CopyFile(dir_file, "c:\tmp\")
	do ##class(%File).Delete(dir_file)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// TODO: Ensure CSP no longer exists in namespace
	if '..EnsureProjectItem(1, $E($system.CSP.GetDefaultApp($NAMESPACE), 2, *)_"/"_file, "CSP") { w !,"Project Item still exists"  quit 0 }
	
	do ##class(%File).CopyFile("c:\tmp\"_file, dir)
	
	set ret=##class(CFDSource.Util.ImportExport).ImportProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to import: "_$system.Status.GetErrorText(ret)  quit 0 }
	set ret=##class(CFDSource.Util.ProjectItemsUtil).ReconcileProject(..SampleSys(), .sourceItems, pT)
	if $$$ISERR(ret) { w !,"Failed to reconcile: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	if '..EnsureProjectItem(0, $E($system.CSP.GetDefaultApp($NAMESPACE), 2, *)_"/"_file, "CSP") { w !,"Project Item does not exist"  quit 0 }
	
	do pT.ToDevice()
	quit 1
]]></Implementation>
</Method>
</Class>
</Export>
