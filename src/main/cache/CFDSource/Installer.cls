<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Installer">
<Description>
Class to install applications into the Environment

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<TimeCreated>63024,65566.577019</TimeCreated>

<Method name="GetDBDir">
<Description>
Returns the root location for all databases (includes trailing slash / or \)</Description>
<ClassMethod>1</ClassMethod>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit $system.Util.ManagerDirectory()
]]></Implementation>
</Method>

<Method name="Prepare">
<Description>
This method prepares a new namespace including data and code databases
If the namespace already exists, no changes will be made
Both databases will be created if different.
If pCodeName is blank, code and data will be in same database
If pDataName is blank, DB will be named after namespace
The DB will be created with a %DB_{DBNAME} resource</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pNamespace:%String,pDataName:%String,pCodeName:%String,pEnsemble:%Boolean=1</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set ret=$$$OK
	set ns=$NAMESPACE
	try {
		zn "%sys"
		
		set pNamespace=$ZCVT(pNamespace,"U")
		set:$G(pDataName)="" pDataName=pNamespace
		set:$G(pCodeName)="" pCodeName=pDataName
		
		quit:##class(Config.Namespaces).Exists(pNamespace)
	
		set tBaseDir=..GetDBDir()
		set tInstaller=##class(%Installer.Installer).%New()
	
		// a. Create Data DB if it does not exist
		if '##class(Config.Databases).Exists(pDataName) {
			do tInstaller.CreateDatabase(pDataName, tBaseDir_pDataName, "yes", "%DB_"_pDataName)
		}
	
		// b. Create Code DB if different from Data and does not exist
		if pCodeName'=pDataName&&'##class(Config.Databases).Exists(pCodeName) {
			do tInstaller.CreateDatabase(pCodeName, tBaseDir_pCodeName, "yes", "%DB_"_pCodeName)
		}
	
		// c. Create the Namespace & CSP App
		if '##class(Config.Namespaces).Exists(pNamespace) {
			do tInstaller.CreateNamespace(pNamespace, pCodeName, pDataName, "yes")
			do tInstaller.ActivateConfiguration(pNamespace)
			do:pEnsemble tInstaller.EnableEnsemble(pNamespace,,,"","","36")
			do tInstaller.ActivateConfiguration(pNamespace)
		
			// Create the Web App for Namespace
			set pUrl="/csp/"_$ZCVT(pNamespace, "L")
			set pDescription="Web App for "_pNamespace
			set pDirectory=$system.Util.InstallDirectory()_"CSP/"_pNamespace
			set pResource=""
			set pRecurse="0"	// ??? 
			set pLoginClass=""
			set pGrant=""
			set pCookiePath=""
			set pAuthMethods="32"
			set pLockCSPName=1
			set pEventClass=""
			set pDefaultTimeout=""
			set pDefaultSuperclass=""
			set pUseSessionCookie=""
			set pServeFiles=""
			set pServeFilesTimeout=""
			set pCustomErrorPage=""
			set pPackageName=""
			set pChangePasswordPage=""
			set pGroupById=""
			set pCspZenEnabled=1
			set pInboundWebServicesEnabled=1
			set pTwoFactorEnabled=0
			set pIsNameSpaceDefault=1
			set pPermittedClasses=""
			do tInstaller.CSPApplication(pUrl,pNamespace,pDescription,pDirectory,pResource,pRecurse,pLoginClass,pGrant,pCookiePath,pAuthMethods,pLockCSPName,pEventClass,pDefaultTimeout,pDefaultSuperclass,pUseSessionCookie,pServeFiles,pServeFilesTimeout,pCustomErrorPage,pPackageName,pChangePasswordPage,pGroupById,pCspZenEnabled,pInboundWebServicesEnabled,pTwoFactorEnabled,pIsNameSpaceDefault,pPermittedClasses)
		}
	}
	catch ex {
		set ret=ex.AsStatus()
	}
	
	zn ns
	
	quit ret
]]></Implementation>
</Method>
</Class>
</Export>
