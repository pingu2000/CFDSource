<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.SourceControl">
<Description>
This abstract class represents an object that interacts with a source
control system.

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Abstract>1</Abstract>
<IncludeCode>%sySite,%occErrors,%occStatus</IncludeCode>
<Super>%RegisteredObject</Super>
<TimeCreated>62579,80610.696937</TimeCreated>

<Method name="GetStatus">
<Description>
This method gets the status of the project, return 1 if fully
committed, otherwise 0. The current branch is also returned.</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,*pBranch:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Boolean</ReturnType>
</Method>

<Method name="StartFeature">
<Description>
This method starts a new development feature. Optionally this
method will also pull from a remote repository</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pFeature:%String,pPull:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="SwitchFeature">
<Description>
This method switches the working directory to a different feature. 
This will not work if the local repo has uncommited changes</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pFeature:%String,pPull:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="EndFeature">
<Description>
This method ends the current development feature (including a commit if required)</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pPush:%Boolean=1,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="Pull">
<Description>
This method will pull/refresh the working directory from a remote source</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="Commit">
<Description>
This method is called to commit the working directory.
This method should only actually commit if there are changes!</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pMessage:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="CreateProject">
<Description>
Call to create a new project. This will attempt to create a new repository for the project 
and create a local workspace pointing to the repository.</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pRepoUrl:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>

<Method name="ImportProject">
<Description>
Call to create a local workspace on a given repository and import it.</Description>
<Abstract>1</Abstract>
<FormalSpec>pSys:CFDSource.System,pRepoUrl:%String,pTrace:CFDSource.Util.Trace</FormalSpec>
<ReturnType>%Status</ReturnType>
</Method>
</Class>
</Export>
