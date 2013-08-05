<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="Test.TestBase">
<Description>
Base class for the tests

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<TimeCreated>63033,51563.379941</TimeCreated>

<Method name="Scratch">
<ClassMethod>1</ClassMethod>
<Implementation><![CDATA[
	set ret=1
	/*
	set:ret=1 ret=##class(TestProjectItems).TestProjectItems()
	set:ret=1 ret=##class(TestImportExport).TestExport()
	set:ret=1 ret=##class(TestWorkDir).TestWorkDir()
	set:ret=1 ret=##class(TestImportExport).TestImport()
	set:ret=1 ret=##class(TestProjectItems).TestReconClass()
	set:ret=1 ret=##class(TestProjectItems).TestReconRoutine()
	set:ret=1 ret=##class(TestProjectItems).TestReconCSP()
	*/
	
	set:ret=1 ret=##class(TestGIT).TestCreateRepo(..Trace(.pT))  do pT.ToDevice()
	set:ret=1 ret=##class(TestGIT).TestPushRemote(..Trace(.pT))  do pT.ToDevice()
	set:ret=1 ret=##class(TestGIT).TestFeature(..Trace(.pT))  do pT.ToDevice()
]]></Implementation>
</Method>

<Method name="Trace">
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[&pT:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>CFDSource.Util.Trace</ReturnType>
<Implementation><![CDATA[
	set pT=##class(CFDSource.Util.Trace).%New(3)
	quit pT
]]></Implementation>
</Method>

<Method name="SampleSys">
<ClassMethod>1</ClassMethod>
<ReturnType>CFDSource.System</ReturnType>
<Implementation><![CDATA[
	set ^CFDSource("Projects", "Sample", "WorkDir")="c:\tmp\Sample\"
	
	set ret=##class(CFDSource.System).%New("Sample")
	set ret.GroupId="org.sample"
	set ret.Version="0.1"
	set ret.Brief="Sample project for testing purposes"
	set ret.TestPrefix="Test.,Test"
	
	quit ret
]]></Implementation>
</Method>

<Method name="EnsureProjectItem">
<ClassMethod>1</ClassMethod>
<FormalSpec>pMissing:%Boolean,pItem:%String,pType:%String</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set found=0
	set prj=##class(%Studio.Project).%OpenId("Sample")
	set count=prj.Items.Count()
	for i=1:1:count {
		set item=prj.Items.GetAt(i)
		#dim item As %Studio.ProjectItem
		set:(item.Name=pItem)&&(item.Type=pType) found=1
		quit:found
	}
	
	quit:pMissing 'found
	quit found
]]></Implementation>
</Method>
</Class>
</Export>
