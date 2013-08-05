<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="Test.TestGIT">
<Description>
Tests the GIT integration

DO NOT use this as example of how to use CFDSource, only use CFDSource.System!

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>Test.TestBase</Super>
<TimeCreated>63034,59457.816497</TimeCreated>

<Method name="TestCreateRepo">
<Description>
Creates a local repo</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pT:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	do ##class(%File).RemoveDirectoryTree("c:\tmp\Sample")
	
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	set git=##class(CFDSource.GIT.SourceControl).%New()
	set ret=git.CreateProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to create: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	quit 1
]]></Implementation>
</Method>

<Method name="TestPushRemote">
<Description>
Creates a file base remote repo and then pushes out to it
Local project must already exist!</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pT:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	// Assumes project already exists
	do ##class(%File).RemoveDirectoryTree("c:\tmp\Repo")
	
	// Create file repo
	set git=##class(CFDSource.GIT.SourceControl).%New()
	set ret=git.CreateFileRepo(..SampleSys(), "Remote.git", "c:\tmp\Repo\", .url, pT)
	if $$$ISERR(ret) { w !,"Failed to create file repo: "_$system.Status.GetErrorText(ret)  quit 0 }
	do pT.AddCheckpoint("Remote Repo URL="_url)
	
	// Now add to remote
	set ret=git.AddRemoteRepo(..SampleSys(), .url, 1, pT)
	if $$$ISERR(ret) { w !,"Failed to push to repo: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	quit 1
]]></Implementation>
</Method>

<Method name="TestFeature">
<Description><![CDATA[
Changes something inside a feature and ends the feature
Assumes local & remote repository alread works.]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pT:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set git=##class(CFDSource.GIT.SourceControl).%New()
	
	// Start Feature
	set ret=git.StartFeature(..SampleSys(), "test", 1, pT)
	if $$$ISERR(ret) { w !,"Failed to start feature: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// Make a change
	set cls=##class(%Dictionary.ClassDefinition).%OpenId("Sample.App")
	set prop=##class(%Dictionary.PropertyDefinition).%New()
	set prop.Name="Test"_$R(1000)
	set prop.Type="%String"
	do cls.Properties.Insert(prop)
	set ret=cls.%Save()
	if $$$ISERR(ret) { w !,"Failed to app prop: "_$system.Status.GetErrorText(ret)  quit 0 }
	do $system.OBJ.Compile("Sample.App", "c")
	
	// Export
	set ret=##class(CFDSource.Util.ImportExport).ExportProject(..SampleSys(),,pT)
	if $$$ISERR(ret) { w !,"Failed to export: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// Commit
	set ret=git.Commit(..SampleSys(), "test commit", pT)
	if $$$ISERR(ret) { w !,"Failed to commit: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	// End Feature
	set ret=git.EndFeature(..SampleSys(), 1, pT)
	if $$$ISERR(ret) { w !,"Failed to end feature: "_$system.Status.GetErrorText(ret)  quit 0 }
	
	quit 1
]]></Implementation>
</Method>
</Class>
</Export>
