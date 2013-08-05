<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.NewProject">
<Description>
Displays the settings for the current system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>CFDSource.UI.BaseWizard</Super>
<TimeCreated>62660,75394.551545</TimeCreated>

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
<tabGroup id="contents" width="100%">
<tab id="frmpane" width="100%">
<vgroup enclosingClass="dialog" width="100%">
<!-- Description -->
<vgroup width="100%" enclosingClass="description">
<html>This will create a new project in a new namespace which will be initialised for GIT and Confidence</html>
</vgroup>

<!-- Main Form -->
<vgroup enclosingClass="frm">
<text id="name" name="Name" value="#(%page.Project)#" label="Name:" enclosingClass="fld" size="80" readOnly="true"/>
<text id="groupId" name="GroupId" value="" label="Group ID:" enclosingClass="fld" size="60" />
<text id="version" name="Version" value="0.1" label="Version:" enclosingClass="fld" />
<textarea id="brief" name="Brief" value="" label="Brief" enclosingClass="fld" cols="60" rows="2"  />
<text id="testPrefix" name="TestPrefix" value="" label="Test Prefix:" enclosingClass="fld" size="80" />

<combobox id="repoType" name="RepoType" displayList="None,GITHub,GIT File" valueList="none,github,gitfile" onchange="zenPage.onChangeRepo()" />
<vgroup id="gitRepo" hidden="true">
<text id="user" name="User" value="" label="User:" enclosingClass="fld" />
<text id="username" name="UserName" value="" label="GIT Login ID:" enclosingClass="fld" size="40" />
<password id="password" name="Password" value="" label="GIT Password:" enclosingClass="fld" size="40" />
<html enclosingClass="notes">Your GIT Username and Password are not stored at all (they do go via HTTP to Caché server though)</html>
</vgroup>
<vgroup id="fileRepo" hidden="true">
<text id="path" name="Path" value="" label="Path:" enclosingClass="fld" size="80" />
</vgroup>

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

<Method name="onChangeRepo">
<Description>
Shows/Hides the relevant fields</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var val=this.getComponentById("repoType").getValue();
	if ( val == "github" ) {
		this.getComponentById("gitRepo").setHidden(false);
		this.getComponentById("fileRepo").setHidden(true);
	}
	else if ( val == "gitfile" ) {
		this.getComponentById("gitRepo").setHidden(true);
		this.getComponentById("fileRepo").setHidden(false);
	}
	else {
		this.getComponentById("gitRepo").setHidden(true);
		this.getComponentById("fileRepo").setHidden(true);
	}
	
	return true;
]]></Implementation>
</Method>

<Method name="DoStartTask">
<Description>
Zen method to package</Description>
<ReturnType>%Boolean</ReturnType>
<ZenMethod>1</ZenMethod>
<Implementation><![CDATA[
	set name=%page.%GetComponentById("name").value
	set groupId=$ZSTRIP(%page.%GetComponentById("groupId").value, "<>WCP")
	set version=$ZSTRIP($ZSTRIP(%page.%GetComponentById("version").value, "<>WCP"), "*A")
	set desc=$ZSTRIP(%page.%GetComponentById("brief").value, "<>WCP")
	set testPrefix=$ZSTRIP(%page.%GetComponentById("testPrefix").value, "<>WCP")
	set repotype=%page.%GetComponentById("repoType").value
	set user=%page.%GetComponentById("user").value
	set username=%page.%GetComponentById("username").value
	set password=%page.%GetComponentById("password").value
	set path=%page.%GetComponentById("path").value
	
	if ##class(CFDSource.System).Exists(name) {
		&js<window.alert('The repository already exists. Cannot create new project.');>
		quit 0
	}
	
	if groupId="" {
		&js<window.alert('A project must have a group Id');>
		quit 0
	}
	
	if repotype="github" {
		set:user="" msg="You must enter your GIT username for a GITHub Repository"
		set:username="" msg="You must enter your GIT user ID (email) for a GITHub Repository"
		set:password="" msg="You must enter your GIT password for a GITHub Repository"
		
		if $G(msg)'="" {
			&js<window.alert('#(msg)#');>
			quit 0
		}
	}
	elseif repotype="gitfile" {
		if path="" {
			&js<window.alert('A path is required for a GIT File repository');>
			quit 0
		}
		elseif '##class(%File).Exists(path)&&'##class(%File).CreateDirectoryChain(path) {
			&js<window.alert('A valid path is required for a GIT File repository');>
			quit 0
		}
	}
	
	do ..%RunBackgroundMethod("NewProject", name, groupId, version, desc, testPrefix, repotype, user, username, password, path)
	quit 1
]]></Implementation>
</Method>

<Method name="NewProject">
<Description>
Main method to package</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>name,groupId,version,desc,testPrefix,repo,user,username,password,path</FormalSpec>
<Implementation><![CDATA[
	&js<var ta=zenPage.getComponentById('output'); ta.setValue('Creation of new project has started.\nAn alert will display when completed.\nThis does take a long time');>
	
	Do ..%SetBackgroundMethodStatus("Started",0)
	
	set tTrace=##class(CFDSource.Util.Trace).%New()
	set ^CacheTempUser.CFDSource("Trace", $J, "Task")="New Project"
		
	set sc=$$$OK
	try {
		set system=##class(CFDSource.System).%New(name)
		set system.GroupId=groupId
		set system.Version=version
		set system.Brief=desc
		set system.TestPrefix=testPrefix
		
		// Create Remote
		set sc=$$$OK
		set tRepoUrl=""
		if repo="github" {
			set sc=##class(CFDSource.GIT.SourceControl).CreateGITHubRepo(system, user, username, password, .tRepoUrl, .tTrace)
		}
		elseif repo="gitfile" {
			set sc=##class(CFDSource.GIT.SourceControl).CreateFileRepo(system, path, .tRepoUrl, .tTrace)
		}
		
		// Initialise local system (this will push into new repo if we created one)
		do:$$$ISOK(sc) system.Initialise(tRepoUrl, .tTrace)
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
