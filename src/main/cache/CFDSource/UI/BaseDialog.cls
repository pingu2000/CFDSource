<?xml version="1.0" encoding="UTF-8"?>
<Export generator="Cache" version="25">
<Class name="CFDSource.UI.BaseDialog">
<Description>
The base for all our Confidence studio dialog elements

Copyright, Tom Spencer. This file is part of CFDSource. See root or https://github.com/thegaffer/CFDSource for full GPLv3 license</Description>
<Super>%ZEN.Template.studioTemplate</Super>
<TimeCreated>62660,5463.138889</TimeCreated>

<Parameter name="APPLICATION">
<Description>
Class name of application this page belongs to.</Description>
<Default>CFDSource.UI.App</Default>
</Parameter>

<Parameter name="DOMAIN">
<Description>
Domain used for localization.</Description>
<Default>CFD</Default>
</Parameter>

<Parameter name="PAGENAME">
<Description>
Name of all dialogs</Description>
<Default>CFD</Default>
</Parameter>

<Property name="System">
<Description>
The current system</Description>
<Type>CFDSource.System</Type>
<Private>1</Private>
<Transient>1</Transient>
</Property>

<Property name="ExistingCode">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ExistingData">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ExistingTestCode">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ExistingTestData">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="GroupId">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Version">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Brief">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="TestPrefix">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Installer">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="Feature">
<Type>%String</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ProjectOpen">
<Description>
Returns true if we are in an active feature</Description>
<Type>%Boolean</Type>
<Calculated>1</Calculated>
</Property>

<Property name="ProjectLocked">
<Description>
Returns true if we are not in an active feature</Description>
<Type>%Boolean</Type>
<Calculated>1</Calculated>
</Property>

<Method name="GroupIdGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..GetSystem().GroupId
]]></Implementation>
</Method>

<Method name="VersionGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..GetSystem().Version
]]></Implementation>
</Method>

<Method name="BriefGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..GetSystem().Brief
]]></Implementation>
</Method>

<Method name="TestPrefixGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..GetSystem().TestPrefix
]]></Implementation>
</Method>

<Method name="InstallerGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit ..GetSystem().Installer
]]></Implementation>
</Method>

<Method name="FeatureGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set feature=..GetSystem().GetCurrentFeature()
	quit $S(feature'="":feature, 1:"<None>")
]]></Implementation>
</Method>

<Method name="ProjectOpen">
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set feature=..GetSystem().GetCurrentFeature()
	quit feature'=""
]]></Implementation>
</Method>

<Method name="ProjectLockedGet">
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	set feature=..GetSystem().GetCurrentFeature()
	quit feature=""
]]></Implementation>
</Method>

<XData name="Style">
<Description>
This Style block contains page-specific CSS style definitions.</Description>
<Data><![CDATA[
<style type="text/css">
div.dialog {
	padding: 10px;
	font-size: 0.9em;
}

.title {
	font-size: 1.5em;
	font-weight: bold;
	font-style: italic;
	border-bottom: thin ridge;
	padding-bottom: 5px;
	margin-bottom: 10px;
}

div.description {
	margin-bottom: 10px;
}

div.frm div.notes {
	margin-left: 8em;
	background-color: white;
	border: thin ridge gray;
	font-size: 0.91em;
}

div.frm div.inlinenotes {
	margin: 3px;
	padding: 3px;
	background-color: #F8F8F8;
	border: thin ridge grey;
	font-size: 0.8em;
	color: #000099;
}

/* Needed to ensure all line up */
div.frm input.text {
	
}

/* Needed to ensure all line up */
div.frm textarea {
	
}

/* Ensure the labels and fields don't wrap */
div.frm td {
	white-space: nowrap;
}

div.frm span.zenLabel {
	display: inline-block;
	width: 8em;
	text-align: right;
	vertical-align: top;
	font-size: 0.9em;
	font-weight: bold;
	color: gray;
	margin-left: 5px;
	margin-right: 8px;
}

div.frm div.fld {
	display: inline;
}

div.frm div#syncMode.fld {
	display: inline-block ! important;
	width: 300px;
}

div.frm div.roFld input  {
	background-color: #F0F0F0;
	font-style: italic;
}

div.frm div.actions {
	margin-top: 10px;
	padding-left: 8em;
}

div.debug {
	margin-top: 50px;
	border-top: thin ridge;
	padding-top: 10px;
}

div.tabset {
	margin-left: 8em;
	padding-left: 23px;
	margin-top: 5px;
	margin-bottom: 5px;
	font-size: 0.9em;
	width: 550px;
}

div.tabset div {
	background-color: #E0E0E0;
}

div.listBox {
	width: auto;
	background-color: white ! important;
}

div.tabset div.tabGroupBody {
	min-height: 100px;
}

</style>
]]></Data>
</XData>

<XData name="Contents">
<Description>
Overridden Contents</Description>
<XMLNamespace>http://www.intersystems.com/zen</XMLNamespace>
<Data><![CDATA[
<page xmlns="http://www.intersystems.com/zen" >
<html id="header" OnDrawContent="%DrawTitle" />
<form id="templateForm" groupStyle=""
onvalidate="return zenPage.formValidationHandler();">
<hidden id="templateFinal" name="$FINAL" value="0" />
<pane paneName="templateBody" id="body"/>
</form>
<hgroup id="footer" width="100%" cellAlign="right">
<hgroup id="buttonHolder" cellAlign="right">
<button id="btnSource" controlClass="commandButton" caption="Source" onclick="zenPage.showSource();" hidden="#(%page.GetSourceHidden())#"/>
<spacer width="15" />
<button id="btnBack" controlClass="commandButton" caption="Back" onclick="zenPage.previousPage();" hidden="true"/>
<spacer width="5" />
<button id="btnNext" controlClass="commandButton" caption="Next" onclick="zenPage.nextPage();" hidden="true"/>
<spacer width="15" />
<button id="btnFinish" controlClass="commandButton" caption="Finish" onclick="zenPage.finishTemplate();" />
<spacer width="5" />
<button id="btnCancel" controlClass="commandButton" caption="Cancel" onclick="zenPage.cancelTemplate();" />
<spacer width="15" />
<button id="btnHelp" controlClass="commandButton" caption="Help" onclick="zenPage.showHelp();" />
<spacer width="10" />
</hgroup>
</hgroup>
</page>
]]></Data>
</XData>

<XData name="CodeAndDataPane">
<XMLNamespace>http://www.intersystems.com/zen</XMLNamespace>
<Data><![CDATA[
<pane>
<tabGroup id="codeAndData" showTabBar="true" width="500px" height="180px" enclosingClass="tabset" >
<tab caption="Data" width="100%">
<hgroup>
<text id="dataglobal" name="DataGlobal" size="30" />
<html>=</html>
<text id="dataname" name="DataGlobalName" size="20" />
</hgroup>
<html enclosingClass="inlinenotes">i.e. GlobalD[("Subscript")]={Name}</html>
<hgroup>
<button name="AddData" caption="Add" onclick="zenPage.onAddToData('data')" />
<button name="RemData" caption="Remove" onclick="zenPage.onRemoveFromCode('data')" />
<button name="ResetData" caption="Clear" onclick="zenPage.onClearCode('data')" />
</hgroup>
<listBox id="data" name="DataL" width="100%" />
<hidden id="datah" name="Data" value="#(%page.ExistingData)#" />
<hidden id="dataho" name="DataO" value="#(%page.ExistingData)#" />
</tab>
<tab caption="TestData" width="100%">
<hgroup>
<text id="testdataglobal" name="testdataGlobal" size="30" />
<html>=</html>
<text id="testdataname" name="testdataGlobalName" size="20" />
</hgroup>
<html enclosingClass="inlinenotes">i.e. GlobalD[("Subscript")]={Name}</html>
<hgroup>
<button name="AddTestData" caption="Add" onclick="zenPage.onAddToData('testdata')" />
<button name="RemTestData" caption="Remove" onclick="zenPage.onRemoveFromCode('testdata')" />
<button name="ResetTestData" caption="Clear" onclick="zenPage.onClearCode('testdata')" />
</hgroup>
<listBox id="testdata" name="TestDataL" width="100%" />
<hidden id="testdatah" name="TestData" value="#(%page.ExistingTestData)#" />
<hidden id="testdataho" name="TestDataO" value="#(%page.ExistingTestData)#" />
</tab>
</tabGroup>
</pane>
]]></Data>
</XData>

<Method name="GetSourceHidden">
<Description>
Called to set state of source button</Description>
<ReturnType>%Boolean</ReturnType>
<Implementation><![CDATA[
	quit:$G(^CFD.Studio.Debug, 0)>2 0
	quit 1
]]></Implementation>
</Method>

<Method name="GetSystem">
<Description>
Helper method to get the system, this will set it if not set already
Only gets the system if it does not exist - does not return a system that does not yet exist!</Description>
<ReturnType>CFDSource.System</ReturnType>
<Implementation><![CDATA[
	quit:..Project="" ""
	
	if '$IsObject(..System) { 
		set ..System=""
		set:##class(CFDSource.System).Exists(..Project) ..System=##class(CFDSource.System).%New(..Project) 
	}
	elseif ..System.Name'=..Project { 
		set ..System=""
		set:##class(CFDSource.System).Exists(..Project) ..System=##class(CFDSource.System).%New(..Project) 
	}
	
	quit ..System
]]></Implementation>
</Method>

<Method name="onstartHandler">
<Description>
This is called when the template is first displayed;
This provides a chance to set focus etc.</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	for( j=0 ; j < 4 ; j++ ) {
		var lstId="code";
		if( j==1 ) { lstId = "data"; }
		if( j==2 ) { lstId = "testcode"; }
		if( j==3 ) { lstId = "testdata"; }
		var hidId=lstId+"h";
		
		var lst=this.getComponentById(lstId);
		if( (lst != null) && (lst.getOptionCount() == 0) ) {
			var hid=this.getComponentById(hidId);
			if( (hid != null) && (hid.getValue() != "") ) {
				var items=hid.getValue().split(",");
				for( i = 0 ; i < items.length ; i++ ) {
					lst.appendOption(items[i]);
				}
			}
		}
	}
]]></Implementation>
</Method>

<Method name="onfinishHandler">
<Description>
This is called when the template is finished;</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[	return true;
]]></Implementation>
</Method>

<Method name="showSource">
<Description>
When CFD in debug mode, shows to display the source of the window (for debugging CFD itself!)</Description>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var popup=window.open();
	popup.document.open('text/plain').write(document.documentElement.outerHTML)
]]></Implementation>
</Method>

<Method name="%DrawTitle">
<Description>
Provide HTML for standard template html title box.
Overridden to use page name in dialog</Description>
<FormalSpec>pSeed:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	#; draw html title box
	Set tName = ..#PAGENAME
	Set tTitle = ..#TEMPLATETITLE
	Set tUserName = $$$Text("User","%ZEN")
	Set tNamespace = $$$Text("Namespace","%ZEN")

	&html<<table class="stdTitle" border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr>
		<td align="left" width="58"><img width="58" height="58" src="#(..Link("portal/icon_sysexplore.png"))#"/></td>
		<td align="left" width="90%" style="padding-left:20px;">
		<div style="font-size: 0.6em;">#(tName)#</div>
		<div>#(tTitle)#</div></td>
		<td valign="top">&nbsp;
		<table class="stdTitleInfo" border="0" cellpadding="0" cellspacing="2">
		<tr><th>#(tUserName)#:</th><th>#($UserName)#</th></tr>
		<tr><th>#(tNamespace)#:</th><th>#($ZU(5))#</th></tr>
		</table>
		</td>
		</tr></table>>
	Quit $$$OK
]]></Implementation>
</Method>

<Method name="OutputConsole">
<Description>
This method outputs to the output console in the diagram, both a
general indication of success/failure and any lines in the output</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>pStatus:%Status,pTask:%String,pOutput:%Stream.Object</FormalSpec>
<Implementation><![CDATA[
	if $$$ISERR(pStatus) {
		set err=$system.Status.GetErrorText(pStatus)
		
		&js<var ta=zenPage.getComponentById('output');>
		&js<ta.setValue("Failed to #(pTask)# ...");>
		&js<ta.setValue(ta.getValue()+"\n"+"Status: #(err)#");>
	}
	else {
		&js<var ta=zenPage.getComponentById('output');>
		&js<ta.setValue("#(pTask)# succeded ...");>
	}
	
	set rows=2
	if $D(pOutput)&&$IsObject(pOutput) {
		set i=1
		do pOutput.Rewind()
		while 'pOutput.AtEnd {
			set ln=pOutput.ReadLine()
			set i=$I(i)
			quit:i>100
			continue:ln=""
			
			//set ln=$TR(ln, "\", "/")
			//set ln=$TR(ln, "'", """")
			set ln=$ZCVT(ln, "O", "JS")
			&js<ta.setValue(ta.getValue()+"\n"+'#(ln)#');>
			set rows=$I(rows)
		}
	}
	
	//if rows>5 { &js<ta.setProperty("rows", "#(rows)#");> }
	&js<ta.setHidden(false);>
]]></Implementation>
</Method>

<Method name="ExistingCodeGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set ret=""
	set sys=..GetSystem()
	quit:'$IsObject(sys) ret
	
	for i=1:1:sys.Code.Count() {
		set ret=ret_$S(ret="":"", 1:",")_sys.Code.GetAt(i)
	}
	
	quit ret
]]></Implementation>
</Method>

<Method name="ExistingDataGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set ret=""
	set sys=..GetSystem()
	quit:'$IsObject(sys) ret
	
	do {
		set v=sys.Data.GetNext(.k)
		quit:k=""
		
		set ret=ret_$S(ret="":"", 1:",")_k_"="_v
	} while k'=""
	
	quit ret
]]></Implementation>
</Method>

<Method name="ExistingTestCodeGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set ret=""
	set sys=..GetSystem()
	quit:'$IsObject(sys) ret
	
	for i=1:1:sys.TestCode.Count() {
		set ret=ret_$S(ret="":"", 1:",")_sys.TestCode.GetAt(i)
	}
	
	quit ret
]]></Implementation>
</Method>

<Method name="ExistingTestDataGet">
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set ret=""
	set sys=..GetSystem()
	quit:'$IsObject(sys) ret
	
	do {
		set v=sys.TestData.GetNext(.k)
		quit:k=""
		
		set ret=ret_$S(ret="":"", 1:",")_k_"="_v
	} while k'=""
	
	quit ret
]]></Implementation>
</Method>

<Method name="onCodePackageType">
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var type=this.getComponentById(name+"PackageType").getValue();
	
	this.getComponentById(name+"tlPackages").setHidden(type != "TLP");
	this.getComponentById(name+"allPackages").setHidden(type != "All");
	this.getComponentById(name+"allClasses").setHidden(type != "Code");
]]></Implementation>
</Method>

<Method name="onAddToCode">
<FormalSpec>name</FormalSpec>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var type=this.getComponentById(name+"PackageType").getValue();
	var sel=""
	
	if( type == "TLP" ) { sel=this.getComponentById(name+"tlPackages").getValue()+".pkg"; }
	else if( type == "All" ) { sel=this.getComponentById(name+"allPackages").getValue()+".pkg"; }
	else { sel = sel=this.getComponentById(name+"allClasses").getValue()+".cls"; }
	
	// Add if not already present
	var found=false;
	var lst=this.getComponentById(name);
	for( i=0 ; (i<lst.getOptionCount())&&(!found) ; i++ ) {
		if( lst.getOptionValue(i)==sel ) found=true;
	}
	if( !found ) {
		lst.appendOption(sel);
		
		var hid=this.getComponentById(name+"h");
		if( hid.getValue() != "" ) hid.setValue(hid.getValue()+","+sel)
		else hid.setValue(sel)
	}
]]></Implementation>
</Method>

<Method name="onAddToData">
<FormalSpec>name</FormalSpec>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var global=this.getComponentById(name+"global").getValue();
	var index=this.getComponentById(name+"name").getValue();
	var sel=index+"="+global
	
	// Add if not already present
	var found=false;
	var lst=this.getComponentById(name);
	for( i=0 ; (i<lst.getOptionCount())&&(!found) ; i++ ) {
		if( lst.getOptionValue(i)==sel ) found=true;
	}
	if( !found ) {
		lst.appendOption(sel);
		
		var hid=this.getComponentById(name+"h");
		if( hid.getValue() != "" ) hid.setValue(hid.getValue()+","+sel)
		else hid.setValue(sel)
	}
]]></Implementation>
</Method>

<Method name="onRemoveFromCode">
<FormalSpec>name</FormalSpec>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	var lst=this.getComponentById(name);
	lst.removeOption(lst.selectedIndex);
	
	// Not greatest efficiency, but it should work!
	var hid=this.getComponentById(name+"h");
	hid.setValue("");
	for( i=0 ; (i<lst.getOptionCount())&&(!found) ; i++ ) {
		if( hid.getValue() != "" ) hid.setValue(hid.getValue()+","+lst.getOptionValue(i))
		else hid.setValue(lst.getOptionValue(i))
	}
]]></Implementation>
</Method>

<Method name="onClearCode">
<FormalSpec>name</FormalSpec>
<Language>javascript</Language>
<ClientMethod>1</ClientMethod>
<Implementation><![CDATA[
	this.getComponentById(name).resetOptions();
	this.getComponentById(name+"h").setValue("");
]]></Implementation>
</Method>

<Query name="Packages">
<Description>
Query to get top-level packages, all packages or all classes</Description>
<Type>%Query</Type>
<FormalSpec>Type:%String</FormalSpec>
<Parameter name="CONTAINID" value="1"/>
<Parameter name="ROWSPEC" value="Name:%String"/>
</Query>

<Method name="PackagesExecute">
<Description>
Sets up a process private varable</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[&qHandle:%Binary,Type:%String]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set cls=$O(^oddDEF("%zzz"))
	while cls'="" {
		set pkg=$S(Type="3":cls, 1:$P(cls, ".", 1, $S(Type="1":1, 1:($L(cls, ".")-1))))
		set ^||Packages(pkg)=""
		set cls=$O(^oddDEF(cls))
	}
	
	set qHandle=$O(^||Packages(""))
      quit $$$OK
]]></Implementation>
</Method>

<Method name="PackagesFetch">
<Description>
Iterates around the process private variable setup in execute</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[&qHandle:%Binary,&Row:%List,&AtEnd:%Integer=0]]></FormalSpec>
<PlaceAfter>PackagesExecute</PlaceAfter>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set pkg=qHandle
	
	if pkg="" {
		set Row=""
		set AtEnd=1
	}
	else {
		set Row=$LB(pkg)
		set AtEnd=0
		set qHandle=$O(^||Packages(pkg))
	}
	
	quit $$$OK
]]></Implementation>
</Method>

<Method name="PackagesClose">
<Description>
Clears down the process private varable</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[&qHandle:%Binary]]></FormalSpec>
<PlaceAfter>PackagesExecute</PlaceAfter>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	kill ^||Packages
	quit $$$OK
]]></Implementation>
</Method>
</Class>
</Export>
