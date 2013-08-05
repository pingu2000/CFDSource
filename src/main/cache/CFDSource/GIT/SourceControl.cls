<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.GIT.SourceControl">
<Description>
Implementation of the SourceControl interface for the GIT source control system

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>CFDSource.SourceControl</Super>
<TimeCreated>62996,58647.732482</TimeCreated>

<Method name="GetStatus">
<Description>
This method gets the status of the project and the current branch</Description>
<FormalSpec>pSys:CFDSource.System,*pBranch:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	// Run Status
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .pBranch, .staged, .committed, .tItems, pTrace)
	quit $G(staged, 0)&&$G(committed, 0)
]]></Implementation>
</Method>

<Method name="StartFeature">
<Description>
This method starts a new development feature. As well as marking the start of the
new feature this method will refresh the local workspace from the repository</Description>
<FormalSpec>pSys:CFDSource.System,pFeature:%String,pPull:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	// Check Status - Must be committed at this point
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	quit:'committed $$$ERROR("There are uncommitted/staged local changes, you may have work outstanding. Rectify manually or Export system")
	
	// Switch to develop
	if tBranch'="develop" {
		do pTrace.AddCheckpoint("Switching to [develop]")
		// TODO: Need to handle this
		quit:tBranch'="develop" $$$ERROR("Not currently on [develop] branch, you may have work outstanding. Rectify manually")
	}
	
	// Pull in from remote
	if pPull=1 {
		do pTrace.AddCheckpoint("Pulling from remote repository to get latest")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "pull origin develop")
		set sc=os.Run()  quit:$$$ISERR(sc) sc
		
		do pTrace.AddCheckpoint("Checking Status")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
		set sc=os.Run()  quit:$$$ISERR(sc) sc
		do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
		quit:'committed $$$ERROR("There are merges that need to be reconciled, you may have work outstanding. Rectify manually")
	}
	
	// Create Feature Branch
	do pTrace.AddCheckpoint("Creating Feature Branch")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "checkout -b "_pFeature_" develop")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	quit:tBranch'=pFeature $$$ERROR("Unable to create/switch to branch, branch is now: "_tBranch_" (try git status on command line)")
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="SwitchFeature">
<Description>
This method switches the working directory to a different feature.
This will not work if the local repo has uncommited changes</Description>
<FormalSpec>pSys:CFDSource.System,pFeature:%String,pPull:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	// Check Status - Must be committed at this point
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	quit:'committed $$$ERROR("There are uncommitted/staged local changes, you may have work outstanding. Rectify manually or Export system")
	
	// Switch branch
	do pTrace.AddCheckpoint("Moving to feature branch: "_pFeature)
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "checkout "_pFeature)
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	quit $$$OK
]]></Implementation>
</Method>

<Method name="EndFeature">
<Description>
This method ends the current development feature (including a commit if required)</Description>
<FormalSpec>pSys:CFDSource.System,pPush:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	// Check Status - Must be committed at this point
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	quit:'committed $$$ERROR("There are uncommitted/staged local changes, you may have work outstanding. Rectify manually or Export system")
	
	// Go back to [develop]
	do pTrace.AddCheckpoint("Moving to main [develop] branch")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "checkout develop")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	// Apply all changes from feature
	do pTrace.AddCheckpoint("Applying Feature")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "merge --no-ff "_tBranch)
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	// Check Status (ensure all ok)
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	quit:'committed $$$ERROR("There are merges (or other errors) that need to be reconciled, you may have work outstanding. Suggest ExportSource with a commit comment")
	
	// Push to remote
	if pPush {
		do pTrace.AddCheckpoint("Pushing to origin")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "push origin develop")
		set sc=os.Run()  quit:$$$ISERR(sc) sc
	}
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="Pull">
<Description>
This method will pull/refresh the working directory from a remote source</Description>
<FormalSpec>pSys:CFDSource.System,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "env", "")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	
	do pTrace.AddCheckpoint("Pull from remote ...")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "pull origin "_tBranch)
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	quit $$$OK
]]></Implementation>
</Method>

<Method name="Commit">
<Description>
This method is called to commit the working directory
This method should only actually commit if there are changes!</Description>
<FormalSpec>pSys:CFDSource.System,pMessage:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	// Check status - might not need to commit
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	
	do pTrace.AddPOI("Status checked, we are on ["_tBranch_"] branch and we are "_$S(committed:"[Committed]", 1:"[Uncommitted]"))
	quit:committed $$$OK
	
	// Stage Changes
	do pTrace.AddCheckpoint("Staging Changes")
	set added=0
	set k=$O(tItems(""))
	while k'="" {
		if tItems(k)="deleted" { 
			set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "rm "_tItems(k, "path"))
			set sc=os.Run()  quit:$$$ISERR(sc)
		}
		else {
			set added=1
		}
		set k=$O(tItems(k))
	}
	quit:$$$ISERR(sc) sc
			
	do pTrace.AddCheckpoint("Staging new items")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "add .")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
				
	// Commit
	do pTrace.AddCheckpoint("Committing")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "commit -m '"_$ZSTRIP(pMessage, "*", "'")_"'")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	// Check!
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	
	do pTrace.AddPOI("Commit completed, we are on ["_tBranch_"] branch and we are "_$S(committed:"[Committed]", 1:"[Uncommitted]"))
	quit:'committed $$$ERROR("Could not commited local directory, review status")
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="CreateProject">
<Description>
Call to create a new project. This will attempt to create a new repository for the project 
and create a local workspace pointing to the repository. It is assumed to working dir
is already setup</Description>
<FormalSpec>pSys:CFDSource.System,pRepoUrl:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	do:'##class(%File).Exists(path) ##class(%File).CreateDirectoryChain(path)
	
	do pTrace.AddCheckpoint("Initialise Local Repo")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "init")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	set stdusers=$LB("UnknownUser", "_SYSTEM", "Admin", "SuperUser", "_Ensemble")
	set user=$S($D(^CFDSource("User"))=1:^CFDSource("User"), $LF(stdusers, $username)=0:$username, 1:"system")
	set email=$S($D(^CFDSource("Email", user))=1:^CFDSource("Email", user), 1:user_"@"_$namespace_".domain")
	
	do pTrace.AddCheckpoint("Setting up user name")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "config user.name """_user_"""")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Setting up user email")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "config user.email """_email_"""")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Creating std .gitignore")
	set f=##class(%File).%New(pSys.Location_".gitignore")
	set sc=f.Open("WSN")  quit:$$$ISERR(sc) pTrace.SetError(sc)
	set sc=f.WriteLine("packages/")
	set:$$$ISOK(sc) sc=f.Flush()
	do f.Close()
	quit:$$$ISERR(sc) pTrace.SetError(sc)
	
	do pTrace.AddCheckpoint("Staging all files")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "add .")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Committing initial source")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "commit -m 'Initial Import on New Project'")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Creating [develop] branch from master")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "checkout -b develop master")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	
	// Add to remote
	if pRepoUrl'=""&&committed&&(tBranch="develop") {
		do pTrace.AddCheckpoint("Adding remote")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "remote add origin "_pRepoUrl)
		set sc=os.Run()  quit:$$$ISERR(sc) sc
			
		// FUTURE: This works, but seems to take a very long time!?!
		do pTrace.AddCheckpoint("Push local to remote")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "push origin develop")
		set sc=os.Run()  quit:$$$ISERR(sc) sc
	}
	
	quit:(committed)&&(tBranch="develop") $$$OK
	quit $$$ERROR("Local Repo not created, may be there, but some issue. Use git status to review: "_path)
]]></Implementation>
</Method>

<Method name="ImportProject">
<Description>
Call to create a local workspace on a given repository and import it.</Description>
<FormalSpec>pSys:CFDSource.System,pRepoUrl:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set basePath=##class(CFDSource.System).ProjectLocation("")
	set path=pSys.Location
	do:'##class(%File).Exists(path) ##class(%File).CreateDirectoryChain(path)
	
	do pTrace.AddCheckpoint("Cloning Repository")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, basePath, "git", "clone -b develop "_pRepoUrl_" "_pSys.Name)
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	set stdusers=$LB("UnknownUser", "_SYSTEM", "Admin", "SuperUser", "_Ensemble")
	set user=$S($D(^CFDSource("User"))=1:^CFDSource("User"), $LF(stdusers, $username)=0:$username, 1:"system")
	set email=$S($D(^CFDSource("Email", user))=1:^CFDSource("Email", user), 1:user_"@"_$namespace_".domain")
	
	do pTrace.AddCheckpoint("Setting up user name")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "config user.name """_user_"""")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
		
	do pTrace.AddCheckpoint("Setting up user email")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "config user.email """_email_"""")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	
	do pTrace.AddCheckpoint("Checking Status")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "status")
	set sc=os.Run()  quit:$$$ISERR(sc) sc
	do ..ProcessGITResponse(os.Output, .tBranch, .staged, .committed, .tItems, pTrace)
	
	quit:(committed)&&(tBranch="develop") $$$OK
	quit $$$ERROR("Some issue clonding Repo, may be there, but some issue. Use git status to review: "_path)
]]></Implementation>
</Method>

<Method name="CreateGITHubRepo">
<Description><![CDATA[
This extra method creates a GITHub Repository for the project
This does not connect the local repo to the GUTHub repo as
the local repo may not have been created. The resulting repo
will be git@github.com:{pUser}/{pRepoName}.git.
<br /><b>Note 1:</b> the username is the full login ID at GIT, 
pUser is just the GIT username, for instance I am "thegaffer", 
but my login name is an email address.
<br /><b>Note 2:</b> the password is not stored at all]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,pUser:%String,pUserName:%String,pPass:%String,&pRepoUrl,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	do pTrace.AddCheckpoint("Checking GITHub SSL Config exists")
	set ret=$$$OK
	set ns=$NAMESPACE
	try {
		zn "%SYS"
		set:'##class(Security.SSLConfigs).Exists("GITHub") ret=$$$ERROR("You need an SSL config called GITHub to talk with GITHub")
		do pTrace.AddPOI("GITHub SSL Config: "_$S($$$ISOK(ret):"ok", 1:"missing"))
	}
	catch ex {
		set ret=$$$ERROR("Failed to check if SSLConfig exists: "_$system.Status.GetErrorText(ex.AsStatus()))
	}
	zn ns
	quit:$$$ISERR(ret) ret

	do pTrace.AddCheckpoint("Contacting GITHub at api.github.com")
	set req=##class(%Net.HttpRequest).%New()
	set req.Https=1
	set req.SSLConfiguration=$G(^CFDSource("GITHubSSLConfig"), "GITHub")
	set req.Username=pUserName
	set req.Password=pPass
	set req.Server="api.github.com"
	do req.EntityBody.Write("{""name"":"""_pSys.Name_"""}")
	set req.ContentType="application/json"
	set sc=req.Post("/user/repos")
	quit:$$$ISERR(sc) pTrace.SetError(sc)
	// FUTURE: Handle the response better. It's JSON so can easily process, esp 2013.2 onwards.
	
	set pRepoUrl="git@github.com:"_pUser_"/"_pSys.Name_".git"
	do pTrace.AddPOI("New central repository = "_pRepoUrl)
	quit $$$OK
]]></Implementation>
</Method>

<Method name="CreateFileRepo">
<Description>
This creates an {base} external file based repository. 
As above this does not connect to the local repo</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[pSys:CFDSource.System,pPath:%String,&pRepoUrl:%String,&pTrace:CFDSource.Util.Trace]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set:'$IsObject($G(pTrace)) pTrace=##class(CFDSource.Util.Trace).%New()
	
	// Ensure path has a trailing slash. Assume /, but use \ if present
	set sep="/"
	set:$F(pPath, "\")>0 sep="\"
	if ($E(pPath, *)'="/")&&($E(pPath, *)'="\") { set pPath=pPath_sep }
	
	// Ensure path exists
	if '##class(%File).Exists(pPath) {
		if '##class(%File).CreateDirectoryChain(pPath) {
			do pTrace.AddWarning("Cannot create file based bare GIT repository as path does not exist or is no accessible")
			quit $$$ERROR("Cannot create file repo path")
		}
	}
	
	do pTrace.AddCheckpoint("Creating Repository")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, pPath, "git", "init --bare "_pSys.Name_".git")
	set sc=os.Run()  quit:$$$ISERR(sc) pTrace.SetError(sc)
		
	set pRepoUrl="file://"_$REPLACE(pPath, "\", "/")_pSys.Name_".git"
	do pTrace.AddPOI("New central repository = "_pRepoUrl)
	quit $$$OK
]]></Implementation>
</Method>

<Method name="AddRemoteRepo">
<Description>
This method adds a remote repository to the local working repo.
All pushes/pulls will be to this repo.
By default this command will push everything to the remote repo.</Description>
<FormalSpec>pSys:CFDSource.System,pRepoUrl:%String,pPush:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set path=pSys.Location
	
	do pTrace.AddCheckpoint("Adding remote")
	set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "remote add origin "_pRepoUrl)
	set sc=os.Run()  quit:$$$ISERR(sc) sc
			
	if pPush {
		// FUTURE: This works, but seems to take a very long time!!!
		do pTrace.AddCheckpoint("Push local to remote")
		set os=##class(CFDSource.Util.OSCommand).%New(pTrace, path, "git", "push origin develop")
		set sc=os.Run()  quit:$$$ISERR(sc) sc
	}
	
	quit $$$OK
]]></Implementation>
</Method>

<Parameter name="GITOK">
<Default>Already up-to-date</Default>
</Parameter>

<Parameter name="GITBRANCH">
<Default># On branch </Default>
</Parameter>

<Parameter name="GITUNSTAGED">
<Default># Changes not staged for commit:</Default>
</Parameter>

<Parameter name="GITUNSTAGED2">
<Default># Untracked files:</Default>
</Parameter>

<Parameter name="GITCLEAN">
<Default>nothing to commit</Default>
</Parameter>

<Parameter name="GITNEW">
<Default>new file:</Default>
</Parameter>

<Parameter name="GITMOD">
<Default>modified:</Default>
</Parameter>

<Parameter name="GITDEL">
<Default>deleted:</Default>
</Parameter>

<Method name="ProcessGITResponse">
<Description>
This method processes the return from a GIT command to work out where we are</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pRes:%Stream.Object,*pCurrentBranch:%String,*pStaged:%Boolean,*pCommitted:%Boolean,*items,pTrace:CFDSource.Util.Trace</FormalSpec>
<Private>1</Private>
<Implementation><![CDATA[
	set pCurrentBranch=""
	set pStaged=1		// Wait to see changes not staged before
	set pCommitted=0	// We must see the nothing to commit, otherwise assume there are changes
	
	while 'pRes.AtEnd {
		set ln=pRes.ReadLine()
		kill modified

		if $F(ln, ..#GITOK)=($L(..#GITOK)+1) { 
			set pCommitted=1
			quit 	// No point doing the other elements
		}
		elseif $F(ln, ..#GITBRANCH)=($L(..#GITBRANCH)+1) { set pCurrentBranch=$E(ln, $L(..#GITBRANCH)+1, *) }
		elseif $F(ln, ..#GITUNSTAGED)=($L(..#GITUNSTAGED)+1) { set pStaged=0 }
		elseif $F(ln, ..#GITUNSTAGED2)=($L(..#GITUNSTAGED2)+1) { set pStaged=0 }
		elseif $F(ln, ..#GITCLEAN)=($L(..#GITCLEAN)+1) { set pCommitted=1 }
		
		elseif $F(ln, ..#GITNEW)>0 { set modified=$ZSTRIP($E(ln, $F(ln, ..#GITNEW), *), "<>CPW")="new" }
		elseif $F(ln, ..#GITMOD)>0 { set modified=$ZSTRIP($E(ln, $F(ln, ..#GITMOD), *), "<>CPW")="modified" }
		elseif $F(ln, ..#GITDEL)>0 { set modified=$ZSTRIP($E(ln, $F(ln, ..#GITDEL), *), "<>CPW")="deleted" }
		
		if $D(modified) {
			set iName=..GetInternalName($P(modified, "=", 1))
			set items(iName)=$P(modified, "=", 2)
			set items(iName, "path")=$P(modified, "=", 1)
		}
	}
	
	// If we are not staged, we are not committed
	set:pStaged=0 pCommitted=0
	do pTrace.AddPOI("Current GIT Status. Branch="_pCurrentBranch_", Status="_$S(pStaged:"Staged", pCommitted:"Committed", 1:"Pending"))
]]></Implementation>
</Method>

<Method name="GetInternalName">
<Description>
This gets the internal name given its relative path</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pathName:%String</FormalSpec>
<Private>1</Private>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	if $F(pathName, "src/main/cache/")>0 { set pathName=$E(pathName, $L("src/main/cache/")+1, *) }
	elseif $F(pathName, "src/main/resources/")>0 { set pathName=$E(pathName, $L("src/main/resources/")+1, *) }
	elseif $F(pathName, "src/test/cache/")>0 { set pathName=$E(pathName, $L("src/test/cache/")+1, *) }
	elseif $F(pathName, "src/test/resources/")>0 { set pathName=$E(pathName, $L("src/test/resources/")+1, *) }
	
	set pathName=$REPLACE(pathName, "/", ".")
	quit pathName
]]></Implementation>
</Method>
</Class>
</Export>
