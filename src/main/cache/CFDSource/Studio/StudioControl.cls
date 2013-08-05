<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.Studio.StudioControl">
<Description>
Source control for CFD.
This module provides a menu from within Studio to perform the
common import/export/refresh options

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>%Studio.SourceControl.Base</Super>
<TimeCreated>62583,76081.020062</TimeCreated>

<Property name="ProjectName">
<Description>
The name of the current project</Description>
<Type>%String</Type>
</Property>

<Property name="System">
<Description>
The system we are working with (set when the project opens)</Description>
<Type>CFDSource.System</Type>
</Property>

<Property name="Feature">
<Description>
The current feature (set when opening the project or using one of the dialogs)</Description>
<Type>%String</Type>
</Property>

<Property name="Debug">
<Description>
Determines if in debug mode</Description>
<Type>%Integer</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ForwardEdit">
<Type>%Boolean</Type>
<Calculated>1</Calculated>
</Property>

<Method name="DebugGet">
<Description>
Accessor for the debug property</Description>
<CodeMode>expression</CodeMode>
<ReturnType>%Integer</ReturnType>
<Implementation><![CDATA[$G(^CFDSource("Debug"), 0)
]]></Implementation>
</Method>

<Method name="ForwardEditGet">
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	quit:$G(^CFDSource("ForwardEdit"), 0)=1 1
	quit:$G(^CFDSource("Debug"), 0)>2 1
	quit 0
]]></Implementation>
</Method>

<XData name="Menu">
<Description>
///////////////////////////////////////////////////////////////////////////
XDATA Block holds the Menu items</Description>
<Data><![CDATA[
<MenuBase>
<Menu Name="Confidence" Type="0">
<MenuItem Name="Project" />			<!-- Shows the settings in the current project -->
<MenuItem Name="Fetch" />			<!-- Fetch from local repo and import, optional pull -->
<MenuItem Name="Package" />			<!-- Export the package for Install on another machine -->
<MenuItem Name="Settings" />			<!-- Shows the settings for CFD in namespace -->
<MenuItem Separator="1" Name="----------------------------------"/> 
<MenuItem Name="Start Feature" />	<!-- Start a new development feature -->
<MenuItem Name="Export" />			<!-- Export and locally commit current state -->
<MenuItem Name="End Feature" />		<!-- End development, merge and push the changes to remote repositories -->
<MenuItem Separator="1" Name="----------------------------------"/> 
<MenuItem Name="Import System" />			<!-- Import an existing GIT system into this machine -->
<MenuItem Name="Create System" />			<!-- Create a brand new system and set up local GIT repo -->
</Menu>
</MenuBase>
]]></Data>
</XData>

<Method name="UserAction">
<Description><![CDATA[
This is called when the user has selected a menu item and in this method we must
decide if there any further user input required. Briefly this is:<ul>
<li>0 = No further input required</li>
<li>1 = Default Yes, No, Cancel (target has text)</li>
<li>2 = Run CSP (target is url, page will be passed doc name, selected text, project name and namespace</li>
<li>3 = Run EXE (target is name of exe)</li>
<li>4 = Insert text at current point (target has text to add)</li>
<li>5 = Open listed documents (target has documents listed)</li>
<li>6 = Alert box (target has text)</li>
<li>7 = Textybox + Yes, No, Cancel (target has text, Msg any default value)</li>
</ul><br />See %Studio.Extension.Base for full description]]></Description>
<FormalSpec><![CDATA[Type:%Integer,Name:%String,InternalName:%String,SelectedText:%String,&Action:%String,&Target:%String,&Msg:%String,&Reload:%Boolean]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set tMenu=$P(Name, ",", 1)
	set tItem=""
	set:Type=0 tItem=$ZSTRIP($P(Name, ",", 2), "*W")
	set:Type=1 tItem=$S(Name=0:"LockedDoc", Name=1:"NewDoc", Name=2:"DelDoc", Name=3:"OpenDoc", Name=4:"ClosedDoc", Name=5:"NewNS", Name=6:"ImportCSV", 1:"Unknown")
	write:..Debug>Type !,$P($ZTS, ",", 2),": Handling Menu "_Type_":"_tMenu_":"_tItem_":"_InternalName_"="_tMenu
	
	if tItem="LockedDoc" {
		if ..ForwardEdit { set Action=0 }
		else {
			set Action=6
			set Target="There appears to be no active feature, please start a feature branch before changing the code"
		}
	}
	elseif tItem="Project" {
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.Project.cls?Project="_..ProjectName }
	}
	elseif tItem="Fetch" {		
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.Fetch.cls?Project="_..ProjectName }
	}
	elseif tItem="Package" {		
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.Package.cls?Project="_..ProjectName }
	}
	elseif tItem="Settings" {
		set Action=2  
		set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.Settings.cls?Project="_..ProjectName
	}
	elseif tItem="StartFeature" {
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		elseif ..Feature'="" { set Action=6  set Target="You are already developing a feature ["_..Feature_"], you must end this first" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.StartFeature.cls?Project="_..ProjectName }
	}
	elseif tItem="Export" {
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		elseif ..Feature="" { set Action=6  set Target="You do not appear to be developing a feature, start one off first" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.ExportSource.cls?Project="_..ProjectName }
	}
	elseif tItem="EndFeature" {			
		if ..System="" { set Action=6  set Target="You do not appear to be currently working in an active CFDSource project/repo" }
		elseif ..Feature="" { set Action=6  set Target="You do not appear to be developing a feature, start one off first" }
		else { set Action=2  set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.EndFeature.cls?Project="_..ProjectName }
	}
	elseif tItem="ImportSystem" {
		set Action=2
		set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.ImportProject.cls?Project="_..ProjectName
	}
	elseif tItem="CreateSystem" {
		if $IsObject(..System) { set Action=6  set Target="You appear to be currently working in an active CFDSource project/repo" }
		set Action=2
		set Target=$system.CSP.GetDefaultApp($NAMESPACE)_"/CFDSource.UI.NewProject.cls?Project="_..ProjectName
	}
	
	else {
		set Action=0
	}
	
	Quit $$$OK
]]></Implementation>
</Method>

<Method name="AfterUserAction">
<Description>
Called after any action actually ran.
In our case the UI does everything so nothing is needed!</Description>
<FormalSpec><![CDATA[Type:%Integer,Name:%String,InternalName:%String,Answer:%Integer,Msg:%String="",&Reload:%Boolean]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set tMenu=$P(Name, ",", 1)
	set tItem=""
	set:Type=0 tItem=$ZSTRIP($P(Name, ",", 2), "*W")
	set:Type=1 tItem=$S(Name=0:"LockedDoc", Name=1:"NewDoc", Name=2:"DelDoc", Name=3:"OpenDoc", Name=4:"ClosedDoc", Name=5:"NewNS", Name=6:"ImportCSV", 1:"Unknown")
	
	// Might have changed the branch
	if (Type=0)&&($IsObject(..System)) {
		set branch=..System.GetCurrentFeature()
		write:(branch'=..Feature)&&(..Debug>0) !,$P($ZTS, ",", 2),": *** Now on branch [",$S(..Feature="":"develop", 1:..Feature),"]"
		set ..Feature=branch
	}
	
	// Might have created the current project as a CFD project
	if (Type=0)&&('$IsObject(..System))&&(##class(CFDSource.System).Exists(..ProjectName)) {
		set ..System=##class(CFDSource.System).%New(..ProjectName)
		set ..Feature=..System.GetCurrentFeature()
		write:..Debug>0 !,$P($ZTS, ",", 2),": *** Opened Project, Studio in sync with ",..System.Name,"-",..System.Version," on branch [",$S(..Feature="":"develop", 1:..Feature),"]"
	}
	
	Set Reload=0
	Quit $$$OK
]]></Implementation>
</Method>

<Method name="GetStatus">
<Description>
Return information about this entity.</Description>
<FormalSpec><![CDATA[InternalName:%String,&IsInSourceControl:%Boolean,&Editable:%Boolean,&IsCheckedOut:%Boolean,&UserCheckedOut:%String]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	Set Editable=1,IsCheckedOut=0,UserCheckedOut="",IsInSourceControl=0
	quit:'$IsObject(..System) $$$OK
	
	set type=..ItemType(InternalName)
	quit:type="Project" $$$OK
	
	set coreName=$P(InternalName, ".", 1, ($L(InternalName, ".")-1))
	set ext=$ZCVT($P(InternalName,".",$L(InternalName, ".")), "L")
	
	if ##class(CFDSource.Util.ProjectItemsUtil).IsInProject(..ProjectName, coreName_"."_ext, 1) {
		set IsInSourceControl=1
		set Editable=..Feature'=""
		
		// Get out of Jail Free
		if ('Editable)&&(..ForwardEdit) {
			set Editable=1
			write:..Debug>1 !,$P($ZTS, ",", 2),": *** Forward Edit on, disabling status check. ",InternalName," is editable as a result"
		}
	}
	else {
		write:..Debug>1 !,$P($ZTS, ",", 2),": *** Non project item opened: ",InternalName
	}
		
	Quit $$$OK
]]></Implementation>
</Method>

<Method name="OnBeforeLoad">
<Description>
This is called before the actual load of data to give the chance
to load the item from an external format.</Description>
<FormalSpec>InternalName:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set type=..ItemType(InternalName)
	set coreName=$P(InternalName, ".", 1, ($L(InternalName, ".")-1))
	
	// Open Project
	if type="project" {
		set ..ProjectName=coreName
		if ##class(CFDSource.System).Exists(coreName) {
			set ..System=##class(CFDSource.System).%New(coreName)
			set ..Feature=..System.GetCurrentFeature()
			write:..Debug>0 !,$P($ZTS, ",", 2),": *** Opened Project, Studio in sync with ",..System.Name,"-",..System.Version," on branch [",$S(..Feature="":"develop", 1:..Feature),"]"
		}
		else {
			write:..Debug>0 !,$P($ZTS, ",", 2),": !!! The opened project does not have a CFDSource.System present, not using Source Control tie in for project: ",coreName
		}
	}
	
	Quit $$$OK
]]></Implementation>
</Method>

<Method name="ItemType">
<Description>
helper function to determine project item type</Description>
<FormalSpec>InternalName:%String</FormalSpec>
<Private>1</Private>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	if $zcvt(InternalName,"U")[".CLS" quit "class"
	if $zcvt(InternalName,"U")[".CSP" quit "csp"
	if $zcvt(InternalName,"U")[".CSR" quit "csp"
	if $zcvt(InternalName,"U")[".PRJ" quit "project"
	if $zcvt(InternalName,"U")[".INC" quit "routine"
	if $zcvt(InternalName,"U")[".MAC" quit "routine"
	if $zcvt(InternalName,"U")[".BAS" quit "routine"
	if $zcvt(InternalName,"U")[".MVB" quit "routine"
	if $zcvt(InternalName,"U")[".INT" quit "internal"
	if $zcvt(InternalName,"U")[".MVI" quit "internal"
	if $zcvt(InternalName,"U")[".PKG" quit "package"
	quit "other"
]]></Implementation>
</Method>
</Class>
</Export>
